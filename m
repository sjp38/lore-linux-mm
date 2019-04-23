Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A196C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 248DA2148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 07:05:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 248DA2148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDE166B0008; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E681B6B000A; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C43666B000C; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83A086B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:05:34 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l13so11629095pgp.3
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=MJ2/+qJkQoCzOEhqSSUNBJImKDLsp06Ga689ZYuXD/0=;
        b=llE9dI4fqnFDKa58dDtKFcRrDiBQSRZswl7hTPDsgXG0s0b/LXrEwTZseL84Zesrf5
         48mkq6iRWvkh+5o+zJy7vLi6A2JRdQyUJw2mqbkkmYGC2v/fsJQCU4o1ETW9tlGmkhkl
         ng89LbwHilOFEV8H3ivA3edvFk4JggOt7KyicneZLNw1YAeXevqfaSxfK7qRTSkNeQ3X
         83Ywn/XBvcMqCM4KRDoy1cNoyUSFR4dyGFesPB+GIBwWPf6npLWTbRW3i63wx7YAcFoc
         EC8PnkSJCaJfdtUkZcVf7C2ZXNZvf8O8Xy1bIL64VF6J3J5DW4MNATqR7GpWNcr389m/
         MdQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXfHrZiFqv81vbyn8YlhWNeSWImZLyGfSIimavPZuryhoPDelCj
	gKNu359oacPLjN2pZ0H7X2rf8iaF+SH0y+jTxZ+oYdEnD310pWFqbS8ZElDRmsFB02DuJLz36lQ
	TRh7Cbf1i2V1eMxFyejxAkrvLiJ2fzEkGG15SpgBdAADct0TXZwbTgbawF+4YfpnZTA==
X-Received: by 2002:aa7:9e9e:: with SMTP id p30mr32169151pfq.255.1556089534154;
        Wed, 24 Apr 2019 00:05:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsvUZhIwDa4I4dpvS78EmtZZ2C5r/YaKJVxE/pROjjELDAElWlwjSGprt9CZpP1nbmvtB+
X-Received: by 2002:aa7:9e9e:: with SMTP id p30mr32169028pfq.255.1556089532768;
        Wed, 24 Apr 2019 00:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556089532; cv=none;
        d=google.com; s=arc-20160816;
        b=lFFrQiwE2MLn+xwTY/ox5viJEcNhbbTwfNdfZf+omBBBGQapZKe6tzWgfim4aJYrn6
         iS3XDeG6s6z4oVfMyoNTwFIJv820HDzt2G6CsS4bfKcFigOdrG0Qay6Y0ZUTzyc9bWPf
         MYwxKLO7xdtszo348GfeLrAk5C7r91uBAszlpLygokau0XecRXuoTOvT8FOAD1FYQmba
         G6MEohzK1uJrVqC2e2RQq6BInLtcKjmeWkV4iWMF7+7c5lXu88/1d+oxKgb3fCuO2GKq
         WA1I2nn9qpfUGV3ecNnmXx9o9aOskSOhO9ygRlUieJpvy590WS5SYACBdpahFhv5Scox
         RH0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=MJ2/+qJkQoCzOEhqSSUNBJImKDLsp06Ga689ZYuXD/0=;
        b=cYriWGpafgMe7iEeo1hhWMkLEgpronjgLACdo6TrLKwqiOJ3KtLTlxCAX4lQEonMei
         kWyvsrcwjPHQnIyhs9RGRH8lgRuSFTkn9t4eRiMt748QsaxM9um/ZnK8c2JWbaNcqdIZ
         9Gp5f74b3j621nW1aXdbkb65kGbj02Pl4BtIJrD0JTbDHPBjKubxL4wQeDqdQFGwmhxo
         5MFGDVxip4khiafb8nQldB4Mt+SOL/iFWjkcVYRPKRnPYoRdIfTumW8KGtap0tu3A3es
         0SUMDU1Kw7VDnkFhKZbEvJy4VvhK1GQ6o9KAy7XiKddkZ3+/ZsTumxLsB5ioCmNs2K2S
         9KVA==
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
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id C5BA3B2416;
	Wed, 24 Apr 2019 03:05:31 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 4/4] vmw_balloon: split refused pages
Date: Tue, 23 Apr 2019 16:45:31 -0700
Message-ID: <20190423234531.29371-5-namit@vmware.com>
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

The hypervisor might refuse to inflate pages. While the balloon driver
handles this scenario correctly, a refusal to inflate a 2MB pages might
cause the same page to be allocated again later just for its inflation
to be refused again. This wastes energy and time.

To avoid this situation, split the 2MB page to 4KB pages, and then try
to inflate each one individually. Most of the 4KB pages out of the 2MB
should be inflated successfully, and the balloon is likely to prevent
the scenario of repeated refused inflation.

Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 drivers/misc/vmw_balloon.c | 63 +++++++++++++++++++++++++++++++-------
 1 file changed, 52 insertions(+), 11 deletions(-)

