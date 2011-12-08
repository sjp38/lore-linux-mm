Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A48426B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 04:13:44 -0500 (EST)
Date: Thu, 8 Dec 2011 17:03:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: show writeback reason with __print_symbolic
Message-ID: <20111208090338.GA20582@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.797240894@intel.com>
 <20111206153025.GA18974@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206153025.GA18974@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Curt Wohlgemuth <curtw@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> > +		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
> > +			ra_pattern_names[__entry->pattern],
> 
> Instead of doing a manual array lookup please use __print_symbolic so
> that users of the binary interface (like trace-cmd) also get the
> right output.

FYI, here is the related fix on writeback traces.

---
This makes the traces trace-cmd friendly, at the cost of a bit code duplication.

CC: Curt Wohlgemuth <curtw@google.com>
CC: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/writeback.h |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

--- linux-next.orig/include/trace/events/writeback.h	2011-12-08 16:44:38.000000000 +0800
+++ linux-next/include/trace/events/writeback.h	2011-12-08 16:53:41.000000000 +0800
@@ -21,6 +21,18 @@
 		{I_REFERENCED,		"I_REFERENCED"}		\
 	)
 
+#define show_work_reason(reason)					\
+	__print_symbolic(reason,					\
+		{WB_REASON_BACKGROUND,		"background"},		\
+		{WB_REASON_TRY_TO_FREE_PAGES,	"try_to_free_pages"},	\
+		{WB_REASON_SYNC,		"sync"},		\
+		{WB_REASON_PERIODIC,		"periodic"},		\
+		{WB_REASON_LAPTOP_TIMER,	"laptop_timer"},	\
+		{WB_REASON_FREE_MORE_MEM,	"free_more_memory"},	\
+		{WB_REASON_FS_FREE_SPACE,	"fs_free_space"},	\
+		{WB_REASON_FORKER_THREAD,	"forker_thread"}	\
+	)
+
 struct wb_writeback_work;
 
 DECLARE_EVENT_CLASS(writeback_work_class,
@@ -55,7 +67,7 @@ DECLARE_EVENT_CLASS(writeback_work_class
 		  __entry->for_kupdate,
 		  __entry->range_cyclic,
 		  __entry->for_background,
-		  wb_reason_name[__entry->reason]
+		  show_work_reason(__entry->reason)
 	)
 );
 #define DEFINE_WRITEBACK_WORK_EVENT(name) \
@@ -184,7 +196,8 @@ TRACE_EVENT(writeback_queue_io,
 		__entry->older,	/* older_than_this in jiffies */
 		__entry->age,	/* older_than_this in relative milliseconds */
 		__entry->moved,
-		wb_reason_name[__entry->reason])
+		show_work_reason(__entry->reason)
+	)
 );
 
 TRACE_EVENT(global_dirty_state,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
