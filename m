Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85C496B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 05:47:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so2763427wms.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 02:47:34 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id s45si6961900wrc.179.2017.01.12.02.47.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 02:47:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 18301990D8
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:47:33 +0000 (UTC)
Date: Thu, 12 Jan 2017 10:47:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170112104732.jjdjbjrg7uqczttc@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
 <20170109163518.6001-4-mgorman@techsingularity.net>
 <20170111134420.368efb9e@redhat.com>
 <20170111142712.5fd8bea8@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170111142712.5fd8bea8@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Wed, Jan 11, 2017 at 02:27:12PM +0100, Jesper Dangaard Brouer wrote:
> On Wed, 11 Jan 2017 13:44:20 +0100
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > On Mon,  9 Jan 2017 16:35:17 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> >  
> > > The following is results from a page allocator micro-benchmark. Only
> > > order-0 is interesting as higher orders do not use the per-cpu allocator  
> > 
> > Micro-benchmarked with [1] page_bench02:
> >  modprobe page_bench02 page_order=0 run_flags=$((2#010)) loops=$((10**8)); \
> >   rmmod page_bench02 ; dmesg --notime | tail -n 4
> > 
> > Compared to baseline: 213 cycles(tsc) 53.417 ns
> >  - against this     : 184 cycles(tsc) 46.056 ns
> >  - Saving           : -29 cycles
> >  - Very close to expected 27 cycles saving [see below [2]]
> 
> When perf benchmarking I noticed that the "summed" children perf
> overhead from calling alloc_pages_current() is 65.05%. Compared to
> "free-path" of summed 28.28% of calls "under" __free_pages().
> 
> This is caused by CONFIG_NUMA=y, as call path is long with NUMA
> (and other helpers are also non-inlined calls):
> 
>  alloc_pages
>   -> alloc_pages_current
>       -> __alloc_pages_nodemask
>           -> get_page_from_freelist
> 
> Without NUMA the call levels gets compacted by inlining to:
> 
>  __alloc_pages_nodemask
>   -> get_page_from_freelist
> 
> After disabling NUMA, the split between alloc(48.80%) vs. free(42.67%)
> side is more balanced.
> 
> Saving by disabling CONFIG_NUMA of:
>  - CONFIG_NUMA=y : 184 cycles(tsc) 46.056 ns
>  - CONFIG_NUMA=n : 143 cycles(tsc) 35.913 ns
>  - Saving:       :  41 cycles (approx 22%)
> 
> I would conclude, there is room for improvements with CONFIG_NUMA code
> path case. Lets followup on that in a later patch series...
> 

Potentially. The NUMA paths do memory policy work and has more
complexity in the statistics path. It may be possible to side-step some
of it. There were not many safe options when I last looked but that was
a long time ago. Most of the focus has been on the core allocator
itself and not the wrappers around it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