diff --git a/drivers/misc/vmw_balloon.c b/drivers/misc/vmw_balloon.c
index 4b5e939ff4c8..043eed845246 100644
--- a/drivers/misc/vmw_balloon.c
+++ b/drivers/misc/vmw_balloon.c
@@ -239,6 +239,7 @@ static DEFINE_STATIC_KEY_FALSE(balloon_stat_enabled);
 struct vmballoon_ctl {
 	struct list_head pages;
 	struct list_head refused_pages;
+	struct list_head prealloc_pages;
 	unsigned int n_refused_pages;
 	unsigned int n_pages;
 	enum vmballoon_page_size_type page_size;
@@ -668,15 +669,25 @@ static int vmballoon_alloc_page_list(struct vmballoon *b,
 	unsigned int i;
 
 	for (i = 0; i < req_n_pages; i++) {
-		if (ctl->page_size == VMW_BALLOON_2M_PAGE)
-			page = alloc_pages(__GFP_HIGHMEM|__GFP_NOWARN|
+		/*
+		 * First check if we happen to have pages that were allocated
+		 * before. This happens when 2MB page rejected during inflation
+		 * by the hypervisor, and then split into 4KB pages.
+		 */
+		if (!list_empty(&ctl->prealloc_pages)) {
+			page = list_first_entry(&ctl->prealloc_pages,
+						struct page, lru);
+			list_del(&page->lru);
+		} else {
+			if (ctl->page_size == VMW_BALLOON_2M_PAGE)
+				page = alloc_pages(__GFP_HIGHMEM|__GFP_NOWARN|
 					__GFP_NOMEMALLOC, VMW_BALLOON_2M_ORDER);
-		else
-			page = balloon_page_alloc();
+			else
+				page = balloon_page_alloc();
 
-		/* Update statistics */
-		vmballoon_stats_page_inc(b, VMW_BALLOON_PAGE_STAT_ALLOC,
-					 ctl->page_size);
+			vmballoon_stats_page_inc(b, VMW_BALLOON_PAGE_STAT_ALLOC,
+						 ctl->page_size);
+		}
 
 		if (page) {
 			vmballoon_mark_page_offline(page, ctl->page_size);
@@ -922,7 +933,8 @@ static void vmballoon_release_page_list(struct list_head *page_list,
 		__free_pages(page, vmballoon_page_order(page_size));
 	}
 
-	*n_pages = 0;
+	if (n_pages)
+		*n_pages = 0;
 }
 
 
@@ -1054,6 +1066,32 @@ static void vmballoon_dequeue_page_list(struct vmballoon *b,
 	*n_pages = i;
 }
 
+/**
+ * vmballoon_split_refused_pages() - Split the 2MB refused pages to 4k.
+ *
+ * If inflation of 2MB pages was denied by the hypervisor, it is likely to be
+ * due to one or few 4KB pages. These 2MB pages may keep being allocated and
+ * then being refused. To prevent this case, this function splits the refused
+ * pages into 4KB pages and adds them into @prealloc_pages list.
+ *
+ * @ctl: pointer for the %struct vmballoon_ctl, which defines the operation.
+ */
+static void vmballoon_split_refused_pages(struct vmballoon_ctl *ctl)
+{
+	struct page *page, *tmp;
+	unsigned int i, order;
+
+	order = vmballoon_page_order(ctl->page_size);
+
+	list_for_each_entry_safe(page, tmp, &ctl->refused_pages, lru) {
+		list_del(&page->lru);
+		split_page(page, order);
+		for (i = 0; i < (1 << order); i++)
+			list_add(&page[i].lru, &ctl->prealloc_pages);
+	}
+	ctl->n_refused_pages = 0;
+}
+
 /**
  * vmballoon_inflate() - Inflate the balloon towards its target size.
  *
@@ -1065,6 +1103,7 @@ static void vmballoon_inflate(struct vmballoon *b)
 	struct vmballoon_ctl ctl = {
 		.pages = LIST_HEAD_INIT(ctl.pages),
 		.refused_pages = LIST_HEAD_INIT(ctl.refused_pages),
+		.prealloc_pages = LIST_HEAD_INIT(ctl.prealloc_pages),
 		.page_size = b->max_page_size,
 		.op = VMW_BALLOON_INFLATE
 	};
@@ -1112,10 +1151,10 @@ static void vmballoon_inflate(struct vmballoon *b)
 				break;
 
 			/*
-			 * Ignore errors from locking as we now switch to 4k
-			 * pages and we might get different errors.
+			 * Split the refused pages to 4k. This will also empty
+			 * the refused pages list.
 			 */
-			vmballoon_release_refused_pages(b, &ctl);
+			vmballoon_split_refused_pages(&ctl);
 			ctl.page_size--;
 		}
 
@@ -1129,6 +1168,8 @@ static void vmballoon_inflate(struct vmballoon *b)
 	 */
 	if (ctl.n_refused_pages != 0)
 		vmballoon_release_refused_pages(b, &ctl);
+
+	vmballoon_release_page_list(&ctl.prealloc_pages, NULL, ctl.page_size);
 }
 
 /**
-- 
2.19.1

