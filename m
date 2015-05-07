Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 80BB86B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:35:59 -0400 (EDT)
Received: by widdi4 with SMTP id di4so229097351wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:35:59 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id ba3si1725598wjc.86.2015.05.06.23.35.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 23:35:57 -0700 (PDT)
Received: by wizk4 with SMTP id k4so229430494wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:35:57 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v3 2/4] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Date: Thu,  7 May 2015 08:34:10 +0200
Message-Id: <1430980452-2767-3-git-send-email-anisse@astier.eu>
In-Reply-To: <1430980452-2767-1-git-send-email-anisse@astier.eu>
References: <1430980452-2767-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

SANITIZE_FREED_PAGES feature relies on having all pages going through
the free_pages_prepare path in order to be cleared before being used. In
the hibernate use case, pages will automagically appear in the system
without being cleared.

This patch will make sure free pages are cleared on resume; when we'll
enable SANITIZE_FREED_PAGES. We free the pages just after resume because
we can't do it later: going through any device resume code might
allocate some memory and invalidate the free pages bitmap.

Signed-off-by: Anisse Astier <anisse@astier.eu>
---
 kernel/power/hibernate.c |  7 ++++++-
 kernel/power/power.h     |  4 ++++
 kernel/power/snapshot.c  | 21 +++++++++++++++++++++
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index 2329daa..3193b9a 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -305,9 +305,14 @@ static int create_image(int platform_mode)
 			error);
 	/* Restore control flow magically appears here */
 	restore_processor_state();
-	if (!in_suspend)
+	if (!in_suspend) {
 		events_check_enabled = false;
 
+#ifdef CONFIG_SANITIZE_FREED_PAGES
+		clear_free_pages();
+		printk(KERN_INFO "PM: free pages cleared after restore\n");
+#endif
+	}
 	platform_leave(platform_mode);
 
  Power_up:
diff --git a/kernel/power/power.h b/kernel/power/power.h
index ce9b832..26b2101 100644
--- a/kernel/power/power.h
+++ b/kernel/power/power.h
@@ -92,6 +92,10 @@ extern int create_basic_memory_bitmaps(void);
 extern void free_basic_memory_bitmaps(void);
 extern int hibernate_preallocate_memory(void);
 
+#ifdef CONFIG_SANITIZE_FREED_PAGES
+extern void clear_free_pages(void);
+#endif
+
 /**
  *	Auxiliary structure used for reading the snapshot image data and
  *	metadata from and writing them to the list of page backup entries
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 5235dd4..673ade1 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1032,6 +1032,27 @@ void free_basic_memory_bitmaps(void)
 	pr_debug("PM: Basic memory bitmaps freed\n");
 }
 
+#ifdef CONFIG_SANITIZE_FREED_PAGES
+void clear_free_pages(void)
+{
+	struct memory_bitmap *bm = free_pages_map;
+	unsigned long pfn;
+
+	if (WARN_ON(!(free_pages_map)))
+		return;
+
+	memory_bm_position_reset(bm);
+	pfn = memory_bm_next_pfn(bm);
+	while (pfn != BM_END_OF_MAP) {
+		if (pfn_valid(pfn))
+			clear_highpage(pfn_to_page(pfn));
+
+		pfn = memory_bm_next_pfn(bm);
+	}
+	memory_bm_position_reset(bm);
+}
+#endif /* SANITIZE_FREED_PAGES */
+
 /**
  *	snapshot_additional_pages - estimate the number of additional pages
  *	be needed for setting up the suspend image data structures for given
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
