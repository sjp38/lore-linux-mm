Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 280586B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 17:06:49 -0500 (EST)
Date: Fri, 4 Jan 2013 16:09:15 -0600
From: Cliff Wickman <cpw@sgi.com>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130104220915.GA11735@sgi.com>
References: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com> <20130104213516.GA7650@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130104213516.GA7650@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, avi@redhat.com, hughd@google.com, mgorman@suse.de, linux-mm@kvack.org

On Fri, Jan 04, 2013 at 04:35:17PM -0500, Christoph Hellwig wrote:
> On Fri, Jan 04, 2013 at 09:41:53AM -0600, Cliff Wickman wrote:
> > So we request that these two functions be exported.
> 
> Can you please post the patch that actually uses it in the same series?

The code that needs to use these two functions is an SGI module.  We'd
be happy to open source it, but I think no one else is interested in it.

This is what that patch looks like:

---
 opensource/xvma/xvma/kernel/xvma.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: 121214.rhel7/opensource/xvma/xvma/kernel/xvma.c
===================================================================
--- 121214.rhel7.orig/opensource/xvma/xvma/kernel/xvma.c
+++ 121214.rhel7/opensource/xvma/xvma/kernel/xvma.c
@@ -32,6 +32,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/rculist.h>
 #include <linux/spinlock.h>
+#include <linux/version.h>
 #include <asm/current.h>
 #include "xvma.h"
 static struct rb_root xmm_rb_root = RB_ROOT;
@@ -1248,16 +1249,19 @@ void
 zap_xvma_ptes(struct xvma_struct * xvma, unsigned long start, unsigned long size)
 {
 	struct mm_struct * mm = xvma->xvma_mm;
+	unsigned long end = start + size;
+#if LINUX_VERSION_CODE <= KERNEL_VERSION(3,5,0)
 	struct mmu_notifier * mn;
 	struct hlist_node * n;
-	unsigned long end = start + size;
+	int srcu;
+#endif
 
 	DPRINTK_XMM_XVMA(xvma->xvma_xmm, xvma);
 	if (mm) {
-		int srcu;
 		/* don't remove this - superpages may have no mmu notifier */
         	if (!mm->mmu_notifier_mm)
                 	return;
+#if LINUX_VERSION_CODE <= KERNEL_VERSION(3,5,0)
 		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 			if (mn->ops->invalidate_range_start)
@@ -1268,6 +1272,10 @@ zap_xvma_ptes(struct xvma_struct * xvma,
 				mn->ops->invalidate_range_end(mn, mm, start, end);
 		}
 		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
+#else
+                __mmu_notifier_invalidate_range_start(mm, start, end);
+                __mmu_notifier_invalidate_range_end(mm, start, end);
+#endif
 	} else if (xvma->xvma_xmm->xmm_invalidate_high_range) {
 		xvma->xvma_xmm->xmm_invalidate_high_range(xvma->xvma_xmm, start, end);
 	}
-- 
Cliff Wickman
SGI
cpw@sgi.com
(651) 683-3824

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
