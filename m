Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id AC2396B006C
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:06:19 -0400 (EDT)
Received: by wiun10 with SMTP id n10so33100912wiu.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:19 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id q8si813167wif.7.2015.04.24.14.06.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 14:06:18 -0700 (PDT)
Received: by widdi4 with SMTP id di4so33141837wid.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:18 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH 2/2] mm/page_alloc.c: add config option to sanitize freed pages
Date: Fri, 24 Apr 2015 23:05:49 +0200
Message-Id: <1429909549-11726-3-git-send-email-anisse@astier.eu>
In-Reply-To: <1429909549-11726-1-git-send-email-anisse@astier.eu>
References: <1429909549-11726-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This new config option will sanitize all freed pages. This is a pretty
low-level change useful to track some cases of use-after-free, help
kernel same-page merging in VM environments, and counter a few info
leaks.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 mm/Kconfig      | 12 ++++++++++++
 mm/page_alloc.c |  5 +++++
 2 files changed, 17 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..cb2df5f 100644
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
+	  Depending on your workload, it will reduce performance of about 3%.
+
+	  If unsure, say N.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05fcec9..c71440a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -803,6 +803,11 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
+
+#ifdef CONFIG_SANITIZE_FREED_PAGES
+	zero_pages(page, order);
+#endif
+
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
