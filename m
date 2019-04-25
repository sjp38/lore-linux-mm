Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5B10C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C73B206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C73B206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D66056B0005; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF8F36B000D; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87ED96B0005; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 477E66B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:14:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u78so532359pfa.12
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:14:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=A57QNDTm9gEfuLcDlXJiL+105CCH9ZSoNTY8WY5zPdc=;
        b=UqzweRDt0qEl52tv1fBYL4fRXz6IXyrghFJowujSCpnCKa0pKBZidrh/YlI2Wdc858
         jc3QIGyyzGr6gIimiNY54srI16TCnubC9CkElrjKYejkFn9cKZe8cE22uLFh6i08Oucs
         oN0alGRzrpqHxYzB441oEsbB8DJI64+OphN5oXw0+weaFd3vR+neCLkC3w7N4mw8sfgl
         UiaO6JHKXSxICzg04Ln8V6JO+6t24wY0MFhBbp2mLMa1c8J6sJIcsMyvzFWvCbQT63iF
         qKxRhNY+V53EU+HrT4TvqL0HGc7fMSEPm9Gg3zcQJDcXU/WOjVgcZj5zTq4QY4BJNIOU
         JrgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUD9NnBUTqDdLHwtVn6hsFdCrE+/ADvVzWX0g6uQDjVT1qS655T
	tqFFXakwZhpnDpXCKWZ+1WthnwgZY77luwbzRb+7chOW5opNLTXJFFJMvhSIYiYg1+xtzlDPiju
	jvgnNUENLJX/LCUscvURn0z10ga8dyYXsPipUBV5NaC5qp+BRC6R9Bp0flQ/7U48Q/g==
X-Received: by 2002:a63:f707:: with SMTP id x7mr38562856pgh.343.1556219674896;
        Thu, 25 Apr 2019 12:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEuwFuRMf13wYfE+TmPDq8FB3d1D/RH+p+Ihyyck7k7w3OQduXYTerNbV4cmTODzX4KFet
X-Received: by 2002:a63:f707:: with SMTP id x7mr38562761pgh.343.1556219673659;
        Thu, 25 Apr 2019 12:14:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556219673; cv=none;
        d=google.com; s=arc-20160816;
        b=wY8fFYM2iSxtTcpnR08cxLW0OFG30E6jyhQkanog/ZIYmhRwDsxd9H/I5Dgr47vtiE
         IK/5jZMNpXjbYTn69pzas9lV+N5eEFsOFwI0ghRnuR7t3PyPaMjU/BYq8hWYXLiHxX8J
         iaKsgvLJQ+ZbXeX0N7/UEjbTTNpn1iahIZlC8MDeH52ivfJ4CwbWorM4fNraSWCmuyXg
         hIbGMF/qdRk6sK3Bw9BRDo+teWiFiO3a5uua0zWeji44reTDC2gM/8/8TM8nqeAAbTD6
         1SVazoPQFCrHUrYdLXKExA9ymH3+b1OisIKp6nBvkGSRNBu5eU7SEGbIEKvGezqkyb5U
         cneg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=A57QNDTm9gEfuLcDlXJiL+105CCH9ZSoNTY8WY5zPdc=;
        b=stYpMsvdivDfidVeyQWI60h82HNkOk3jDhRzLvK80tce2/gDuiaefGJHvi3CN74b9s
         dn+l1nUAnuHDZEkyVuJ6x3Kh4gMkb1ROzFg5Yn3RwUKpk4YlkI/3y4mv6PfqTY7lRsjm
         Eu/+BkoWEoX8wwco8kMIRyiBzwhcp4HFbkWEUtuP029hlF/VKnyb9Dx1J0igG7TWGX8u
         Uub7LkVI+A4xEc9Zt/Y8bROXx+0spWXRWz/4/kwFGQEedl/yX/jBvNW8GA/B5s+FUQPs
         xmPRBHoPn+uOc2a3P6dvuuhOfAXpuzjrn/gy9jj/kfA6JKPCUCi625HtSJ7zMVSghhoR
         z5BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id a85si23305392pfj.12.2019.04.25.12.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 12:14:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Thu, 25 Apr 2019 12:14:31 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 5F9AD412C3;
	Thu, 25 Apr 2019 12:14:32 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v4 1/4] mm/balloon_compaction: List interfaces
Date: Thu, 25 Apr 2019 04:54:42 -0700
Message-ID: <20190425115445.20815-2-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190425115445.20815-1-namit@vmware.com>
References: <20190425115445.20815-1-namit@vmware.com>
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

Cc: Jason Wang <jasowang@redhat.com>
Cc: linux-mm@kvack.org
Cc: virtualization@lists.linux-foundation.org
Acked-by: Michael S. Tsirkin <mst@redhat.com>
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
index ef858d547e2d..b7bd72612c5a 100644
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
+		 * Block others from accessing the 'page' while we get around to
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
+		list_add(&page->lru, pages);
+		unlock_page(page);
+		n_pages++;
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

