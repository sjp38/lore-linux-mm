Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3092B6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 04:43:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w12so8897674wmf.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 01:43:47 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id bp2si1992891wjb.158.2016.09.09.01.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 01:43:46 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id a6so1683476wmc.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 01:43:45 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH] PM / Hibernate: allow hibernation with PAGE_POISONING_ZERO
Date: Fri,  9 Sep 2016 10:43:32 +0200
Message-Id: <1473410612-6207-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-pm@vger.kernel.org
Cc: Anisse Astier <anisse@astier.eu>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Laura Abbott <labbott@fedoraproject.org>, Mel Gorman <mgorman@suse.de>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Jianyu Zhan <nasa4836@gmail.com>, Kees Cook <keescook@chromium.org>, Len Brown <len.brown@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mathias Krause <minipli@googlemail.com>, Michal Hocko <mhocko@suse.com>, PaX Team <pageexec@freemail.hu>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Yves-Alexis Perez <corsac@debian.org>, linux-kernel@vger.kernel.org

PAGE_POISONING_ZERO disables zeroing new pages on alloc, they are
poisoned (zeroed) as they become available.
In the hibernate use case, free pages will appear in the system without
being cleared, left there by the loading kernel.

This patch will make sure free pages are cleared on resume when
PAGE_POISONING_ZERO is enabled. We free the pages just after resume
because we can't do it later: going through any device resume code might
allocate some memory and invalidate the free pages bitmap.

Thus we don't need to disable hibernation when PAGE_POISONING_ZERO is
enabled.

Signed-off-by: Anisse Astier <anisse@astier.eu>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Laura Abbott <labbott@fedoraproject.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
---
 kernel/power/hibernate.c | 21 +++------------------
 kernel/power/power.h     |  2 ++
 kernel/power/snapshot.c  | 22 ++++++++++++++++++++++
 mm/Kconfig.debug         |  2 --
 4 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index 33c79b6..b26dbc4 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -306,8 +306,10 @@ static int create_image(int platform_mode)
 	if (error)
 		printk(KERN_ERR "PM: Error %d creating hibernation image\n",
 			error);
-	if (!in_suspend)
+	if (!in_suspend) {
 		events_check_enabled = false;
+		clear_free_pages();
+	}
 
 	platform_leave(platform_mode);
 
@@ -1189,22 +1191,6 @@ static int __init nohibernate_setup(char *str)
 	return 1;
 }
 
-static int __init page_poison_nohibernate_setup(char *str)
-{
-#ifdef CONFIG_PAGE_POISONING_ZERO
-	/*
-	 * The zeroing option for page poison skips the checks on alloc.
-	 * since hibernation doesn't save free pages there's no way to
-	 * guarantee the pages will still be zeroed.
-	 */
-	if (!strcmp(str, "on")) {
-		pr_info("Disabling hibernation due to page poisoning\n");
-		return nohibernate_setup(str);
-	}
-#endif
-	return 1;
-}
-
 __setup("noresume", noresume_setup);
 __setup("resume_offset=", resume_offset_setup);
 __setup("resume=", resume_setup);
@@ -1212,4 +1198,3 @@ __setup("hibernate=", hibernate_setup);
 __setup("resumewait", resumewait_setup);
 __setup("resumedelay=", resumedelay_setup);
 __setup("nohibernate", nohibernate_setup);
-__setup("page_poison=", page_poison_nohibernate_setup);
diff --git a/kernel/power/power.h b/kernel/power/power.h
index 242d8b8..56d1d0d 100644
--- a/kernel/power/power.h
+++ b/kernel/power/power.h
@@ -110,6 +110,8 @@ extern int create_basic_memory_bitmaps(void);
 extern void free_basic_memory_bitmaps(void);
 extern int hibernate_preallocate_memory(void);
 
+extern void clear_free_pages(void);
+
 /**
  *	Auxiliary structure used for reading the snapshot image data and
  *	metadata from and writing them to the list of page backup entries
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index b022284..4f0f060 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1132,6 +1132,28 @@ void free_basic_memory_bitmaps(void)
 	pr_debug("PM: Basic memory bitmaps freed\n");
 }
 
+void clear_free_pages(void)
+{
+#ifdef CONFIG_PAGE_POISONING_ZERO
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
+	pr_info("PM: free pages cleared after restore\n");
+#endif /* PAGE_POISONING_ZERO */
+}
+
 /**
  * snapshot_additional_pages - Estimate the number of extra pages needed.
  * @zone: Memory zone to carry out the computation for.
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 22f4cd9..afcc550 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -76,8 +76,6 @@ config PAGE_POISONING_ZERO
 	   no longer necessary to write zeros when GFP_ZERO is used on
 	   allocation.
 
-	   Enabling page poisoning with this option will disable hibernation
-
 	   If unsure, say N
 	bool
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
