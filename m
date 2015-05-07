Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EE9966B006C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:36:06 -0400 (EDT)
Received: by wgic8 with SMTP id c8so6668257wgi.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:36:06 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id lg1si1689234wjc.136.2015.05.06.23.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 23:36:05 -0700 (PDT)
Received: by widdi4 with SMTP id di4so47502100wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:36:04 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v3 3/4] mm/page_alloc.c: add config option to sanitize freed pages
Date: Thu,  7 May 2015 08:34:11 +0200
Message-Id: <1430980452-2767-4-git-send-email-anisse@astier.eu>
In-Reply-To: <1430980452-2767-1-git-send-email-anisse@astier.eu>
References: <1430980452-2767-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

This new config option will sanitize all freed pages. This is a pretty
low-level change useful to track some cases of use-after-free, help
kernel same-page merging in VM environments, and counter a few info
leaks.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 mm/Kconfig      | 12 ++++++++++++
 mm/page_alloc.c | 12 ++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..e9fb3bd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config SANITIZE_FREED_PAGES
+	bool "Sanitize memory pages after free"
+	default n
+	help
+	  This option is used to make sure all pages freed are zeroed. This is
+	  quite low-level and doesn't handle your slab buffers.
+	  It has various applications, from preventing some info leaks to
+	  helping kernel same-page merging in virtualised environments.
+	  Depending on your workload it will greatly reduce performance.
+
+	  If unsure, say N.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4d5ce6e..c29e3a0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -795,6 +795,12 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
+
+#ifdef CONFIG_SANITIZE_FREED_PAGES
+	for (i = 0; i < (1 << order); i++)
+		clear_highpage(page + i);
+#endif
+
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
@@ -960,9 +966,15 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 	kernel_map_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 
+#ifndef CONFIG_SANITIZE_FREED_PAGES
+	/* SANITIZE_FREED_PAGES relies implicitly on the fact that pages are
+	 * cleared before use, so we don't need gfp zero in the default case
+	 * because all pages go through the free_pages_prepare code path when
+	 * switching from bootmem to the default allocator */
 	if (gfp_flags & __GFP_ZERO)
 		for (i = 0; i < (1 << order); i++)
 			clear_highpage(page + i);
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
