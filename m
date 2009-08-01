Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 977B36B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 22:02:41 -0400 (EDT)
Date: Sat, 1 Aug 2009 10:02:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090801020228.GA6542@localhost>
References: <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com> <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com> <20090729114322.GA9335@localhost> <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com> <20090730010630.GA7326@localhost> <33307c790907291812j40146a96tc2e9c5e097a33615@mail.gmail.com> <20090730015754.GC7326@localhost> <33307c790907291959r47b1bd3ap7cfa06fd5154aaad@mail.gmail.com> <20090730040803.GA20652@localhost> <33307c790907301255j136e003dtac0e4ba2032e890e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="45Z9DzgjV8m4Oswq"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <33307c790907301255j136e003dtac0e4ba2032e890e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Fri, Jul 31, 2009 at 03:55:44AM +0800, Martin Bligh wrote:
> > Note that this is a simple fix that may have suboptimal write performance.
> > Here is an old reasoning:
> >
> > A  A  A  A http://lkml.org/lkml/2009/3/28/235
> 
> The other thing I've been experimenting with is to disable the per-page
> check in write_cache_pages, ie:
> 
>                         if (wbc->nonblocking && bdi_write_congested(bdi)) {
>                                 wb_stats_inc(WB_STATS_WCP_SECTION_CONG);
>                                 wbc->encountered_congestion = 1;
>                                 /* done = 1; */
> 
> This treats the congestion limits as soft, but encourages us to write
> back in larger, more efficient chunks. If that's not going to scare
> people unduly, I can submit that as well.

This risks hitting the hard limit (nr_requests), and block everyone,
including the ones with higher priority (ie. kswapd).

On the other hand, the simple fix in previous mails won't necessarily
act too sub-optimal. It's only a potential one. There is a window of
(1/16)*(nr_requests)*request_size (= 128*256KB/16 = 4MB) between
congestion-on and congestion-off states. So for the best we can inject
a big 4MB chunk into the async write queue once it becomes uncongested.

I have a writeback debug patch that can help find out how
that works out in your real world workloads (by monitoring
nr_to_write). You can also try doubling the ratio (1/16) in
blk_queue_congestion_threshold(), to see how an increased
congestion-on-off window may help.

Thanks,
Fengguang

--45Z9DzgjV8m4Oswq
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="writeback-debug-2.6.31.patch"

 mm/page-writeback.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

--- sound-2.6.orig/mm/page-writeback.c
+++ sound-2.6/mm/page-writeback.c
@@ -116,6 +116,33 @@ EXPORT_SYMBOL(laptop_mode);
 
 /* End of sysctl-exported parameters */
 
+#define writeback_debug_report(n, wbc) do {                               \
+	__writeback_debug_report(n, wbc, __FILE__, __LINE__, __FUNCTION__); \
+} while (0)
+
+void print_writeback_control(struct writeback_control *wbc)
+{
+	printk(KERN_DEBUG
+			"global dirty %lu writeback %lu nfs %lu "
+			"flags %c%c towrite %ld skipped %ld\n",
+			global_page_state(NR_FILE_DIRTY),
+			global_page_state(NR_WRITEBACK),
+			global_page_state(NR_UNSTABLE_NFS),
+			wbc->encountered_congestion ? 'C':'_',
+			wbc->more_io ? 'M':'_',
+			wbc->nr_to_write,
+			wbc->pages_skipped);
+}
+
+void __writeback_debug_report(long n, struct writeback_control *wbc,
+		const char *file, int line, const char *func)
+{
+	printk(KERN_DEBUG "%s %d %s: %s(%d) %ld\n",
+			file, line, func,
+			current->comm, current->pid,
+			n);
+	print_writeback_control(wbc);
+}
 
 static void background_writeout(unsigned long _min_pages);
 
@@ -550,6 +577,7 @@ static void balance_dirty_pages(struct a
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
+			writeback_debug_report(pages_written, &wbc);
 		}
 
 		/*
@@ -576,6 +604,7 @@ static void balance_dirty_pages(struct a
 			break;		/* We've done our duty */
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		writeback_debug_report(-pages_written, &wbc);
 	}
 
 	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
@@ -670,6 +699,11 @@ void throttle_vm_writeout(gfp_t gfp_mask
 			global_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
+		printk(KERN_DEBUG "throttle_vm_writeout: "
+				"congestion_wait on %lu+%lu > %lu\n",
+				global_page_state(NR_UNSTABLE_NFS),
+				global_page_state(NR_WRITEBACK),
+				dirty_thresh);
 
 		/*
 		 * The caller might hold locks which can prevent IO completion
@@ -719,7 +753,9 @@ static void background_writeout(unsigned
 			else
 				break;
 		}
+		writeback_debug_report(min_pages, &wbc);
 	}
+	writeback_debug_report(min_pages, &wbc);
 }
 
 /*
@@ -792,7 +828,9 @@ static void wb_kupdate(unsigned long arg
 				break;	/* All the old data is written */
 		}
 		nr_to_write -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		writeback_debug_report(nr_to_write, &wbc);
 	}
+	writeback_debug_report(nr_to_write, &wbc);
 	if (time_before(next_jif, jiffies + HZ))
 		next_jif = jiffies + HZ;
 	if (dirty_writeback_interval)

--45Z9DzgjV8m4Oswq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
