Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FB25C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29AAC206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:09:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29AAC206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5E66B0007; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6D886B0008; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE74A6B000D; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 690DA6B0008
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:09:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u8so14550496pfm.6
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BHbdRneIMKhLzM9N0cVkceZICuGt+ehqBdRC6oi9jeo=;
        b=fLzFB7UQBy0qxpj6ys5te72kxtBp8WiLNHlihLbrCW5+yGOIiV/eRsd2zlkoAd4YJE
         s1FoQQps2fFTCbg2VAB2XKXMOt6FpAb2UfNSgE9pd2w4/Z41cAhsSaWZat5Ww5f4AhcP
         GpJj1126xoodhkh3OugBfgx1ZyK9RuFOg+cXQLTbCJFkKPHkvuIn4oDlitktgGdl2Prj
         CIdrEnRxdWsQfqSz4Ls9BeptRL7BE3vkdy/JuLpokmSp/aR50DkcOe1pKLoRFAy8YvS/
         abMVniqZojJ18S7pDZsDINpiWabLjPHOKiKIjx/jsL4FtxR3rM2w6hhCUlAXcWqhRMqg
         pB3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWwR4jvbvE93BX9TXrteoVa188VQBnAubsDNgyUnBsqZe0I009u
	OiRBVDv9+VnXqKqOaz9TEIjSsSFg4fXfoV9F8WCkSxfqYDogscMu6FjcJxo7EImX+46liIeoo4D
	0TiHekBMs3o0JrFON6OiVVjLqU3kLoABQHOQLZyiXpkWfx35ahp4SRE0pkNTzRDvq2Q==
X-Received: by 2002:a63:cc0e:: with SMTP id x14mr35975640pgf.159.1553706572057;
        Wed, 27 Mar 2019 10:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHM5lRxP+lFX88kdUmzGjSHlFDCWozDqIvjO9XMIyJnIr1h0j8J6I0Ylgo9EPjmvEj0aKn
X-Received: by 2002:a63:cc0e:: with SMTP id x14mr35975510pgf.159.1553706570626;
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706570; cv=none;
        d=google.com; s=arc-20160816;
        b=v7i5n/+NrY6o3s0kD3VZImJOYOIaKfBQ51fmsJAjKzioGgf5BilNeCvewsHdPFNFGJ
         0TiFEB/IH2lrGoin49013Rilv0PUUPaO6XUot0g4Ba5X0HRznpgIpwvQ+JmGwMyrgNS6
         cPAIfVnVcBgpwQJA8wGn7sn7esM1Lqyao97e+bnF28p29UuKgJaZ0pIo3j/kZyVfXp+R
         Nbv5nJG8Fgg8CQca26JQB1TupAyEqjEgiq3jDHy4Zef0kOdaLHhnYP44NjCv5v6dnfWn
         4X6G2MF/lJekVOQe4wKDTEf+8HQXlFjE6/9zLAM2CQYKPD+udMp3/FfW6QBp1uRcPmO6
         QqXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=BHbdRneIMKhLzM9N0cVkceZICuGt+ehqBdRC6oi9jeo=;
        b=wSQRRYXfzQyN90IlnjwTVizjdwSSNq81oYo9QvZkCP7nkJb+7tuaDnR1bzJ3vPy8oq
         etLxplF2AwzWGz2PkE5tWGHkz2Zj54OBMMbUKuVaHb20lcZs/+Io+kqrpZ1La6wr3Q1O
         AUyt8mt7nK+qf1y218C8fENr3Dh0BvFeHhJQ4BOwFKv89jGBURmRVWVQo5s39HdRzinF
         0OOZF7csXenSntxXq2ZQTuywgshTexEhjqljXurHpOv4e9cF20TMgpnC9m38Vy7IN6os
         tZ1f5crk9G4C1rFamTp3sckNYck4c8bBYUoBUKVS7lhPV1jFkNX47KebpNJnbZFS9RAj
         j6vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id v31si20196984plg.2.2019.03.27.10.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Mar 2019 10:09:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Wed, 27 Mar 2019 10:09:16 -0700
Received: from namit-esx4.eng.vmware.com (sc2-hs2-general-dhcp-219-51.eng.vmware.com [10.172.219.51])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id EA139B212A;
	Wed, 27 Mar 2019 13:09:29 -0400 (EDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	<virtualization@lists.linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>, Nadav Amit <nadav.amit@gmail.com>, Nadav
 Amit <namit@vmware.com>
Subject: [PATCH v2 4/4] vmw_balloon: split refused pages
Date: Thu, 28 Mar 2019 01:07:18 +0000
Message-ID: <20190328010718.2248-5-namit@vmware.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190328010718.2248-1-namit@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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
index 59d3c0202dcc..65ce8b41cd66 100644
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

