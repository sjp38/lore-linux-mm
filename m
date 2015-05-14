Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id DA2216B0072
	for <linux-mm@kvack.org>; Thu, 14 May 2015 10:20:03 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so18716693wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:20:03 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id cy1si5683645wib.89.2015.05.14.07.19.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 07:20:00 -0700 (PDT)
Received: by wizk4 with SMTP id k4so243199182wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 07:19:59 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v4 3/3] mm: Add debug code for SANITIZE_FREED_PAGES
Date: Thu, 14 May 2015 16:19:48 +0200
Message-Id: <1431613188-4511-4-git-send-email-anisse@astier.eu>
In-Reply-To: <1431613188-4511-1-git-send-email-anisse@astier.eu>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

Add debug code for sanitize freed pages to print status and verify pages
at alloc to make sure they're clean. It can be useful if you have
crashes when using SANITIZE_FREED_PAGES.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 kernel/power/snapshot.c |  8 ++++++--
 mm/Kconfig              | 10 ++++++++++
 mm/page_alloc.c         | 18 ++++++++++++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 2335130..e10e736 100644
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
index c29e3a0..d76325ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -975,6 +975,24 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
 #endif
+#ifdef CONFIG_SANITIZE_FREED_PAGES_DEBUG
+	for (i = 0; i < (1 << order); i++) {
+		struct page *p = page + i;
+		void *kaddr = kmap_atomic(p);
+		void *found = memchr_inv(kaddr, 0, PAGE_SIZE);
+
+		kunmap_atomic(kaddr);
+
+		if (found) {
+			pr_err("page %p is not zero on alloc! %s\n",
+					page_address(p), (gfp_flags &
+						__GFP_ZERO) ?
+					"fixing." : "");
+			if (gfp_flags & __GFP_ZERO)
+				clear_highpage(p);
+		}
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
