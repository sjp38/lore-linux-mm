Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id C3D7A6B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 07:56:20 -0400 (EDT)
Received: by oiev193 with SMTP id v193so55571568oie.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:56:20 -0700 (PDT)
Received: from BLU004-OMC1S38.hotmail.com (blu004-omc1s38.hotmail.com. [65.55.116.49])
        by mx.google.com with ESMTPS id r9si14239481obg.22.2015.08.10.04.56.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 04:56:20 -0700 (PDT)
Message-ID: <BLU436-SMTP127AFDD347F96AC6BDED54C80700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 3/5] mm/hwpoison: introduce put_hwpoison_page to put refcount for memory error handling
Date: Mon, 10 Aug 2015 19:28:21 +0800
In-Reply-To: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>

Introduce put_hwpoison_page to put refcount for memory 
error handling. 

Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 include/linux/mm.h  |    1 +
 mm/memory-failure.c |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 554b0f0..c0a0b9f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2103,6 +2103,7 @@ extern int memory_failure(unsigned long pfn, int trapno, int flags);
 extern void memory_failure_queue(unsigned long pfn, int trapno, int flags);
 extern int unpoison_memory(unsigned long pfn);
 extern int get_hwpoison_page(struct page *page);
+extern void put_hwpoison_page(struct page *page);
 extern int sysctl_memory_failure_early_kill;
 extern int sysctl_memory_failure_recovery;
 extern void shake_page(struct page *p, int access);
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index e0eb7ab..fa9aa21 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -922,6 +922,27 @@ int get_hwpoison_page(struct page *page)
 }
 EXPORT_SYMBOL_GPL(get_hwpoison_page);
 
+/**
+ * put_hwpoison_page() - Put refcount for memory error handling:
+ * @page:	raw error page (hit by memory error)
+ */
+void put_hwpoison_page(struct page *page)
+{
+	struct page *head = compound_head(page);
+
+	if (PageHuge(head)) {
+		put_page(head);
+		return;
+	}
+
+	if (PageTransHuge(head))
+		if (page != head)
+			put_page(head);
+
+	put_page(page);
+}
+EXPORT_SYMBOL_GPL(put_hwpoison_page);
+
 /*
  * Do all that is necessary to remove user space mappings. Unmap
  * the pages and send SIGBUS to the processes if the data was dirty.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
