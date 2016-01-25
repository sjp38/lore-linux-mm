Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E0458828DF
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:56:01 -0500 (EST)
Received: by mail-qk0-f169.google.com with SMTP id s5so56592803qkd.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:56:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 79si25180234qhm.62.2016.01.25.08.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:56:01 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [RFC][PATCH 2/3] mm/page_poison.c: Enable PAGE_POISONING as a separate option
Date: Mon, 25 Jan 2016 08:55:52 -0800
Message-Id: <1453740953-18109-3-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


Page poisoning is currently setup as a feature if architectures don't
have architecture debug page_alloc to allow unmapping of pages. It has
uses apart from that though. Clearing of the pages on free provides
an increase in security as it helps to limit the risk of information
leaks. Allow page poisoning to be enabled as a separate option
independent of any other debug feature. Because of how hiberanation
is implemented, the checks on alloc cannot occur if hibernation is
enabled. This option can also be set on !HIBERNATION as well.

Credit to Mathias Krause and grsecurity for original work

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>

---
 include/linux/mm.h   |  3 +++
 mm/Kconfig.debug     | 22 +++++++++++++++++++++-
 mm/debug-pagealloc.c |  8 +-------
 mm/page_alloc.c      |  2 ++
 mm/page_poison.c     | 14 ++++++++++++++
 5 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 25551c1..d14bca4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2178,10 +2178,13 @@ extern int apply_to_page_range(struct mm_struct *mm, unsigned long address,
 extern void poison_pages(struct page *page, int n);
 extern void unpoison_pages(struct page *page, int n);
 extern bool page_poisoning_enabled(void);
+extern void kernel_poison_pages(struct page *page, int numpages, int enable);
 #else
 static inline void poison_pages(struct page *page, int n) { }
 static inline void unpoison_pages(struct page *page, int n) { }
 static inline bool page_poisoning_enabled(void) { return false; }
+static inline void kernel_poison_pages(struct page *page, int numpages,
+					int enable) { }
 #endif
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 957d3da..c300f5f 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -27,4 +27,24 @@ config DEBUG_PAGEALLOC
 	  a resume because free pages are not saved to the suspend image.
 
 config PAGE_POISONING
-	bool
+	bool "Poisson pages after freeing"
+	select PAGE_EXTENSION
+	select PAGE_POISONING_NO_SANITY if HIBERNATION
+	---help---
+	  Fill the pages with poison patterns after free_pages() and verify
+	  the patterns before alloc_pages. The filling of the memory helps
+	  reduce the risk of information leaks from freed data. This does
+	  have a potential performance impact.
+
+	  If unsure, say N
+
+config PAGE_POISONING_NO_SANITY
+	depends on PAGE_POISONING
+	bool "Only poison, don't sanity check"
+	---help---
+	   Skip the sanity checking on alloc, only fill the pages with
+	   poison on free. This reduces some of the overhead of the
+	   poisoning feature.
+
+	   If you are only interested in sanitization, say Y. Otherwise
+	   say N.
diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index 3cc4c1d..0928d13 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -8,11 +8,5 @@
 
 void __kernel_map_pages(struct page *page, int numpages, int enable)
 {
-	if (!page_poisoning_enabled())
-		return;
-
-	if (enable)
-		unpoison_pages(page, numpages);
-	else
-		poison_pages(page, numpages);
+	kernel_poison_pages(page, numpages, enable);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 63358d9..c733421 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1002,6 +1002,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 					   PAGE_SIZE << order);
 	}
 	arch_free_page(page, order);
+	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 
 	return true;
@@ -1396,6 +1397,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
+	kernel_poison_pages(page, 1 << order, 1);
 	kernel_map_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 
diff --git a/mm/page_poison.c b/mm/page_poison.c
index 0f369a6..f6ae58b 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -101,6 +101,9 @@ static void check_poison_mem(unsigned char *mem, size_t bytes)
 	unsigned char *start;
 	unsigned char *end;
 
+	if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY))
+		return;
+
 	start = memchr_inv(mem, PAGE_POISON, bytes);
 	if (!start)
 		return;
@@ -142,3 +145,14 @@ void unpoison_pages(struct page *page, int n)
 	for (i = 0; i < n; i++)
 		unpoison_page(page + i);
 }
+
+void kernel_poison_pages(struct page *page, int numpages, int enable)
+{
+	if (!page_poisoning_enabled())
+		return;
+
+	if (enable)
+		unpoison_pages(page, numpages);
+	else
+		poison_pages(page, numpages);
+}
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
