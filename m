Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC2B6B000C
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 01:08:14 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id g76-v6so7072300pfe.13
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:08:14 -0800 (PST)
Received: from alexa-out-blr.qualcomm.com (alexa-out-blr-02.qualcomm.com. [103.229.18.198])
        by mx.google.com with ESMTPS id 2si16377227pgz.395.2018.11.11.22.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 22:08:10 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v4 4/4] mm: Remove managed_page_count spinlock
Date: Mon, 12 Nov 2018 11:37:49 +0530
Message-Id: <1542002869-16704-5-git-send-email-arunks@codeaurora.org>
In-Reply-To: <1542002869-16704-1-git-send-email-arunks@codeaurora.org>
References: <1542002869-16704-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, Arun KS <arunks@codeaurora.org>

Now that totalram_pages and managed_pages are atomic varibles, no need
of managed_page_count spinlock. The lock had really a weak consistency
guarantee. It hasn't been used for anything but the update but no reader
actually cares about all the values being updated to be in sync.

Signed-off-by: Arun KS <arunks@codeaurora.org>
Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h | 6 ------
 mm/page_alloc.c        | 5 -----
 2 files changed, 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e73dc31..c71b4d9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -428,12 +428,6 @@ struct zone {
 	 * Write access to present_pages at runtime should be protected by
 	 * mem_hotplug_begin/end(). Any reader who can't tolerant drift of
 	 * present_pages should get_online_mems() to get a stable value.
-	 *
-	 * Read access to managed_pages should be safe because it's unsigned
-	 * long. Write access to zone->managed_pages and totalram_pages are
-	 * protected by managed_page_count_lock at runtime. Idealy only
-	 * adjust_managed_page_count() should be used instead of directly
-	 * touching zone->managed_pages and totalram_pages.
 	 */
 	atomic_long_t		managed_pages;
 	unsigned long		spanned_pages;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8b64cc..26c5e14 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -122,9 +122,6 @@
 };
 EXPORT_SYMBOL(node_states);
 
-/* Protect totalram_pages and zone->managed_pages */
-static DEFINE_SPINLOCK(managed_page_count_lock);
-
 atomic_long_t _totalram_pages __read_mostly;
 EXPORT_SYMBOL(_totalram_pages);
 unsigned long totalreserve_pages __read_mostly;
@@ -7065,14 +7062,12 @@ static int __init cmdline_parse_movablecore(char *p)
 
 void adjust_managed_page_count(struct page *page, long count)
 {
-	spin_lock(&managed_page_count_lock);
 	atomic_long_add(count, &page_zone(page)->managed_pages);
 	totalram_pages_add(count);
 #ifdef CONFIG_HIGHMEM
 	if (PageHighMem(page))
 		totalhigh_pages_add(count);
 #endif
-	spin_unlock(&managed_page_count_lock);
 }
 EXPORT_SYMBOL(adjust_managed_page_count);
 
-- 
1.9.1
