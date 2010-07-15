Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BEC9D6B02A7
	for <linux-mm@kvack.org>; Thu, 15 Jul 2010 10:55:18 -0400 (EDT)
Date: Thu, 15 Jul 2010 22:55:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/6] writeback: avoid unnecessary calculation of bdi
 dirty thresholds
Message-ID: <20100715145509.GB6511@localhost>
References: <20100711020656.340075560@intel.com>
 <20100711021748.879183413@intel.com>
 <20100712145643.a944c495.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712145643.a944c495.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 05:56:43AM +0800, Andrew Morton wrote:
> On Sun, 11 Jul 2010 10:06:59 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > +void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
> >
> > ...
> >
> > +unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
> > +			       unsigned long dirty)
> 
> It'd be nice to have some documentation for these things.  They're
> non-static, non-obvious and are stuffed to the gills with secret magic
> numbers.

Good suggestion, here is an attempt to document the functions.

Thanks,
Fengguang
---
Subject: add comment to the dirty limit functions
From: Wu Fengguang <fengguang.wu@intel.com>
Date: Thu Jul 15 09:54:25 CST 2010

Document global_dirty_limits() and bdi_dirty_limit().

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-07-15 08:20:32.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-07-15 10:39:41.000000000 +0800
@@ -390,6 +390,15 @@ unsigned long determine_dirtyable_memory
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
+/**
+ * global_dirty_limits - background writeback and dirty throttling thresholds
+ *
+ * Calculate the dirty thresholds based on sysctl parameters
+ * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
+ * - vm.dirty_ratio             or  vm.dirty_bytes
+ * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
+ * runtime tasks.
+ */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
 	unsigned long background;
@@ -424,8 +433,18 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
-			       unsigned long dirty)
+/**
+ * bdi_dirty_limit - current task's share of dirty throttling threshold on @bdi
+ *
+ * Once the global dirty limit is _exceeded_, all dirtiers will be throttled.
+ * To avoid starving fast devices (which can sync dirty pages in short time) or
+ * throttling light dirtiers, we start throttling individual tasks on a per-bdi
+ * basis when _approaching_ the global dirty limit. Relative high limits will
+ * be allocated to fast devices and/or light dirtiers. The bdi's dirty share is
+ * evaluated adapting to its throughput and bounded if the bdi->min_ratio
+ * and/or bdi->max_ratio parameters are set.
+ */
+unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 {
 	u64 bdi_dirty;
 	long numerator, denominator;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
