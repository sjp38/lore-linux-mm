Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9073B6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:55:29 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id g62so219967473wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:55:29 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id n6si9265712wjw.45.2016.02.23.13.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 13:55:28 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id a4so3780303wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:55:27 -0800 (PST)
Message-ID: <56CCD54C.3010600@plexistor.com>
Date: Tue, 23 Feb 2016 23:55:24 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56C9EDCF.8010007@plexistor.com>	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>	<56CA1CE7.6050309@plexistor.com>	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>	<56CA2AC9.7030905@plexistor.com>	<CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>	<20160221223157.GC25832@dastard>	<x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>	<20160222174426.GA30110@infradead.org>	<257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>	<20160223095225.GB32294@infradead.org>	<56CC686A.9040909@plexistor.com> <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
In-Reply-To: <CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/23/2016 06:56 PM, Dan Williams wrote:
> On Tue, Feb 23, 2016 at 6:10 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> On 02/23/2016 11:52 AM, Christoph Hellwig wrote:
> [..]
>> Please tell me what you find wrong with my approach?
> 
> Setting aside fs interactions you didn't respond to my note about
> architectures where the pmem-aware app needs to flush caches due to
> other non-pmem aware apps sharing the mapping.  Non-temporal stores
> guaranteeing persistence on their own is an architecture specific
> feature.  I don't see how we can have a generic support for mixed
> MAP_PMEM_AWARE / unaware shared mappings when the architecture
> dependency exists [1].
> 

I thought I did. your Pentium M example below is just fine.
Or I'm missing something really big here. so you will need
to step me through real slow.

Lets say we have a very silly system
[Which BTW will never exist because again the presidence of NFS and
applications are written to do work also over NFS]

So say in this system two applications one writes to all the even
addressed longs and the second writes to all the odd addressed in
a given page. then app 1 syncs and so does app 2. Only after both syncs
the system is stable at a known checkpoint, because before to union of the
two syncs we do not know what will persist to harddisk, right?

Now say we are dax and app 1 is MAP_PMEM_AWAR and app 2 is old.

app 1] faults in page X; Does its "evens" stores Pentium M movnt style directly
      to memory, all odd addresses new values are still in cache.

app 2] faults in page X; the page is in the radix tree because it is "old-style"
       does its cached "odds" stores; calls a sync that does cl_flush.

Lets look at a single cacheline. 
- If app 2 sync came before app1 movnt then in memory we have a zebra of zeros and app2 values.
  but once app 1 came along and did its movnt all expected values are there persistent.

- If app 1 stores came before app 2 sync, then we have a zebra of app1 + zeros.
  But once sync came we have persistent both values.

In any which case we are guarantied persistence when both apps finished their
run. If we interrupt the run at any point before, we will have zebra cachlines
even if we are talking about a regular harddisk with regular volatile page cache.

So I fail to see what is broken, please explain. What broken senario you are
seeing? that before dax/none-dax would work?

(For me BTW the two applications that intimately share a single cacheline are one
 multi process application and for me they need to understand what they are doing.
 if the admin upgrages the one he should also upgrade the other. Look in the real
 world, who are heavy users of MAP_SHARED, can you imagine gcc linker sharing the same
 file with another concurrent application? the only one that I know that remotely does
 that is git. And git makes sure to take file locks when it writes such shared records.
 Git works over NFS as well)

But seriously please explain the problem. I do not see one.

> I think Christoph has already pointed out the roadmap.  Get the
> existing crop of DAX bugs squashed 

Sure that's always true, I'm a stability freak through and through ask
the guys who work with me. I like to sleep at night ;-)

> and then *maybe* look at something
> like a MAP_SYNC to opt-out of userspace needing to call *sync.
> 

MAP_SYNC Is another novelty, which as Dave showed will not be implemented
by such a legacy filesystem as xfs. any time soon. sync is needed not only
for memory stores. For me this is a supper set of what I proposed. because
again any file writes persistence is built of two parts durable data, and
durable meta-data. My flag says, app takes care of data, then the other part
can be done another way. For performance sake which is what I care about
the heavy lifting is done at the data path. the meta data is marginal.
If you want for completeness sake then fine have another flag.

The new app written will need to do its new pmem_memcpy magic any way.
then we are saying "do we need to call fsync() or not?"

I hate it that you postpone that to never because it would be nice for
philosophical sake to not have the app call sync at all. and all these
years suffer the performance penalty. Instead of putting in a 10 liners
patch today that has no risks, and yes forces new apps to keep the ugly
fsync() call, but have the targeted performance today instead of *maybe* never.

my path is a nice intermediate  progression to yours. Yours blocks my needs
indefinitely?

> [1]: 10.4.6.2 Caching of Temporal vs. Non-Temporal Data
> "Some older CPU implementations (e.g., Pentium M) allowed addresses
> being written with a non-temporal store instruction to be updated
> in-place if the memory type was not WC and line was already in the
> cache."
> 
> I wouldn't be surprised if other architectures had similar constraints.
> 

Perhaps you are looking at this from the wrong perspective. Pentium M
can do this because the two cores shared the same cache. But we are talking
about POSIX files semantics. Not CPU memory semantics. Some of our problems
go away.

Or am I missing something out and I'm completely clueless. Please explain
slowly.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
