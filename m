Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA6A6B0254
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 04:57:45 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so163648737wme.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 01:57:45 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id vl10si36838062wjc.75.2016.02.22.01.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 01:57:44 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g62so149106263wme.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 01:57:44 -0800 (PST)
Message-ID: <56CADB95.4080701@plexistor.com>
Date: Mon, 22 Feb 2016 11:57:41 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com> <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com> <56CA1CE7.6050309@plexistor.com> <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com> <56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com> <20160221223157.GC25832@dastard>
In-Reply-To: <20160221223157.GC25832@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On 02/22/2016 12:31 AM, Dave Chinner wrote:
> On Sun, Feb 21, 2016 at 02:03:43PM -0800, Dan Williams wrote:
>> On Sun, Feb 21, 2016 at 1:23 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>> On 02/21/2016 10:57 PM, Dan Williams wrote:
>>>> On Sun, Feb 21, 2016 at 12:24 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>>>> On 02/21/2016 09:51 PM, Dan Williams wrote:
>>> Sure. please have a look. What happens is that the legacy app
>>> will add the page to the radix tree, come the fsync it will be
>>> flushed. Even though a "new-type" app might fault on the same page
>>> before or after, which did not add it to the radix tree.
>>> So yes, all pages faulted by legacy apps will be flushed.
>>>
>>> I have manually tested all this and it seems to work. Can you see
>>> a theoretical scenario where it would not?
>>
>> I'm worried about the scenario where the pmem aware app assumes that
>> none of the cachelines in its mapping are dirty when it goes to issue
>> pcommit.  We'll have two applications with different perceptions of
>> when writes are durable.  Maybe it's not a problem in practice, at
>> least current generation x86 cpus flush existing dirty cachelines when
>> performing non-temporal stores.  However, it bothers me that there are
>> cpus where a pmem-unaware app could prevent a pmem-aware app from
>> making writes durable.  It seems if one app has established a
>> MAP_PMEM_AWARE mapping it needs guarantees that all apps participating
>> in that shared mapping have the same awareness.
> 
> Which, in practice, cannot work. Think cp, rsync, or any other
> program a user can run that can read the file the MAP_PMEM_AWARE
> application is using.
> 

Yes what of it? nothing will happen, it all just works.

Perhaps you did not understand, we are talking about DAX mapped
file. Not a combination of dax vs page-cached system.

One thread stores a value X in memory movnt style, one thread pocks
the same X value from memory, CPUs do this all the time. What of it?

>> Another potential issue is that MAP_PMEM_AWARE is not enough on its
>> own.  If the filesystem or inode does not support DAX the application
>> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
>> requests would need to fail if DAX is not available.

DAN this is a good Idea. I will add it. In a system perspective this
is not needed. In fact today what will happen if you load nvml on a
none -dax mounted fs? nothing will work at all even though at the
beginning the all data seems to be there. right?
But I think with this here it is a chance for us to let nvml unload
gracefully before any destructive changes are made.

> 
> They will always still need to call msync()/fsync() to guarantee
> data integrity, because the filesystem metadata that indexes the
> data still needs to be committed before data integrity can be
> guaranteed. i.e. MAP_PMEM_AWARE by itself it not sufficient for data
> integrity, and so the app will have to be written like any other app
> that uses page cache based mmap().
> 

Sure yes. I agree completely. msync()/fsync() will need to be called.

I apologize, you have missed the motivation of this patch because I
did not explain very good. Our motivation is speed.

One can have durable data by:
1. Doing movnt  - Done and faster then memcpy even
2. radix-tree-add; memcpy; cl_flush;
   Surly this one is much slower lock heavy, and resource consuming.
   Our micro benchmarks show 3-8 times slowness. (memory speeds remember)

So sure a MAP_PMEM_AWARE *must* call m/fsync() for data integrity but
will not pay the "slow" price at all, it will all be very fast because
the o(n) radix-tree management+traversal+cl_flush will not be there, only
the meta-data bits will sync.

> Indeed, the application cannot even assume that a fully allocated
> file does not require msync/fsync because the filesystem may be
> doing things like dedupe, defrag, copy on write, etc behind the back
> of the application and so file metadata changes may still be in
> volatile RAM even though the application has flushed it's data.
> Applications have no idea what the underlying filesystem and storage
> is doing and so they cannot assume that complete data integrity is
> provided by userspace driven CPU cache flush instructions on their
> file data.
> 

Exactly, m/fsync() is needed, only will be much *faster*

> This "pmem aware applications only need to commit their data"
> thinking is what got us into this mess in the first place. It's
> wrong, and we need to stop trying to make pmem work this way because
> it's a fundamentally broken concept.
> 

Hey sir Dave, Please hold your horses. What mess are you talking about?
there is no mess. All We are trying to do is enable model [1] above vs
current model [2], which costs a lot.

Every bit of data integrity and FS freedom to manage data behind the
scenes, is kept intact.
	YES apps need to fsync!

Thank you, I will add this warning in the next submission. To explain
better.

> Cheers,
> Dave.
> 

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
