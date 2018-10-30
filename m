Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 135036B02AB
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 13:03:17 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t3-v6so9262957pgp.0
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 10:03:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 37-v6si24177015pgp.211.2018.10.30.10.03.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 10:03:15 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
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
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <98305976-612f-cf6d-1377-2f9f045710a9@suse.cz>
Date: Tue, 30 Oct 2018 18:00:23 +0100
MIME-Version: 1.0
In-Reply-To: <CADF2uSr2V+6MosROF7dJjs_Pn_hR8u6Z+5bKPqXYUUKx=5knDg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Christopher Lameter <cl@linux.com>

On 10/30/18 5:08 PM, Marinko Catovic wrote:
>> One notable thing here is that there shouldn't be any reason to do the
>> direct reclaim when kswapd itself doesn't do anything. It could be
>> either blocked on something but I find it quite surprising to see it in
>> that state for the whole 1500s time period or we are simply not low on
>> free memory at all. That would point towards compaction triggered memory
>> reclaim which account as the direct reclaim as well. The direct
>> compaction triggered more than once a second in average. We shouldn't
>> really reclaim unless we are low on memory but repeatedly failing
>> compaction could just add up and reclaim a lot in the end. There seem to
>> be quite a lot of low order request as per your trace buffer

I realized that the fact that slabs grew so large might be very
relevant. It means a lot of unmovable pages, and while they are slowly
being freed, the remaining are scattered all over the memory, making it
impossible to successfully compact, until the slabs are almost
*completely* freed. It's in fact the theoretical worst case scenario for
compaction and fragmentation avoidance. Next time it would be nice to
also gather /proc/pagetypeinfo, and /proc/slabinfo to see what grew so
much there (probably dentries and inodes).

The question is why the problems happened some time later after the
unmovable pollution. The trace showed me that the structure of
allocations wrt order+flags as Michal breaks them down below, is not
significanly different in the last phase than in the whole trace.
Possibly the state of memory gradually changed so that the various
heuristics (fragindex, pageblock skip bits etc) resulted in compaction
being tried more than initially, eventually hitting a very bad corner case.

>> $ grep order trace-last-phase | sed 's@.*\(order=[0-9]*\).*gfp_flags=\(.*\)@\1 \2@' | sort | uniq -c
>>    1238 order=1 __GFP_HIGH|__GFP_ATOMIC|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>    5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>     121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>      22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>  395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
>>  783055 order=1 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>>    1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>    3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>  797255 order=2 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>>   93524 order=3 GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
>>  498148 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_ACCOUNT
>>  243563 order=3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
>>      10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>     114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>   67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE
>>
>> We can safely rule out NOWAIT and ATOMIC because those do not reclaim.
>> That leaves us with
>>    5812 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>     121 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>      22 order=1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>  395910 order=1 GFP_KERNEL_ACCOUNT|__GFP_ZERO

I suspect there are lots of short-lived processes, so these are probably
rapidly recycled and not causing compaction. It also seems to be pgd
allocation (2 pages due to PTI) not kernel stack?

>>    1060 order=1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>>    3278 order=2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>>      10 order=4 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>     114 order=7 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_THISNODE
>>   67621 order=9 GFP_TRANSHUGE|__GFP_THISNODE

I would again suspect those. IIRC we already confirmed earlier that THP
defrag setting is madvise or madvise+defer, and there are
madvise(MADV_HUGEPAGE) using processes? Did you ever try changing defrag
to plain 'defer'?

>>
>> by large the kernel stack allocations are in lead. You can put some
>> relief by enabling CONFIG_VMAP_STACK. There is alos a notable number of
>> THP pages allocations. Just curious are you running on a NUMA machine?
>> If yes [1] might be relevant. Other than that nothing really jumped at
>> me.


> thanks a lot Vlastimil!

And Michal :)

> I would not really know whether this is a NUMA, it is some usual
> server running with a i7-8700
> and ECC RAM. How would I find out?

Please provide /proc/zoneinfo and we'll see.

> So I should do CONFIG_VMAP_STACK=y and try that..?

I suspect you already have it.
