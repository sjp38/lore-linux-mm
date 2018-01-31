Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5446B000E
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:33 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id e132so9636315vkf.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:33 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t28si1970538uae.199.2018.01.31.15.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:32 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 06/13] mm: add lru_[un]lock_all APIs
Date: Wed, 31 Jan 2018 18:04:06 -0500
Message-Id: <20180131230413.27653-7-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Add heavy locking API's for the few cases that a thread needs exclusive
access to an LRU list.  This locks lru_lock as well as every lock in
lru_batch_locks.

This API will be used often at first, in scaffolding code, to ease the
transition from using lru_lock to the batch locking scheme.  Later it
will be rarely needed.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mm_inline.h | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index ec8b966a1c76..1f1657c75b1b 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -178,6 +178,38 @@ static __always_inline void move_page_to_lru_list_tail(struct page *page,
 	__add_page_to_lru_list_tail(page, lruvec, lru);
 }
 
+static __always_inline void lru_lock_all(struct pglist_data *pgdat,
+					 unsigned long *flags)
+{
+	size_t i;
+
+	if (flags)
+		local_irq_save(*flags);
+	else
+		local_irq_disable();
+
+	for (i = 0; i < NUM_LRU_BATCH_LOCKS; ++i)
+		spin_lock(&pgdat->lru_batch_locks[i].lock);
+
+	spin_lock(&pgdat->lru_lock);
+}
+
+static __always_inline void lru_unlock_all(struct pglist_data *pgdat,
+					   unsigned long *flags)
+{
+	int i;
+
+	spin_unlock(&pgdat->lru_lock);
+
+	for (i = NUM_LRU_BATCH_LOCKS - 1; i >= 0; --i)
+		spin_unlock(&pgdat->lru_batch_locks[i].lock);
+
+	if (flags)
+		local_irq_restore(*flags);
+	else
+		local_irq_enable();
+}
+
 /**
  * page_lru_base_type - which LRU list type should a page be on?
  * @page: the page to test
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
