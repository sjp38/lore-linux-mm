Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED3DE6B0005
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:43:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1-v6so10717388eds.15
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:43:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6si3970337edw.439.2018.10.31.06.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:43:19 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
From: Vlastimil Babka <vbabka@suse.cz>
References: <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz>
 <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
 <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz>
 <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
 <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
 <CADF2uSpiD9t-dF6bp-3-EnqWK9BBEwrfp69=_tcxUOLk_DytUA@mail.gmail.com>
 <6e3a9434-32f2-0388-e0c7-2bd1c2ebc8b1@suse.cz>
 <20181030152632.GG32673@dhcp22.suse.cz>
 <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
 <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
Message-ID: <b9dd0c10-d87b-94a8-0234-7c6c0264d672@suse.cz>
Date: Wed, 31 Oct 2018 14:40:30 +0100
MIME-Version: 1.0
In-Reply-To: <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On 10/30/18 6:00 PM, Vlastimil Babka wrote:
> On 10/30/18 5:08 PM, Marinko Catovic wrote:
>>> One notable thing here is that there shouldn't be any reason to do the
>>> direct reclaim when kswapd itself doesn't do anything. It could be
>>> either blocked on something but I find it quite surprising to see it in
>>> that state for the whole 1500s time period or we are simply not low on
>>> free memory at all. That would point towards compaction triggered memory
>>> reclaim which account as the direct reclaim as well. The direct
>>> compaction triggered more than once a second in average. We shouldn't
>>> really reclaim unless we are low on memory but repeatedly failing
>>> compaction could just add up and reclaim a lot in the end. There seem to
>>> be quite a lot of low order request as per your trace buffer
> 
> I realized that the fact that slabs grew so large might be very
> relevant. It means a lot of unmovable pages, and while they are slowly
> being freed, the remaining are scattered all over the memory, making it
> impossible to successfully compact, until the slabs are almost
> *completely* freed. It's in fact the theoretical worst case scenario for
> compaction and fragmentation avoidance. Next time it would be nice to
> also gather /proc/pagetypeinfo, and /proc/slabinfo to see what grew so
> much there (probably dentries and inodes).

I went through the whole thread again as it was spread over months, and
finally connected some dots. In one mail you said:

> There is one thing I forgot to mention: the hosts perform find and du (I mean the commands, finding files and disk usage)
> on the HDDs every night, starting from 00:20 AM up until in the morning 07:45 AM, for maintenance and stats.

The timespan above roughly matches the phase where reclaimable slab grow
(samples 2000-6000 over 5 seconds is roughly 5.5 hours). The find will
fetch a lots of metadata in dentries, inodes etc. which are part of
reclaimable slabs. In other mail you posted a slabinfo
https://pastebin.com/81QAFgke in the phase where it's already being
slowly reclaimed, but still occupies 6.5GB, and mostly it's
ext4_inode_cache, and dentry cache (also very much internally fragmented).
In another mail I suggest that maybe fragmentation happened because the
slab filled up much more at some point, and I think we now have that
solidly confirmed from the vmstat plots.
I think one workaround is for you to perform echo 2 > drop_caches (not
3) right after the find/du maintenance finishes. At that point you don't
have too much page cache anyway, since the slabs have pushed it out.
It's also overnight so there are not many users yet?
Alternatively the find/du could run in a memcg limiting its slab use.
Michal would know the details.

Long term we should do something about these slab objects that are only
used briefly (once?) so there's no point in caching them and letting the
cache grow like this.

> The question is why the problems happened some time later after the
> unmovable pollution. The trace showed me that the structure of
> allocations wrt order+flags as Michal breaks them down below, is not
> significanly different in the last phase than in the whole trace.
> Possibly the state of memory gradually changed so that the various
> heuristics (fragindex, pageblock skip bits etc) resulted in compaction
> being tried more than initially, eventually hitting a very bad corner case.

This is still an open question. Why do we overreclaim that much? If we
can trust one of the older pagetypeinfo snapshots
https://pastebin.com/6QWEZagL then of those below, only the THP
allocations should need reclaim/compaction. Maybe the order-7 ones as
well, but there are just a few of those and they are __GFP_NORETRY.

Maybe enable also tracing events (in addition to page alloc)
compaction/mm_compaction_try_to_compact_pages and
compaction/mm_compaction_suitable?

>>> We can safely rule out NOWAIT and ATOMIC because those do not reclaim.
>>> That leaves us with
>>>    5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>>     121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>>      22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>>  395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
> 
> I suspect there are lots of short-lived processes, so these are probably
> rapidly recycled and not causing compaction. It also seems to be pgd
> allocation (2 pages due to PTI) not kernel stack?
> 
>>>    1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>>    3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>>      10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>>     114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>>   67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE
> 
> I would again suspect those. IIRC we already confirmed earlier that THP
> defrag setting is madvise or madvise+defer, and there are
> madvise(MADV_HUGEPAGE) using processes? Did you ever try changing defrag
> to plain 'defer'?
> 
>>>
>>> by large the kernel stack allocations are in lead. You can put some
>>> relief by enabling CONFIG_VMAP_STACK. There is alos a notable number of
>>> THP pages allocations. Just curious are you running on a NUMA machine?
>>> If yes [1] might be relevant. Other than that nothing really jumped at
>>> me.
> 
> 
>> thanks a lot Vlastimil!
> 
> And Michal :)
> 
>> I would not really know whether this is a NUMA, it is some usual
>> server running with a i7-8700
>> and ECC RAM. How would I find out?
> 
> Please provide /proc/zoneinfo and we'll see.
> 
>> So I should do CONFIG_VMAP_STACK=y and try that..?
> 
> I suspect you already have it.
> 
