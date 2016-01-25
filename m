Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id D21BB828DF
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:55:59 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id o11so113031329qge.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:55:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f124si25248218qkb.19.2016.01.25.08.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:55:59 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [RFC][PATCH 1/3] mm/debug-pagealloc.c: Split out page poisoning from debug page_alloc
Date: Mon, 25 Jan 2016 08:55:51 -0800
Message-Id: <1453740953-18109-2-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


For architectures that do not have debug page_alloc
(!ARCH_SUPPORTS_DEBUG_PAGEALLOC), page poisoning is used instead.
Even architectures that do have DEBUG_PAGEALLOC may want to take advantage of
the poisoning feature. Separate out page poisoning into a separate file. This
does not change the default behavior for !ARCH_SUPPORTS_DEBUG_PAGEALLOC.

Credit to Mathias Krause and grsecurity for original work

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 Documentation/kernel-parameters.txt |   5 ++
 include/linux/mm.h                  |  10 +++
 mm/Makefile                         |   5 +-
 mm/debug-pagealloc.c                | 121 +-----------------------------
 mm/page_poison.c                    | 144 ++++++++++++++++++++++++++++++++++++
 5 files changed, 164 insertions(+), 121 deletions(-)
 create mode 100644 mm/page_poison.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index cfb2c0f..343a4f1 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2681,6 +2681,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			we can turn it on.
 			on: enable the feature
 
+	page_poison=	[KNL] Boot-time parameter changing the state of
+			poisoning on the buddy allocator.
+			off: turn off poisoning
+			on: turn on poisoning
+
 	panic=		[KNL] Kernel behaviour on panic: delay <timeout>
 			timeout > 0: seconds before rebooting
 			timeout = 0: wait forever
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1cd22f..25551c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2174,6 +2174,16 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 			       unsigned long size, pte_fn_t fn, void *data);
 
 
+#ifdef CONFIG_PAGE_POISONING
+extern void poison_pages(struct page *page, int n);
+extern void unpoison_pages(struct page *page, int n);
+extern bool page_poisoning_enabled(void);
+#else
+static inline void poison_pages(struct page *page, int n) { }
+static inline void unpoison_pages(struct page *page, int n) { }
+static inline bool page_poisoning_enabled(void) { return false; }
+#endif
+
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern bool _debug_pagealloc_enabled;
 extern void __kernel_map_pages(struct page *page, int numpages, int enable);
diff --git a/mm/Makefile b/mm/Makefile
index 2ed4319..f256978 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -48,7 +48,10 @@ obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_KSM) += ksm.o
-obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
+ifndef CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	obj-$(CONFIG_DEBUG_PAGEALLOC) += debug-pagealloc.o
+endif
+obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_KMEMCHECK) += kmemcheck.o
diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index 5bf5906..3cc4c1d 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -6,128 +6,9 @@
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
 
-static bool page_poisoning_enabled __read_mostly;
-
-static bool need_page_poisoning(void)
-{
-	if (!debug_pagealloc_enabled())
-		return false;
-
-	return true;
-}
-
-static void init_page_poisoning(void)
-{
-	if (!debug_pagealloc_enabled())
-		return;
-
-	page_poisoning_enabled = true;
-}
-
-struct page_ext_operations page_poisoning_ops = {
-	.need = need_page_poisoning,
-	.init = init_page_poisoning,
-};
-
-static inline void set_page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static inline void clear_page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static inline bool page_poison(struct page *page)
-{
-	struct page_ext *page_ext;
-
-	page_ext = lookup_page_ext(page);
-	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
-}
-
-static void poison_page(struct page *page)
-{
-	void *addr = kmap_atomic(page);
-
-	set_page_poison(page);
-	memset(addr, PAGE_POISON, PAGE_SIZE);
-	kunmap_atomic(addr);
-}
-
-static void poison_pages(struct page *page, int n)
-{
-	int i;
-
-	for (i = 0; i < n; i++)
-		poison_page(page + i);
-}
-
-static bool single_bit_flip(unsigned char a, unsigned char b)
-{
-	unsigned char error = a ^ b;
-
-	return error && !(error & (error - 1));
-}
-
-static void check_poison_mem(unsigned char *mem, size_t bytes)
-{
-	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
-	unsigned char *start;
-	unsigned char *end;
-
-	start = memchr_inv(mem, PAGE_POISON, bytes);
-	if (!start)
-		return;
-
-	for (end = mem + bytes - 1; end > start; end--) {
-		if (*end != PAGE_POISON)
-			break;
-	}
-
-	if (!__ratelimit(&ratelimit))
-		return;
-	else if (start == end && single_bit_flip(*start, PAGE_POISON))
-		printk(KERN_ERR "pagealloc: single bit error\n");
-	else
-		printk(KERN_ERR "pagealloc: memory corruption\n");
-
-	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
-			end - start + 1, 1);
-	dump_stack();
-}
-
-static void unpoison_page(struct page *page)
-{
-	void *addr;
-
-	if (!page_poison(page))
-		return;
-
-	addr = kmap_atomic(page);
-	check_poison_mem(addr, PAGE_SIZE);
-	clear_page_poison(page);
-	kunmap_atomic(addr);
-}
-
-static void unpoison_pages(struct page *page, int n)
-{
-	int i;
-
-	for (i = 0; i < n; i++)
-		unpoison_page(page + i);
-}
-
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
-	if (!page_poisoning_enabled)
+	if (!page_poisoning_enabled())
 		return;
 
 	if (enable)
