Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id E23A66B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 13:40:57 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id e32so103193510qgf.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 10:40:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z17si25676689qka.125.2016.01.31.10.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jan 2016 10:40:57 -0800 (PST)
Date: Sun, 31 Jan 2016 19:40:48 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [slab] a1fd55538c: WARNING: CPU: 0 PID: 0 at
 kernel/locking/lockdep.c:2601 trace_hardirqs_on_caller()
Message-ID: <20160131194048.6f7add16@redhat.com>
In-Reply-To: <20160131131506.4aad01b5@canb.auug.org.au>
References: <56aa2b47.MwdlkrzZ08oDKqh8%fengguang.wu@intel.com>
	<20160128184749.7bdee246@redhat.com>
	<21684.1454137770@turing-police.cc.vt.edu>
	<20160130184646.6ea9c5f8@redhat.com>
	<20160131131506.4aad01b5@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Valdis.Kletnieks@vt.edu, kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com

On Sun, 31 Jan 2016 13:15:06 +1100
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Jesper,
> 
> On Sat, 30 Jan 2016 18:46:46 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> >
> > Let me know, if the linux-next tree need's an explicit fix?  
> 
> It would be a good idea if you could send a fix against linux-next to
> me as Andrew is currently travelling.

My analysis before was wrong, the fix was much simpler. No need to
revert my FAILSLAB patch.  Just forgot to mask flags with gfp_allowed_mask.

I expect AKPM can pickup these two small fixes to my patches.

Below is a patch for linux-next. 

- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


[PATCH] mm: temporary fix for SLAB in linux-next

From: Jesper Dangaard Brouer <brouer@redhat.com>

This is only for linux-next, until AKPM pickup fixes two patches:
 base url: http://ozlabs.org/~akpm/mmots/broken-out/
 [1] mm-fault-inject-take-over-bootstrap-kmem_cache-check.patch
 [2] slab-use-slab_pre_alloc_hook-in-slab-allocator-shared-with-slub.patch

First fix is for compiling with CONFIG_FAILSLAB. The linux-next commit
needing this fix is 074b6f53c320 ("mm: fault-inject take over
bootstrap kmem_cache check").

Second fix is for correct masking of allowed GFP flags (gfp_allowed_mask),
in SLAB allocator.  This triggered a WARN, by percpu_init_late ->
pcpu_mem_zalloc invoking kzalloc with GFP_KERNEL flags. The linux-next
commit needing this fix is a1fd55538cae ("slab: use
slab_pre_alloc_hook in SLAB allocator shared with SLUB").

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/failslab.c |    1 +
 mm/slab.c     |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/mm/failslab.c b/mm/failslab.c
index 0c5b3f31f310..b0fac98cd938 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -1,5 +1,6 @@
 #include <linux/fault-inject.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include "slab.h"
 
 static struct {
diff --git a/mm/slab.c b/mm/slab.c
index e90d259b3242..ddd974e6b3bb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3190,6 +3190,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	void *ptr;
 	int slab_node = numa_mem_id();
 
+	flags &= gfp_allowed_mask;
 	cachep = slab_pre_alloc_hook(cachep, flags);
 	if (unlikely(!cachep))
 		return NULL;
@@ -3268,6 +3269,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	unsigned long save_flags;
 	void *objp;
 
+	flags &= gfp_allowed_mask;
 	cachep = slab_pre_alloc_hook(cachep, flags);
 	if (unlikely(!cachep))
 		return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
