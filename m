Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40AF8C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F03D52147C
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:57:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F03D52147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D9918E0006; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 539288E0002; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26EB68E0007; Wed,  6 Feb 2019 18:57:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1D0E8E0006
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:57:13 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so6467937pfi.21
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:57:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=3cFMgb/nxYwqmGq4qg/P9OpklSsQlX+5KNK3YSshihQ=;
        b=oRTabEdceoOc9HxqKwRLlNE3EyurhnJZthJsHggh1OeMwfaXxjqc6rB0mgNC7/Fm8g
         HkYC/dSjw84asms1qM2PPz5hbJvA7FWAgS7W2mJuBz9gN4hZzqwcedan5+/NB7pRtKkd
         6Vd6/6PAl79MRAyuIkCxCIIprBW45JyaoZbKZGUy9CkotqPu2Ka1NgsXtdN0pl2yR+kY
         2bt95I/4rtNLZslXyspBcd3IcsJ3lAmNrI8J1u5IwlEdILBhdmzhXLc1BJxNWEHt8VF7
         QZaXSgPO43SRexbfXMIzmXsQeWaXHZi0d+WcfoodJB+Mm1WW4/jo1/m1LDT4GfxwJsSU
         AbYg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: AHQUAuZ+H9qio+j7y6VhKD36l6wMBbT50mm/x+GspWHPoiEdftMbAyih
	qDfg2onhwh9y7WlVSU46857PTv3rv6BzlEze58tnAnPBVTIB8HZYbgyoKID3Wa82NeDS6OTsnAj
	yf/ySEGC/RWqHO5A4+SjN2HfoaCDXyynZ6fuAzA4uBD222b36WO+0/SfEXWpfOIBUzA==
X-Received: by 2002:a63:f41:: with SMTP id 1mr12165411pgp.29.1549497433434;
        Wed, 06 Feb 2019 15:57:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ42+aE3Aq4665A6KW0PVjOOBNWLunaTpCjEmIfYIuG76J8068EZJkqhTXylJx+wz7x52Qd
X-Received: by 2002:a63:f41:: with SMTP id 1mr12165370pgp.29.1549497432488;
        Wed, 06 Feb 2019 15:57:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549497432; cv=none;
        d=google.com; s=arc-20160816;
        b=YH1gix3FZoy3zkeBKtmccpfmvcvlzUVZS8p+igG7i1oILtqt+x+W5d+Wyh9Rt/eG8P
         Ogz3JzPCmJdpF4/B9k/n4sE31rbCiRhtl9KszWqXTcNnvps9ILmCvwbyAe804xnoRjeX
         Y4csoLVkzhRXmijVJ1PYZOV0Fp2FaUSfEayRsM8xilLlvJoEsYMitZaEQjo6+WRR94t2
         w67iQXdlIhQhLbI0zdp4WL0OxV+pHwxQbB/uvzo7IGOSSTnq5OXwZr6AzHSOx8qvPmJS
         9f5Z6GGjMYxIAhAOEDWg3KDpJuD4p+mN98nr2masZGcxfqjfsqD0eqJ56kN+EsBWw1RU
         y18A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=3cFMgb/nxYwqmGq4qg/P9OpklSsQlX+5KNK3YSshihQ=;
        b=Pr9oHy3NDEXmUW0TCOGWGx+BfmjDoM0SjDgOIm7ULKgV2XWKSNwXRTDOt7c+Edfz7u
         TUXmuhiKo/0aEobhhK3JlRzRzFV+LnpwfOhtKmwA9YYjimfTcp6N/fijZ38+/JvHbybV
         P11O+lNTJDTZdtkR+r1ST3qjQN+dPnjT3MOzr1LIqYcGvcXNS0IEcYSrDFqFXUwyUeiz
         MwsAg8kTAj0kGUNBFQdPVhp85WTumyTP/+LUJfo8mqvx4wc7O17vGgqB+kMfrrPMaisd
         UvL1aO+N1lwQ3jCYJDlhrCX33/VCnCodPkfgWb0vdar6EF6QO2Qpr9peMe6tI2bdaP0D
         HT2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id e35si4567699pgb.548.2019.02.06.15.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 15:57:12 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 6 Feb 2019 15:56:37 -0800
Received: from ubuntu.localdomain (unknown [10.33.115.182])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id BAB2C40FBF;
	Wed,  6 Feb 2019 15:57:11 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>, <linux-kernel@vger.kernel.org>, Julien
 Freche <jfreche@vmware.com>, Nadav Amit <namit@vmware.com>, "Michael S.
 Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<linux-mm@kvack.org>, <virtualization@lists.linux-foundation.org>
Subject: [PATCH 3/6] mm/balloon_compaction: list interfaces
Date: Wed, 6 Feb 2019 15:57:03 -0800
Message-ID: <20190206235706.4851-4-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190206235706.4851-1-namit@vmware.com>
References: <20190206235706.4851-1-namit@vmware.com>
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
 mm/balloon_compaction.c            | 139 +++++++++++++++++++++--------
 2 files changed, 105 insertions(+), 38 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 53051f3d8f25..2c5a8e09e413 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -72,6 +72,10 @@ extern struct page *balloon_page_alloc(void);
 extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
 				 struct page *page);
 extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
+extern void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+				      struct list_head *pages);
+extern int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+				     struct list_head *pages, int n_req_pages);
 
 static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 {
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index ef858d547e2d..b8e82864f82c 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -10,6 +10,100 @@
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
+ */
+void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
+			       struct list_head *pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
+	list_for_each_entry_safe(page, tmp, pages, lru)
+		balloon_page_enqueue_one(b_dev_info, page);
+	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
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
+int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
+			       struct list_head *pages, int n_req_pages)
+{
+	struct page *page, *tmp;
+	unsigned long flags;
+	int n_pages = 0;
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
@@ -43,17 +137,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
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
 
@@ -70,36 +156,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
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
@@ -112,9 +175,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
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
2.17.1