diff --git a/mm/page_poison.c b/mm/page_poison.c
new file mode 100644
index 0000000..0f369a6
--- /dev/null
+++ b/mm/page_poison.c
@@ -0,0 +1,144 @@
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/page_ext.h>
+#include <linux/poison.h>
+#include <linux/ratelimit.h>
+
+static bool __page_poisoning_enabled __read_mostly;
+static bool want_page_poisoning __read_mostly =
+	!IS_ENABLED(CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC);
+
+static int early_page_poison_param(char *buf)
+{
+        if (!buf)
+                return -EINVAL;
+
+        if (strcmp(buf, "on") == 0)
+                want_page_poisoning = true;
+	else if (strcmp(buf, "off") == 0)
+		want_page_poisoning = false;
+
+        return 0;
+}
+early_param("page_poison", early_page_poison_param);
+
+bool page_poisoning_enabled(void)
+{
+	return __page_poisoning_enabled;
+}
+
+static bool need_page_poisoning(void)
+{
+	return want_page_poisoning;
+}
+
+static void init_page_poisoning(void)
+{
+	if (!want_page_poisoning)
+		return;
+
+	__page_poisoning_enabled = true;
+}
+
+struct page_ext_operations page_poisoning_ops = {
+	.need = need_page_poisoning,
+	.init = init_page_poisoning,
+};
+
+static inline void set_page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static inline void clear_page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static inline bool page_poison(struct page *page)
+{
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
+}
+
+static void poison_page(struct page *page)
+{
+	void *addr = kmap_atomic(page);
+
+	set_page_poison(page);
+	memset(addr, PAGE_POISON, PAGE_SIZE);
+	kunmap_atomic(addr);
+}
+
+void poison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		poison_page(page + i);
+}
+
+static bool single_bit_flip(unsigned char a, unsigned char b)
+{
+	unsigned char error = a ^ b;
+
+	return error && !(error & (error - 1));
+}
+
+static void check_poison_mem(unsigned char *mem, size_t bytes)
+{
+	static DEFINE_RATELIMIT_STATE(ratelimit, 5 * HZ, 10);
+	unsigned char *start;
+	unsigned char *end;
+
+	start = memchr_inv(mem, PAGE_POISON, bytes);
+	if (!start)
+		return;
+
+	for (end = mem + bytes - 1; end > start; end--) {
+		if (*end != PAGE_POISON)
+			break;
+	}
+
+	if (!__ratelimit(&ratelimit))
+		return;
+	else if (start == end && single_bit_flip(*start, PAGE_POISON))
+		printk(KERN_ERR "pagealloc: single bit error\n");
+	else
+		printk(KERN_ERR "pagealloc: memory corruption\n");
+
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
+			end - start + 1, 1);
+	dump_stack();
+}
+
+static void unpoison_page(struct page *page)
+{
+	void *addr;
+
+	if (!page_poison(page))
+		return;
+
+	addr = kmap_atomic(page);
+	check_poison_mem(addr, PAGE_SIZE);
+	clear_page_poison(page);
+	kunmap_atomic(addr);
+}
+
+void unpoison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		unpoison_page(page + i);
+}
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
