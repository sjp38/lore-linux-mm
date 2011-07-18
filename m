Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 01AA06B00E7
	for <linux-mm@kvack.org>; Sun, 17 Jul 2011 21:15:18 -0400 (EDT)
Date: Mon, 18 Jul 2011 11:14:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 02/14] vmscan: add shrink_slab tracepoints
Message-ID: <20110718011445.GA30254@dastard>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
 <1310098486-6453-3-git-send-email-david@fromorbit.com>
 <20110711095708.GB19354@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110711095708.GB19354@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 11, 2011 at 05:57:08AM -0400, Christoph Hellwig wrote:
> On Fri, Jul 08, 2011 at 02:14:34PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > ??t is impossible to understand what the shrinkers are actually doing
> > without instrumenting the code, so add a some tracepoints to allow
> > insight to be gained.
> > 
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> 
> Looks good.  But wouldn't it be a good idea to give the shrinkers names
> so that we can pretty print those in the trace event?

Incremental patch below.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

vmscan: add shrinker name to shrink_slab tracepoints.

From: Dave Chinner <dchinner@redhat.com>

Allow people to see what shrinker the tracepoints belong to by
outputing the shrinker function name as well as the shrinker
instance.

This results in output like:

mm_shrink_slab_end:   rpcauth_cache_shrinker+0x0 0xffffffff81f9be20 ....
mm_shrink_slab_end:   mb_cache_shrink_fn+0x0 0xffffffff81f2310 ....
mm_shrink_slab_end:   shrink_dqcache_memory+0x0 0xffffffff81f2320 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007ce1330 ....
mm_shrink_slab_end:   nfs_access_cache_shrinker+0x0 0xffffffff81f30aa ....
mm_shrink_slab_end:   gfs2_shrink_glock_memory+0x0 0xffffffff81f59a8 ....
mm_shrink_slab_end:   gfs2_shrink_qd_memory+0x0 0xffffffff81f59cc ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007c3f930 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007be6bb0 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007be8db0 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007c5bb70 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007be8d70 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007b9c270 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007ba44b0 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007b9bbf0 ....
mm_shrink_slab_end:   xfs_buftarg_shrink+0x0 0xffff88007b1ef1d8 ....
mm_shrink_slab_end:   prune_super+0x0 0xffff88007b132f0 ....
mm_shrink_slab_end:   xfs_buftarg_shrink+0x0 0xffff88007bcda258 ....

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/trace/events/vmscan.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 5f3fea4..36851f7 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -190,6 +190,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
+		__field(void *, shrink)
 		__field(long, nr_objects_to_shrink)
 		__field(gfp_t, gfp_flags)
 		__field(unsigned long, pgs_scanned)
@@ -201,6 +202,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_fast_assign(
 		__entry->shr = shr;
+		__entry->shrink = shr->shrink;
 		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
 		__entry->gfp_flags = sc->gfp_mask;
 		__entry->pgs_scanned = pgs_scanned;
@@ -210,7 +212,8 @@ TRACE_EVENT(mm_shrink_slab_start,
 		__entry->total_scan = total_scan;
 	),
 
-	TP_printk("shrinker %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+	TP_printk("%pF %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+		__entry->shrink,
 		__entry->shr,
 		__entry->nr_objects_to_shrink,
 		show_gfp_flags(__entry->gfp_flags),
@@ -229,6 +232,7 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
+		__field(void *, shrink)
 		__field(long, unused_scan)
 		__field(long, new_scan)
 		__field(int, retval)
@@ -237,13 +241,15 @@ TRACE_EVENT(mm_shrink_slab_end,
 
 	TP_fast_assign(
 		__entry->shr = shr;
+		__entry->shrink = shr->shrink;
 		__entry->unused_scan = unused_scan_cnt;
 		__entry->new_scan = new_scan_cnt;
 		__entry->retval = shrinker_retval;
 		__entry->total_scan = new_scan_cnt - unused_scan_cnt;
 	),
 
-	TP_printk("shrinker %p: unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pF %p: unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+		__entry->shrink,
 		__entry->shr,
 		__entry->unused_scan,
 		__entry->new_scan,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
