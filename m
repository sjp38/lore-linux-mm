Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA066B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 02:20:37 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1119032pab.27
        for <linux-mm@kvack.org>; Thu, 29 May 2014 23:20:37 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fo3si4037066pad.223.2014.05.29.23.20.35
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 23:20:36 -0700 (PDT)
Date: Fri, 30 May 2014 15:21:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530062105.GT10092@bbox>
References: <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
 <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
 <20140530002021.GM10092@bbox>
 <CA+55aFxjXf5xLKGFBjUWimn8-=rj0=g3pku9O1MvGSoDUcEQAw@mail.gmail.com>
 <20140530005042.GO10092@bbox>
 <CA+55aFz84toJOqnuphA99c0av1nLzxcxfjiTwhBbxzaNs3J6NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz84toJOqnuphA99c0av1nLzxcxfjiTwhBbxzaNs3J6NQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 06:24:02PM -0700, Linus Torvalds wrote:
> On Thu, May 29, 2014 at 5:50 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>
> >> You could also try Dave's patch, and _not_ do my mm/vmscan.c part.
> >
> > Sure. While I write this, Rusty's test was crached so I will try Dave's patch,
> > them yours except vmscan.c part.
> 
> Looking more at Dave's patch (well, description), I don't think there
> is any way in hell we can ever apply it. If I read it right, it will
> cause all IO that overflows the max request count to go through the
> scheduler to get it flushed. Maybe I misread it, but that's definitely
> not acceptable. Maybe it's not noticeable with a slow rotational
> device, but modern ssd hardware? No way.
> 
> I'd *much* rather slow down the swap side. Not "real IO". So I think
> my mm/vmscan.c patch is preferable (but yes, it might require some
> work to make kswapd do better).
> 
> So you can try Dave's patch just to see what it does for stack depth,
> but other than that it looks unacceptable unless I misread things.
> 
>              Linus

I tested below patch and the result is endless OOM although there are
lots of anon pages and empty space of swap.

I guess __alloc_pages_direct_reclaim couldn't proceed due to anon pages
once VM drop most of file-backed pages, then go to OOM.

---
 mm/backing-dev.c | 25 +++++++++++++++----------
 mm/vmscan.c      |  4 +---
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index ce682f7a4f29..2762b16404bd 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -11,6 +11,7 @@
 #include <linux/writeback.h>
 #include <linux/device.h>
 #include <trace/events/writeback.h>
+#include <linux/blkdev.h>
 
 static atomic_long_t bdi_seq = ATOMIC_LONG_INIT(0);
 
@@ -565,6 +566,18 @@ void set_bdi_congested(struct backing_dev_info *bdi, int sync)
 }
 EXPORT_SYMBOL(set_bdi_congested);
 
+static long congestion_timeout(int sync, long timeout)
+{
+	long ret;
+	DEFINE_WAIT(wait);
+
+	wait_queue_head_t *wqh = &congestion_wqh[sync];
+	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
+	ret = schedule_timeout(timeout);
+	finish_wait(wqh, &wait);
+	return ret;
+}
+
 /**
  * congestion_wait - wait for a backing_dev to become uncongested
  * @sync: SYNC or ASYNC IO
@@ -578,12 +591,8 @@ long congestion_wait(int sync, long timeout)
 {
 	long ret;
 	unsigned long start = jiffies;
-	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
-	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
-	ret = io_schedule_timeout(timeout);
-	finish_wait(wqh, &wait);
+	ret = congestion_timeout(sync,timeout);
 
 	trace_writeback_congestion_wait(jiffies_to_usecs(timeout),
 					jiffies_to_usecs(jiffies - start));
@@ -614,8 +623,6 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 {
 	long ret;
 	unsigned long start = jiffies;
-	DEFINE_WAIT(wait);
-	wait_queue_head_t *wqh = &congestion_wqh[sync];
 
 	/*
 	 * If there is no congestion, or heavy congestion is not being
@@ -635,9 +642,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	}
 
 	/* Sleep until uncongested or a write happens */
-	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
-	ret = io_schedule_timeout(timeout);
-	finish_wait(wqh, &wait);
+	ret = congestion_timeout(sync, timeout);
 
 out:
 	trace_writeback_wait_iff_congested(jiffies_to_usecs(timeout),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a9c74b409681..e4ad7cd1885b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -975,9 +975,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * avoid risk of stack overflow but only writeback
 			 * if many dirty pages have been encountered.
 			 */
-			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() ||
-					 !zone_is_reclaim_dirty(zone))) {
+			if (!current_is_kswapd() || !zone_is_reclaim_dirty(zone)) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
-- 
1.9.2

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
