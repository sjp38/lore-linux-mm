Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A69A06B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:15:43 -0500 (EST)
Received: by pacej9 with SMTP id ej9so183964838pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:15:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id sa8si18236092pbb.131.2015.11.23.00.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 00:15:42 -0800 (PST)
Date: Mon, 23 Nov 2015 17:16:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: hugepage compaction causes performance drop
Message-ID: <20151123081601.GA29397@js1304-P5Q-DELUXE>
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
 <564DCEA6.3000802@suse.cz>
 <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com>
 <564EF0B6.10508@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564EF0B6.10508@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Aaron Lu <aaron.lu@intel.com>, linux-mm@kvack.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Fri, Nov 20, 2015 at 11:06:46AM +0100, Vlastimil Babka wrote:
> On 11/20/2015 10:33 AM, Aaron Lu wrote:
> >On 11/20/2015 04:55 PM, Aaron Lu wrote:
> >>On 11/19/2015 09:29 PM, Vlastimil Babka wrote:
> >>>+CC Andrea, David, Joonsoo
> >>>
> >>>On 11/19/2015 10:29 AM, Aaron Lu wrote:
> >>>>The vmstat and perf-profile are also attached, please let me know if you
> >>>>need any more information, thanks.
> >>>
> >>>Output from vmstat (the tool) isn't much useful here, a periodic "cat
> >>>/proc/vmstat" would be much better.
> >>
> >>No problem.
> >>
> >>>The perf profiles are somewhat weirdly sorted by children cost (?), but
> >>>I noticed a very high cost (46%) in pageblock_pfn_to_page(). This could
> >>>be due to a very large but sparsely populated zone. Could you provide
> >>>/proc/zoneinfo?
> >>
> >>Is a one time /proc/zoneinfo enough or also a periodic one?
> >
> >Please see attached, note that this is a new run so the perf profile is
> >a little different.
> >
> >Thanks,
> >Aaron
> 
> Thanks.
> 
> DMA32 is a bit sparse:
> 
> Node 0, zone    DMA32
>   pages free     62829
>         min      327
>         low      408
>         high     490
>         scanned  0
>         spanned  1044480
>         present  495951
>         managed  479559
> 
> Since the other zones are much larger, probably this is not the
> culprit. But tracepoints should tell us more. I have a theory that
> updating free scanner's cached pfn doesn't happen if it aborts due
> to need_resched() during isolate_freepages(), before hitting a valid
> pageblock, if the zone has a large hole in it. But zoneinfo doesn't
> tell us if the large difference between "spanned" and
> "present"/"managed" is due to a large hole, or many smaller holes...
> 
> compact_migrate_scanned 1982396
> compact_free_scanned 40576943
> compact_isolated 2096602
> compact_stall 9070
> compact_fail 6025
> compact_success 3045
> 
> So it's struggling to find free pages, no wonder about that. I'm

Numbers looks fine to me. I guess this performance degradation is
caused by COMPACT_CLUSTER_MAX change (from 32 to 256). THP allocation
is async so should be aborted quickly. But, after isolating 256
migratable pages, it can't be aborted and will finish 256 pages
migration (at least, current implementation).

Aaron, please test again with setting COMPACT_CLUSTER_MAX to 32
(in swap.h)?

And, please attach always-always's vmstat numbers, too.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
