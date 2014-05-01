Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCB76B0036
	for <linux-mm@kvack.org>; Thu,  1 May 2014 13:07:02 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hm4so1109233wib.17
        for <linux-mm@kvack.org>; Thu, 01 May 2014 10:07:01 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id am1si10896010wjc.201.2014.05.01.10.07.00
        for <linux-mm@kvack.org>;
        Thu, 01 May 2014 10:07:00 -0700 (PDT)
Date: Thu, 1 May 2014 18:06:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Message-ID: <20140501170610.GB28745@arm.com>
References: <1398390340.4283.36.camel@kjgkr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398390340.4283.36.camel@kjgkr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Kim <jaegeuk.kim@samsung.com>
Cc: "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Apr 25, 2014 at 10:45:40AM +0900, Jaegeuk Kim wrote:
> 2. Bug
>  This is one of the results, but all the results indicate
> __radix_tree_preload.
> 
> unreferenced object 0xffff88002ae2a238 (size 576):
> comm "fsstress", pid 25019, jiffies 4295651360 (age 2276.104s)
> hex dump (first 32 bytes):
> 01 00 00 00 81 ff ff ff 00 00 00 00 00 00 00 00  ................
> 40 7d 37 81 ff ff ff ff 50 a2 e2 2a 00 88 ff ff  @}7.....P..*....
> backtrace:
>  [<ffffffff8170e546>] kmemleak_alloc+0x26/0x50
>  [<ffffffff8119feac>] kmem_cache_alloc+0xdc/0x190
>  [<ffffffff81378709>] __radix_tree_preload+0x49/0xc0
>  [<ffffffff813787a1>] radix_tree_maybe_preload+0x21/0x30
>  [<ffffffff8114bbbc>] add_to_page_cache_lru+0x3c/0xc0
>  [<ffffffff8114c778>] grab_cache_page_write_begin+0x98/0xf0
>  [<ffffffffa02d3151>] f2fs_write_begin+0xa1/0x370 [f2fs]
>  [<ffffffff8114af47>] generic_perform_write+0xc7/0x1e0
>  [<ffffffff8114d230>] __generic_file_aio_write+0x1d0/0x400
>  [<ffffffff8114d4c0>] generic_file_aio_write+0x60/0xe0
>  [<ffffffff811b281a>] do_sync_write+0x5a/0x90
>  [<ffffffff811b3575>] vfs_write+0xc5/0x1f0
>  [<ffffffff811b3a92>] SyS_write+0x52/0xb0
>  [<ffffffff81730912>] system_call_fastpath+0x16/0x1b
>  [<ffffffffffffffff>] 0xffffffffffffffff

Do all the backtraces look like the above (coming from
add_to_page_cache_lru)?

There were some changes in lib/radix-tree.c since 3.14, maybe you could
try reverting them and see if the leaks still appear (cc'ing Johannes).
It could also be a false positive.

An issue with debugging such cases is that the preloading is common for
multiple radix trees, so the actual radix_tree_node_alloc() could be on
a different path. You could give the patch below a try to see what
backtrace you get (it updates backtrace in radix_tree_node_alloc()).


diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index a7563ec4ea7b..b772418bf064 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -142,6 +142,7 @@ kmemleak_alloc_percpu	 - notify of a percpu memory block allocation
 kmemleak_free		 - notify of a memory block freeing
 kmemleak_free_part	 - notify of a partial memory block freeing
 kmemleak_free_percpu	 - notify of a percpu memory block freeing
+kmemleak_update_trace	 - update object allocation stack trace
 kmemleak_not_leak	 - mark an object as not a leak
 kmemleak_ignore		 - do not scan or report an object as leak
 kmemleak_scan_area	 - add scan areas inside a memory block
diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 5bb424659c04..057e95971014 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -30,6 +30,7 @@ extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size) __ref;
 extern void kmemleak_free(const void *ptr) __ref;
 extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
 extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
+extern void kmemleak_update_trace(const void *ptr) __ref;
 extern void kmemleak_not_leak(const void *ptr) __ref;
 extern void kmemleak_ignore(const void *ptr) __ref;
 extern void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp) __ref;
@@ -83,6 +84,9 @@ static inline void kmemleak_free_recursive(const void *ptr, unsigned long flags)
 static inline void kmemleak_free_percpu(const void __percpu *ptr)
 {
 }
+static inline void kmemleak_update_trace(const void *ptr)
+{
+}
 static inline void kmemleak_not_leak(const void *ptr)
 {
 }
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 9599aa72d7a0..5297f8e09096 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -27,6 +27,7 @@
 #include <linux/radix-tree.h>
 #include <linux/percpu.h>
 #include <linux/slab.h>
+#include <linux/kmemleak.h>
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/string.h>
@@ -200,6 +201,11 @@ radix_tree_node_alloc(struct radix_tree_root *root)
 			rtp->nodes[rtp->nr - 1] = NULL;
 			rtp->nr--;
 		}
+		/*
+		 * Update the allocation stack trace as this is more useful
+		 * for debugging.
+		 */
+		kmemleak_update_trace(ret);
 	}
 	if (ret == NULL)
 		ret = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 3a36e2b16cba..61a64ed2fbef 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -990,6 +990,40 @@ void __ref kmemleak_free_percpu(const void __percpu *ptr)
 EXPORT_SYMBOL_GPL(kmemleak_free_percpu);
 
 /**
+ * kmemleak_update_trace - update object allocation stack trace
+ * @ptr:	pointer to beginning of the object
+ *
+ * Override the object allocation stack trace for cases where the actual
+ * allocation place is not always useful.
+ */
+void __ref kmemleak_update_trace(const void *ptr)
+{
+	struct kmemleak_object *object;
+	unsigned long flags;
+
+	pr_debug("%s(0x%p)\n", __func__, ptr);
+
+	if (!kmemleak_enabled || IS_ERR_OR_NULL(ptr))
+		return;
+
+	object = find_and_get_object((unsigned long)ptr, 1);
+	if (!object) {
+#ifdef DEBUG
+		kmemleak_warn("Updating stack trace for unknown object at %p\n",
+			      ptr);
+#endif
+		return;
+	}
+
+	spin_lock_irqsave(&object->lock, flags);
+	object->trace_len = __save_stack_trace(object->trace);
+	spin_unlock_irqrestore(&object->lock, flags);
+
+	put_object(object);
+}
+EXPORT_SYMBOL(kmemleak_update_trace);
+
+/**
  * kmemleak_not_leak - mark an allocated object as false positive
  * @ptr:	pointer to beginning of the object
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
