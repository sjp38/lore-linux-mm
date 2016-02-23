Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFF06B025F
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:51:50 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so223177273wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:51:50 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id o187si39690897wma.118.2016.02.23.05.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 05:51:49 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id a4so209950452wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:51:49 -0800 (PST)
Message-ID: <56CC63F2.3040503@plexistor.com>
Date: Tue, 23 Feb 2016 15:51:46 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com> <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com> <56CA1CE7.6050309@plexistor.com> <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com> <56CA2AC9.7030905@plexistor.com> <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com> <20160221223157.GC25832@dastard> <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/22/2016 05:34 PM, Jeff Moyer wrote:
> Hi, Dave,
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
>>> Another potential issue is that MAP_PMEM_AWARE is not enough on its
>>> own.  If the filesystem or inode does not support DAX the application
>>> needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
>>> requests would need to fail if DAX is not available.
>>
>> They will always still need to call msync()/fsync() to guarantee
>> data integrity, because the filesystem metadata that indexes the
>> data still needs to be committed before data integrity can be
>> guaranteed. i.e. MAP_PMEM_AWARE by itself it not sufficient for data
>> integrity, and so the app will have to be written like any other app
>> that uses page cache based mmap().
>>
>> Indeed, the application cannot even assume that a fully allocated
>> file does not require msync/fsync because the filesystem may be
>> doing things like dedupe, defrag, copy on write, etc behind the back
>> of the application and so file metadata changes may still be in
>> volatile RAM even though the application has flushed it's data.
> 
> Once you hand out a persistent memory mapping, you sure as heck can't
> switch blocks around behind the back of the application.
> 
> But even if we're not dealing with persistent memory, you seem to imply
> that applications needs to fsync just in case the file system did
> something behind its back.  In other words, an application opening a
> fully allocated file and using fdatasync will also need to call fsync,
> just in case.  Is that really what you're suggesting?
> 
>> Applications have no idea what the underlying filesystem and storage
>> is doing and so they cannot assume that complete data integrity is
>> provided by userspace driven CPU cache flush instructions on their
>> file data.
> 
> This is surprising to me, and goes completely against the proposed
> programming model.  In fact, this is a very basic tenet of the operation
> of the nvml libraries on pmem.io.
> 
> That aside, let me see if I understand you correctly.
> 
> An application creates a file and writes to every single block in the
> thing, sync's it, closes it.  It then opens it back up, calls mmap with
> this new MAP_DAX flag or on a file system mounted with -o dax, and
> proceeds to access the file using loads and stores.  It persists its
> data by using non-temporal stores, flushing and fencing cpu
> instructions.
> 
> If I understand you correctly, you're saying that that application is
> not written correctly, because it needs to call fsync to persist
> metadata (that it presumably did not modify).  Is that right?
> 

Hi Jeff

I do not understand why you chose to drop my email address from your
reply? What do I need to feel when this happens?

And to your questions above. As I answered to Dave.
This is the novelty of my approach and the big difference between
what you guys thought with MAP_DAX and my patches as submitted.
 1. Application will/need to call m/fsync to let the FS the freedom it needs
 2. The m/fsync as well as the page faults will be very light wait and fast,
    all that is required from the pmem aware app is to do movnt stores and cl_flushes.

So enjoying both worlds. And actually more:
With your approach of fallocat(ing) the all space in advance you might as well
just partition the storage and use the DAX(ed) block device. But with my
approach you need not pre-allocate and enjoy the over provisioned model and
the space allocation management of a modern FS. And even with all that still
enjoy very fast direct mapped stores by not requiring the current slow m/fsync()

I hope you guys stand behind me in my effort to accelerate userspace pmem apps
and still not break any built in assumptions.

> -Jeff

Cheers
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
