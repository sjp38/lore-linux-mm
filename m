Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A3866B0008
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 03:29:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m3so4115313pgd.20
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 00:29:52 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0047.outbound.protection.outlook.com. [104.47.40.47])
        by mx.google.com with ESMTPS id q27si11443829pfl.135.2018.01.29.00.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 00:29:50 -0800 (PST)
From: Roger He <Hongbo.He@amd.com>
Subject: [PATCH] mm/swap: add function get_total_swap_pages to expose total_swap_pages
Date: Mon, 29 Jan 2018 16:29:42 +0800
Message-ID: <1517214582-30880-1-git-send-email-Hongbo.He@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christian.Koenig@amd.com, Roger He <Hongbo.He@amd.com>

ttm module needs it to determine its internal parameter setting.

Signed-off-by: Roger He <Hongbo.He@amd.com>
---
 include/linux/swap.h |  6 ++++++
 mm/swapfile.c        | 15 +++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c2b8128..708d66f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -484,6 +484,7 @@ extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
 extern void exit_swap_address_space(unsigned int type);
+extern long get_total_swap_pages(void);
 
 #else /* CONFIG_SWAP */
 
@@ -516,6 +517,11 @@ static inline void show_swap_cache_info(void)
 {
 }
 
+long get_total_swap_pages(void)
+{
+	return 0;
+}
+
 #define free_swap_and_cache(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
 #define swapcache_prepare(e) ({(is_migration_entry(e) || is_device_private_entry(e));})
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02..a0062eb 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -98,6 +98,21 @@ static atomic_t proc_poll_event = ATOMIC_INIT(0);
 
 atomic_t nr_rotate_swap = ATOMIC_INIT(0);
 
+/*
+ * expose this value for others use
+ */
+long get_total_swap_pages(void)
+{
+	long ret;
+
+	spin_lock(&swap_lock);
+	ret = total_swap_pages;
+	spin_unlock(&swap_lock);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(get_total_swap_pages);
+
 static inline unsigned char swap_count(unsigned char ent)
 {
 	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
