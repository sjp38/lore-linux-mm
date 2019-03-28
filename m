Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFD6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C1E8206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C1E8206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F6086B0008; Wed, 27 Mar 2019 13:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076956B0010; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8CE16B000C; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 779886B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e12so10375666pgh.2
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y6cinH3ZOurbKjZ1YP49eubQN0hSHHiTFTJ4zmUIiZU=;
        b=oO4e7y4mKCXVXqnRPTFYb3rmZBq3kTbUWjLvkO7/lfFN9QCaI/FzZFUYyS4nvHxaxa
         wGzYqdjn5RXZjyExybVlGtTqG2mmimXj94CT8F8ceoVh/aNUS6B/AUAKwz42SrcYDWrO
         1Ve7l08BfSURcBaZStX7+MaOnGFUUc7goR2b79vEU6s0Gk2YY8xYwYEphG43j2o2ZCvl
         jNbXF/TqZmVQyqGfMYytcd3JMWTTC9ny/tidxWGxp3eqJ0muAEwTKxPgiovMueDm41pK
         OYEwuk295IN2tdLQE/1JHJN3iAfFFeRFo3k0baWmkKn0Bl/pAoH5/vq7n+wtypBGZ8cW
         Ppjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVJY7zO33z7r47d+118J+aVGip04GMQCnYwhYJ9zgA2uMYe2Xnf
	QmXHgB/n7Y4L0CIPOTuGXpZwWOqiHU3V2wH7rnhJFB3eC/j4geaKHg6+Db8s+CY30jctevQuyDl
	kGxZu7NqsjpQfYsLQN1raDLvZktopR31BOv3j/RwLG9EKIoMBBzAHMqgVhJhBP1eV8A==
X-Received: by 2002:a17:902:b609:: with SMTP id b9mr38065897pls.134.1553706572015;
        Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8GKVMTAunZth4YG1NvvYOcu0ZOHOnG+yMEYaK2qaJvLVUhcqk4fFT8b4lfgAENOviDfJW
X-Received: by 2002:a17:902:b609:: with SMTP id b9mr38065773pls.134.1553706570608;
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706570; cv=none;
        d=google.com; s=arc-20160816;
        b=waEI1n8IVzqtqhrL/ITbV0j0KZNk2491IYrSL/ROfwn7ywiEKAS+85KUYpgTs/ZuDv
         2K0ZPs6KmPtVKcKTQK1WYaRxDbAf8qUJYhOdageVgtTWhG815dSc+iALIKB97EAJKrKI
         49VS9bkpJ0PHLsh6jg5PSNf8LYzbkZs2hZxK3UD24+HpDqf/Fxo2BB+96IKHo8lO9ULP
         acGzdJGT7bMUEvy8TzSXpA0gWUA71lZGPMwUgNadosH6+ytvb8923tzB4SJ2Pb4u9jpG
         +X3OqMlmJ2b66jAZtkwJMnaYZqk6M34adReMKGeBmR6mf4m03xGh6n+HrVU/SSLwxjaT
         hA7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=y6cinH3ZOurbKjZ1YP49eubQN0hSHHiTFTJ4zmUIiZU=;
        b=vRpw2Lo2fJSM6QFmcYh0efgq/SrmyxKL/iPBZ5pHftisqcs4pSUYCQCIhrdxTMKKNT
         G8RmKFAZv3kMClHQ9jrIxzlKS0diTmEWdr0wPVqrxdcWd0CfnpB7M/ZIYKwDCsCWtrhK
         kxJoILfwWI0WUcKH6ULfjXY1FzrrY+ImkoVL4ik1+NBzY85eJJG+waIo1h7+d0+Q7P+d
         92AdRWwLum8CmBQiRAX+1ldWJtVurl/mw+y5o94b4nNiKQfp4qLZhPpL6guwajiQfAFS
         Hh2Fz9a7I1NuUJCpphDrLGl/IqgW1AeBwmtelSzv/fiKHuVKsFpPryKsXQiXYBa26ysl
         6w0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id n22si19678465plp.296.2019.03.27.10.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 27 Mar 2019 10:09:16 -0700
Received: from namit-esx4.eng.vmware.com (sc2-hs2-general-dhcp-219-51.eng.vmware.com [10.172.219.51])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id AC3EEB2125;
	Wed, 27 Mar 2019 13:09:29 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav
 Amit <namit@vmware.com>
Subject: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Date: Thu, 28 Mar 2019 01:07:15 +0000
Message-ID: <20190328010718.2248-2-namit@vmware.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190328010718.2248-1-namit@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce interfaces for ballooning enqueueing and dequeueing of a list
of pages. These interfaces reduce the overhead of storing and restoring
IRQs by batching the operations. In addition they do not panic if the
list of pages is empty.

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org
Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/balloon_compaction.h |   4 +
 mm/balloon_compaction.c            | 145 +++++++++++++++++++++--------
 2 files changed, 111 insertions(+), 38 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index f111c780ef1d..1da79edadb69 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -64,6 +64,10 @@ extern struct page *balloon_page_alloc(void);
 extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 				 struct page *page);
 extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
