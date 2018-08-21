Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60D146B1D7B
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 03:22:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id n21-v6so11332370plp.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 00:22:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9-v6si11417625plo.206.2018.08.21.00.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 00:22:05 -0700 (PDT)
Subject: Re: Caching/buffers become useless after some time
References: <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
 <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
 <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz>
 <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz>
 <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
Date: Tue, 21 Aug 2018 09:19:34 +0200
MIME-Version: 1.0
In-Reply-To: <20180821064911.GW29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Marinko Catovic <marinko.catovic@gmail.com>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

On 8/21/18 8:49 AM, Michal Hocko wrote:
> On Tue 21-08-18 02:36:05, Marinko Catovic wrote:
> [...]
>>>> Well, there are some drivers (mostly out-of-tree) which are high order
>>>> hungry. You can try to trace all allocations which with order > 0 and
>>>> see who that might be.
>>>> # mount -t tracefs none /debug/trace/
>>>> # echo stacktrace > /debug/trace/trace_options
>>>> # echo "order>0" > /debug/trace/events/kmem/mm_page_alloc/filter
>>>> # echo 1 > /debug/trace/events/kmem/mm_page_alloc/enable
>>>> # cat /debug/trace/trace_pipe
>>>>
>>>> And later this to disable tracing.
>>>> # echo 0 > /debug/trace/events/kmem/mm_page_alloc/enable
>>>
>>> I just had a major cache-useless situation, with like 100M/8G usage only
>>> and horrible performance. There you go:
>>>
>>> https://nofile.io/f/mmwVedaTFsd
> 
> $ grep mm_page_alloc: trace_pipe | sed 's@.*order=\([0-9]*\) .*gfp_flags=\(.*\)@\1 \2@' | sort | uniq -c
>     428 1 __GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>      10 1 __GFP_HIGH|__GFP_ATOMIC|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>       6 1 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>    3061 1 GFP_KERNEL_ACCOUNT|__GFP_ZERO
>    8672 1 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_ACCOUNT
>    2547 1 __GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_THISNODE
>       4 2 __GFP_HIGH|__GFP_ATOMIC|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>       5 2 __GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_COMP|__GFP_THISNODE
>   20030 2 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_ACCOUNT
>    1528 3 GFP_ATOMIC|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC
>    2476 3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP
>    6512 3 GFP_NOWAIT|__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_ACCOUNT
>     277 9 GFP_TRANSHUGE|__GFP_THISNODE
> 
> This only covers ~90s of the allocator activity. Most of those requests
> are not troggering any reclaim (GFP_NOWAIT/ATOMIC). Vlastimil will
> know better but this might mean that we are not envoking kcompactd
> enough.

Earlier vmstat data showed that it's invoked but responsible for less
than 1% of compaction activity.

> But considering that we have suspected that an overly eager
> reclaim triggers the page cache reduction I am not really sure I see the
> above to match that theory.

Yeah, the GFP_NOWAIT/GFP_ATOMIC above shouldn't be responsible for such
overreclaim?

> Btw. I was probably not specific enough. This data should be collected
> _during_ the time when the page cache is disappearing. I suspect you
> have started collecting after the fact.

It might be also interesting to do in the problematic state, instead of
dropping caches:

- save snapshot of /proc/vmstat and /proc/pagetypeinfo
- echo 1 > /proc/sys/vm/compact_memory
- save new snapshot of /proc/vmstat and /proc/pagetypeinfo

That would show if compaction is able to help at all.

> Btw. vast majority of order-3 requests come from the network layer. Are
> you using a large MTU (jumbo packets)?
> 
