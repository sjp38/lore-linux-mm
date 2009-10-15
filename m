Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B39D06B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 19:13:10 -0400 (EDT)
Date: Thu, 15 Oct 2009 16:13:08 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
In-Reply-To: <alpine.DEB.2.00.0910151507260.2882@kernalhack.brc.ubc.ca>
Message-ID: <alpine.DEB.2.00.0910151607160.10149@kernalhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca> <20090903140602.e0169ffc.akpm@linux-foundation.org> <alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca> <20090903154704.da62dd76.akpm@linux-foundation.org>
 <alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca> <20090904165305.c19429ce.akpm@linux-foundation.org> <20090908132100.GA17446@csn.ul.ie> <alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca> <20090909082759.7144aaa5.minchan.kim@barrios-desktop>
 <alpine.DEB.2.00.0910151507260.2882@kernalhack.brc.ubc.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 15 Oct 2009, Vincent Li wrote:

> 
> 
> On Wed, 9 Sep 2009, Minchan Kim wrote:
> 
> > 
> > You're right. the experiment said so.
> > But hackbench performs fork-bomb test
> > so that it makes corner case, I think.
> > Such a case shows the your patch is good.
> > But that case is rare.
> > 
> > The thing remained is to test your patch
> > in normal case. so you need to test hackbench with
> > smaller parameters to make for the number of task
> > to fit your memory size but does happen reclaim.
> > 
> 
> Hi Kim,
> 
> I finally got some time to rerun the perf test and press Alt + SysRq + M the
> same time  on a freshly start computer.
> 
> I run the perf with repeat only 1 instead of 5, so run hackbench with number
> 100 does not cause my system stall, the system  is still quite responsive
> during the test, I assume that is normal situation, not fork bomb case?
> 
> In general, it seems nr_taken_zero does happen in normal page reclaim
> situation, but it is also true that nr_taken_zero does not happen from time to
> time.
> 

Oh, The nr_taken_zero/nonzero event tracing test patch is based on 
2.6.32-rc4 as below:

---
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index eaf46bd..a94daa0 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -388,6 +388,42 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->alloc_migratetype == __entry->fallback_migratetype)
 );
 
+TRACE_EVENT(mm_vmscan_nr_taken_zero,
+
+	TP_PROTO(unsigned long nr_taken),
+
+	TP_ARGS(nr_taken),
+
+	TP_STRUCT__entry(
+		__field(        unsigned long,          nr_taken        )
+	),
+
+	TP_fast_assign(
+		__entry->nr_taken       = nr_taken;
+	),
+
+	TP_printk("nr_taken=%lu",
+		__entry->nr_taken)
+);
+
+TRACE_EVENT(mm_vmscan_nr_taken_nonzero,
+
+	TP_PROTO(unsigned long nr_taken),
+
+	TP_ARGS(nr_taken),
+
+	TP_STRUCT__entry(
+		__field(        unsigned long,          nr_taken        )
+	),
+
+	TP_fast_assign(
+		__entry->nr_taken       = nr_taken;
+	),
+
+	TP_printk("nr_taken=%lu",
+		__entry->nr_taken)
+);
+
 #endif /* _TRACE_KMEM_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 64e4388..36e7fe2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1326,6 +1326,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+
+	if (nr_taken == 0)
+		trace_mm_vmscan_nr_taken_zero(nr_taken);
+	else
+		trace_mm_vmscan_nr_taken_nonzero(nr_taken);
+
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else


Regards,

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