+extern size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+				      struct list_head *pages);
+extern size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				     struct list_head *pages, int n_req_pages);
 
 static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 {
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d547e2d..88d5d9a01072 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -10,6 +10,106 @@
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
 
+static int balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
+				     struct page *page)
+{
+	/*
+	 * Block others from accessing the 'page' when we get around to
+	 * establishing additional references. We should be the only one
+	 * holding a reference to the 'page' at this point.
+	 */
+	if (!trylock_page(page)) {
+		WARN_ONCE(1, "balloon inflation failed to enqueue page\n");
+		return -EFAULT;
+	}
+	list_del(&page->lru);
+	balloon_page_insert(b_dev_info, page);
+	unlock_page(page);
+	__count_vm_event(BALLOON_INFLATE);
+	return 0;
+}
+
+/**
+ * balloon_page_list_enqueue() - inserts a list of pages into the balloon page
+ *				 list.
+ * @b_dev_info: balloon device descriptor where we will insert a new page to
+ * @pages: pages to enqueue - allocated using balloon_page_alloc.
+ *
+ * Driver must call it to properly enqueue a balloon pages before definitively
+ * removing it from the guest system.
+ *
+ * Return: number of pages that were enqueued.
+ */
+size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+			       struct list_head *pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	size_t n_pages = 0;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, pages, lru) {
+		balloon_page_enqueue_one(b_dev_info, page);
+		n_pages++;
+	}
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	return n_pages;
+}
+EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
+
+/**
+ * balloon_page_list_dequeue() - removes pages from balloon's page list and
+ *				 returns a list of the pages.
+ * @b_dev_info: balloon device decriptor where we will grab a page from.
+ * @pages: pointer to the list of pages that would be returned to the caller.
+ * @n_req_pages: number of requested pages.
+ *
+ * Driver must call it to properly de-allocate a previous enlisted balloon pages
+ * before definetively releasing it back to the guest system. This function
+ * tries to remove @n_req_pages from the ballooned pages and return it to the
+ * caller in the @pages list.
+ *
+ * Note that this function may fail to dequeue some pages temporarily empty due
+ * to compaction isolated pages.
+ *
+ * Return: number of pages that were added to the @pages list.
+ */
+size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				 struct list_head *pages, int n_req_pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	size_t n_pages = 0;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
+		/*
+		 * Block others from accessing the 'page' while we get around
+		 * establishing additional references and preparing the 'page'
+		 * to be released by the balloon driver.
+		 */
+		if (!trylock_page(page))
+			continue;
+
+		if (IS_ENABLED(CONFIG_BALLOON_COMPACTION) &&
+		    PageIsolated(page)) {
+			/* raced with isolation */
+			unlock_page(page);
+			continue;
+		}
+		balloon_page_delete(page);
+		__count_vm_event(BALLOON_DEFLATE);
+		unlock_page(page);
+		list_add(&page->lru, pages);
+		if (++n_pages >= n_req_pages)
+			break;
+	}
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+
+	return n_pages;
+}
+EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
+
 /*
  * balloon_page_alloc - allocates a new page for insertion into the balloon
  *			  page list.
@@ -43,17 +143,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 {
 	unsigned long flags;
 
-	/*
-	 * Block others from accessing the 'page' when we get around to
-	 * establishing additional references. We should be the only one
-	 * holding a reference to the 'page' at this point.
-	 */
-	BUG_ON(!trylock_page(page));
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	balloon_page_insert(b_dev_info, page);
-	__count_vm_event(BALLOON_INFLATE);
+	balloon_page_enqueue_one(b_dev_info, page);
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
-	unlock_page(page);
 }
 EXPORT_SYMBOL_GPL(balloon_page_enqueue);
 
@@ -70,36 +162,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
  */
 struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 {
-	struct page *page, *tmp;
 	unsigned long flags;
-	bool dequeued_page;
+	LIST_HEAD(pages);
+	int n_pages;
 
-	dequeued_page = false;
-	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
-		/*
-		 * Block others from accessing the 'page' while we get around
-		 * establishing additional references and preparing the 'page'
-		 * to be released by the balloon driver.
-		 */
-		if (trylock_page(page)) {
-#ifdef CONFIG_BALLOON_COMPACTION
-			if (PageIsolated(page)) {
-				/* raced with isolation */
-				unlock_page(page);
-				continue;
-			}
-#endif
-			balloon_page_delete(page);
-			__count_vm_event(BALLOON_DEFLATE);
-			unlock_page(page);
-			dequeued_page = true;
-			break;
-		}
-	}
-	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	n_pages = balloon_page_list_dequeue(b_dev_info, &pages, 1);
 
-	if (!dequeued_page) {
+	if (n_pages != 1) {
 		/*
 		 * If we are unable to dequeue a balloon page because the page
 		 * list is empty and there is no isolated pages, then something
@@ -112,9 +181,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 			     !b_dev_info->isolated_pages))
 			BUG();
 		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
-		page = NULL;
+		return NULL;
 	}
-	return page;
+	return list_first_entry(&pages, struct page, lru);
 }
 EXPORT_SYMBOL_GPL(balloon_page_dequeue);
 
-- 
2.19.1

