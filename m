Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFB16B0073
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:17:13 -0400 (EDT)
Received: by wgin8 with SMTP id n8so163088671wgi.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:17:13 -0700 (PDT)
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id t1si13360102wif.84.2015.05.04.14.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:17:11 -0700 (PDT)
Received: by wgin8 with SMTP id n8so163088065wgi.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:17:11 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v2 4/4] mm: Add debug code for SANITIZE_FREED_PAGES
Date: Mon,  4 May 2015 23:16:58 +0200
Message-Id: <1430774218-5311-5-git-send-email-anisse@astier.eu>
In-Reply-To: <1430774218-5311-1-git-send-email-anisse@astier.eu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add debug code for sanitize freed pages to print status and verify pages
at alloc to make sure they're clean. It can be useful if you have
crashes when using SANITIZE_FREED_PAGES.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 kernel/power/snapshot.c |  8 ++++++--
 mm/Kconfig              | 10 ++++++++++
 mm/page_alloc.c         | 25 +++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 673ade1..dfbfb5f 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1044,9 +1044,13 @@ void clear_free_pages(void)
 	memory_bm_position_reset(bm);
 	pfn = memory_bm_next_pfn(bm);
 	while (pfn != BM_END_OF_MAP) {
-		if (pfn_valid(pfn))
+		if (pfn_valid(pfn)) {
+#ifdef CONFIG_SANITIZE_FREED_PAGES_DEBUG
+			printk(KERN_INFO "Clearing page %p\n",
+					page_address(pfn_to_page(pfn)));
+#endif
 			clear_highpage(pfn_to_page(pfn));
-
+		}
 		pfn = memory_bm_next_pfn(bm);
 	}
 	memory_bm_position_reset(bm);
diff --git a/mm/Kconfig b/mm/Kconfig
index e9fb3bd..95364f2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -647,3 +647,13 @@ config SANITIZE_FREED_PAGES
 	  Depending on your workload it will greatly reduce performance.
 
 	  If unsure, say N.
+
+config SANITIZE_FREED_PAGES_DEBUG
+	bool "Debug sanitize pages feature"
+	default n
+	depends on SANITIZE_FREED_PAGES && DEBUG_KERNEL
+	help
+	  This option adds some debugging code for the SANITIZE_FREED_PAGES
+	  option, as well as verification code to ensure pages are really
+	  zeroed. Don't enable unless you want to debug this feature.
+	  If unsure, say N.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c29e3a0..ba8aa25 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -975,6 +975,31 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 #endif
+#ifdef CONFIG_SANITIZE_FREED_PAGES_DEBUG
+	for (i = 0; i < (1 << order); i++) {
+		struct page *p = page + i;
+		int j;
+		bool err = false;
+		void *kaddr = kmap_atomic(p);
+
+		for (j = 0; j < PAGE_SIZE; j++) {
+			if (((char *)kaddr)[j] != 0) {
+				pr_err("page %p is not zero on alloc! %s\n",
+						page_address(p), (gfp_flags &
+							__GFP_ZERO) ?
+						"fixing." : "");
+				if (gfp_flags & __GFP_ZERO) {
+					err = true;
+					kunmap_atomic(kaddr);
+					clear_highpage(p);
+				}
+				break;
+			}
+		}
+		if (!err)
+			kunmap_atomic(kaddr);
+	}
+#endif
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
