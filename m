Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8409000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 13:27:40 -0400 (EDT)
Date: Wed, 28 Sep 2011 18:23:43 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: Question about memory leak detector giving false positive
 report for net/core/flow.c
Message-ID: <20110928172342.GH23559@e102109-lin.cambridge.arm.com>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
 <1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
 <1317066395.2796.11.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1317066395.2796.11.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Huajun Li <huajun.li.lee@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>

On Mon, Sep 26, 2011 at 08:46:35PM +0100, Eric Dumazet wrote:
> Le lundi 26 septembre 2011 a 17:50 +0100, Catalin Marinas a ecrit :
> > kmemleak_not_leak() definitely not the write answer. The alloc_percpu()
> > call does not have any kmemleak_alloc() callback, so it doesn't scan
> > them.
> > 
> > Huajun, could you please try the patch below:
...
> Hmm, you need to call kmemleak_alloc() for each chunk allocated per
> possible cpu.

I tried this but it's tricky. The problem is that the percpu pointer
returned by alloc_percpu() does not directly point to the per-cpu chunks
and kmemleak would report most percpu allocations as leaks. So far the
workaround is to simply mark the alloc_percpu() objects as never leaking
and at least we avoid false positives in other areas. See the patch
below (note that you have to increase the CONFIG_KMEMLEAK_EARLY_LOG_SIZE
as there are many alloc_percpu() calls before kmemleak is fully
initialised):

------------8<------------------------------------

kmemleak: Handle percpu memory allocation

From: Catalin Marinas <catalin.marinas@arm.com>

This patch adds kmemleak callbacks from the percpu allocator, reducing a
number of false positives caused by kmemleak not scanning such memory
blocks.

Reported-by: Huajun Li <huajun.li.lee@gmail.com>
Cc: Tejun Heo <tj@kernel.org>,
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/percpu.c |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index bf80e55..ece9f85 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -67,6 +67,7 @@
 #include <linux/spinlock.h>
 #include <linux/vmalloc.h>
 #include <linux/workqueue.h>
+#include <linux/kmemleak.h>
 
 #include <asm/cacheflush.h>
 #include <asm/sections.h>
@@ -709,6 +710,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved)
 	const char *err;
 	int slot, off, new_alloc;
 	unsigned long flags;
+	void __percpu *ptr;
+	unsigned int cpu;
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
 		WARN(true, "illegal size (%zu) or align (%zu) for "
@@ -801,7 +804,16 @@ area_found:
 	mutex_unlock(&pcpu_alloc_mutex);
 
 	/* return address relative to base address */
-	return __addr_to_pcpu_ptr(chunk->base_addr + off);
+	ptr = __addr_to_pcpu_ptr(chunk->base_addr + off);
+
+	/*
+	 * Percpu allocations are currently reported as leaks (kmemleak false
+	 * positives). To avoid this, just set min_count to 0.
+	 */
+	for_each_possible_cpu(cpu)
+		kmemleak_alloc(per_cpu_ptr(ptr, cpu), size, 0, GFP_KERNEL);
+
+	return ptr;
 
 fail_unlock:
 	spin_unlock_irqrestore(&pcpu_lock, flags);
@@ -911,10 +923,14 @@ void free_percpu(void __percpu *ptr)
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
 	int off;
+	unsigned int cpu;
 
 	if (!ptr)
 		return;
 
+	for_each_possible_cpu(cpu)
+		kmemleak_free(per_cpu_ptr(ptr, cpu));
+
 	addr = __pcpu_ptr_to_addr(ptr);
 
 	spin_lock_irqsave(&pcpu_lock, flags);
@@ -1619,6 +1635,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 			rc = -ENOMEM;
 			goto out_free_areas;
 		}
+		/* kmemleak tracks the percpu allocations separately */
+		kmemleak_free(ptr);
 		areas[group] = ptr;
 
 		base = min(ptr, base);
@@ -1733,6 +1751,8 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 					   "for cpu%u\n", psize_str, cpu);
 				goto enomem;
 			}
+			/* kmemleak tracks the percpu allocations separately */
+			kmemleak_free(ptr);
 			pages[j++] = virt_to_page(ptr);
 		}
 

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
