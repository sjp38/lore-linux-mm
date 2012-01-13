Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 389326B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 22:50:48 -0500 (EST)
Received: by vbnl22 with SMTP id l22so1156742vbn.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 19:50:47 -0800 (PST)
Date: Fri, 13 Jan 2012 12:50:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
Message-ID: <20120113035037.GA10924@barrios-desktop.redhat.com>
References: <1326347222-9980-1-git-send-email-b32955@freescale.com>
 <20120112080311.GA30634@barrios-desktop.redhat.com>
 <20120112114835.GI4118@suse.de>
 <20120113005026.GA2614@barrios-desktop.redhat.com>
 <4F0F987E.1080001@freescale.com>
 <20120113031221.GA6473@barrios-desktop>
 <4F0FA593.6010903@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F0FA593.6010903@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org

On Fri, Jan 13, 2012 at 11:31:31AM +0800, Huang Shijie wrote:
> 
> >On Fri, Jan 13, 2012 at 10:35:42AM +0800, Huang Shijie wrote:
> >>Hi,
> >>>I think simple patch is returning "return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;"
> >>>It's very clear and readable, I think.
> >>>In this patch, what's the problem you think?
> >>>
> >>sorry for the wrong thread, please read the following thread:
> >>http://marc.info/?l=linux-mm&m=132532266130861&w=2
> >Huang, Thanks for notice that thread.
> >I read and if I understand correctly, the point is that Mel want to see tracepoint
> >"trace_mm_compaction_migratepages" and account "count_vm_event(COMPACTBLOCKS);"
> >My patch does accounting COMPACTBLOCKS so it's not a problem.
> Your patch also accounts the COMPACTBLOCKS In the ISOLATE_NONE and
> ISOLATE_ABOART when :
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>     /* Do not cross the free scanner or scan within a memory hole */
>     if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
>         cc->migrate_pfn = end_pfn;
>         return ISOLATE_NONE;
>     }
> 
>     /*
>      * Ensure that there are not too many pages isolated from the LRU
>      * list by either parallel reclaimers or compaction. If there are,
>      * delay for some time until fewer pages are isolated
>      */
>     while (unlikely(too_many_isolated(zone))) {
>         /* async migration should just abort */
>         if (!cc->sync)
>             return ISOLATE_ABORT;
> 
>         congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
>         if (fatal_signal_pending(current))
>             return ISOLATE_ABORT;
>     }
> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 
> this not make sense.
> >The problem is my patch doesn't emit trace of "trace_mm_compaction_migratepages".
> >But doesn't it matter? When we doesn't isolate any page at all, both argument in
> >trace_mm_compaction_migratepages are always zero. Is it meaningful tracepoint?
> >Do we really want it?
> >
> IMHO, yes.
> 
> For it _DOES_  scan one PAGEBLOCK even we can not get any page from
> this pageblock.
> it should trace the scan even the parameters are both zero.

Okay. If you want it really, How about this?
Why I insist on is I don't want to change ISOLATE_NONE's semantic.
It's very clear and readable.
We should change code itself instead of semantic of ISOLATE_NONE.

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
        trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-       return ISOLATE_SUCCESS;
+       return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
 /*
@@ -547,6 +547,12 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
                        ret = COMPACT_PARTIAL;
                        goto out;
                case ISOLATE_NONE:
+                       /*
+                        * If we can't isolate pages at all, we want to
+                        * trace, still.
+                        */
+                       count_vm_event(COMPACTBLOCKS);
+                       trace_mm_compaction_migratepages(0, 0);
                        continue;
                case ISOLATE_SUCCESS:
                        ;



> 
> Huang Shijie
> >>Best Regards
> >>Huang Shijie
> >>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
