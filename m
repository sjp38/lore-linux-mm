Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DEAAC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A2D42148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A2D42148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B815C6B0006; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61A46B0008; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95D4D6B000A; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F8EB6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q12so1527575pff.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=ebwJstrYPGxLraDC5I7RtOjkKdQk5KZQ7JsOvQG501E=;
        b=QnCS3xWkIpclh+0FGFJa7IT9rov/UOEKpiZA48z5lQj5+mQCdzrFYHrrpdDTPU+Tcf
         XEaRp5oc25DwfZSaUA3pFQh/KpLkB3SmR2WuZ4TFap6lhbOY6b6CUc4fVOix/r+/ql2k
         k22HodzitjMN85K695mdNphQhZDXiz9UBos5/vxErbOVIQ1B4nsRiIYbH6jPv/DL8YIH
         6mqZvKXj4UYQHB5CcZvRwlh2gNYO6Tp12Sqf1DhhkRvrEsIOzjBLnqQ07Lu1ZlBpXGpw
         sjiekfhBm9rMgixm2LcIZTEQo7TbMxg6QJqifrx7ERbGZzxsNyG+YVIzm1D+mN2ekhpq
         mK9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXzm5b1Xd7P6GAnWI0tMx8MYlXVyj/0Xb+weKr1CgIvrgECxdVl
	tGP5HbgQw/r9OxEGJtSuDvb1DZnWq9CWVI0RySqfpVaWMpRdyTayMzvF0t4SBGTIM8wPkBlS9nl
	iaXwhmfQ6B2YfQ3soOW/8UKShNCOEiQHJX0/uhzDPt2ctIuDDOB0aZWT2W+rbw/d9Wg==
X-Received: by 2002:a62:6c6:: with SMTP id 189mr31398706pfg.36.1556089534033;
        Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUjZsRBut1k3oAXJcFzshMr8jKokQCkw8Ks9iBgQAA+wt/i32Da1CPU4BTFBBGBbr2rv+c
X-Received: by 2002:a62:6c6:: with SMTP id 189mr31398596pfg.36.1556089532567;
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556089532; cv=none;
        d=google.com; s=arc-20160816;
        b=ow8fqRNksvTAj3Z0n78U5nxY9tpPIozIy8Qe6vyZj0nBiSTASXaeOv9MyJs7Dc6zpX
         maSTcdCOrug8xKpp8CmEBr3dmvvXuVAagSIZc5dX+lNROB70iHTET363mMYqU0fTPdNH
         71QNzDJeX29A/K4+wtgBPWfyAfnC3NCwFXIMFSHBHYnkBuuwr24kduUeGI6QPENJYZQi
         /RLjbyOt/3Tm2PXhyUlNAIirMvL5jeyR45OzSlUUni7mwcE7wLjzz9t1a5503rBMWEQx
         3fjMElfjuJBATqWHQmrEzTHu3LLuTBG5LtRC/ldn2S0s54mginzAPtp+RDB6qx8sjXKb
         OZJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=ebwJstrYPGxLraDC5I7RtOjkKdQk5KZQ7JsOvQG501E=;
        b=OBrsvgKG9WjMLh4DCdcA5VxUREL7U3uyiyouLWe6xAANdMZqm1Omx8dHi9Wcdvtw9E
         n4llHpK8o6x0wYaHCiy+Ekpc5Og+Cd8SNtMetoAUtesJqWjHwMu3IZSOWiRmVcNQ725E
         zeoXPylRZOmPDNnjaq0WxSZwF5HP9KhRwB8dXnZVO5Ww4dFstNmtFE+BXkqokD/Gy5W3
         Ijy+TXMVXb9K/A+oeNndXB4wMV/Aq/3YhTUhjeFF75vjeURR0YPa3AvXAEcYisgcUVnH
         4PVOTSqNXzIgS8qjyGqiDgPYxAus/9ODAVS7UHpGGcQflZEgeGxuA4g58U9I7nMhQIvQ
         HYnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id h66si16940034pgc.418.2019.04.24.00.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 24 Apr 2019 00:05:31 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 92F02B2410;
	Wed, 24 Apr 2019 03:05:31 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 1/4] mm/balloon_compaction: list interfaces
Date: Tue, 23 Apr 2019 16:45:28 -0700
Message-ID: <20190423234531.29371-2-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190423234531.29371-1-namit@vmware.com>
References: <20190423234531.29371-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
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
 mm/balloon_compaction.c            | 144 +++++++++++++++++++++--------
 2 files changed, 110 insertions(+), 38 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index f111c780ef1d..430b6047cef7 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -64,6 +64,10 @@ extern struct page *balloon_page_alloc(void);
 extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 				 struct page *page);
 extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
+extern size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+				      struct list_head *pages);
+extern size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				     struct list_head *pages, size_t n_req_pages);
 
 static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 {
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d547e2d..a2995002edc2 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -10,6 +10,105 @@
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
 
+static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
+				     struct page *page)
+{
+	/*
+	 * Block others from accessing the 'page' when we get around to
+	 * establishing additional references. We should be the only one
+	 * holding a reference to the 'page' at this point. If we are not, then
+	 * memory corruption is possible and we should stop execution.
+	 */
+	BUG_ON(!trylock_page(page));
+	list_del(&page->lru);
+	balloon_page_insert(b_dev_info, page);
+	unlock_page(page);
+	__count_vm_event(BALLOON_INFLATE);
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
+				 struct list_head *pages)
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
+ * Driver must call this function to properly de-allocate a previous enlisted
+ * balloon pages before definetively releasing it back to the guest system.
+ * This function tries to remove @n_req_pages from the ballooned pages and
+ * return them to the caller in the @pages list.
+ *
+ * Note that this function may fail to dequeue some pages temporarily empty due
+ * to compaction isolated pages.
+ *
+ * Return: number of pages that were added to the @pages list.
+ */
+size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				 struct list_head *pages, size_t n_req_pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	size_t n_pages = 0;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
+		if (n_pages == n_req_pages)
+			break;
+
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
+		++n_pages;
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
@@ -43,17 +142,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
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
 
@@ -70,36 +161,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
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
@@ -112,9 +180,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
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

