Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2905FC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51358206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:14:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51358206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85A206B000D; Thu, 25 Apr 2019 15:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BF676B000C; Thu, 25 Apr 2019 15:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5805E6B0010; Thu, 25 Apr 2019 15:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 089906B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:14:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w9so345291plz.11
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:14:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=MJ2/+qJkQoCzOEhqSSUNBJImKDLsp06Ga689ZYuXD/0=;
        b=c0Un+pLBeBleS2Eal23BhtSol6+sgalLNFxIturnJY87nSGfMQ3mfOIZOAX7ZyNb5G
         3h5rFjN5qUZKuyqR19f8ZJT6idOJ+G7CODm30ABNXx4UKGto1hY9Tm0MVC0KfgVj9Xel
         ISu/E2EPPCQpb+j4NtZaCjlL9QmXQiPJPQQ5M4UouipDhK3q+gD1bEI47Lt9MViNFHVP
         dliDedOVvSBNXWjlmWDE8CfbI7SUCfMBRo0l0pypFfk+q7C5QtLK66QGTouN4ae2ajmk
         X9m6r5j9iSoJ3ooRbwAtESyRqwlxs9HXLxBmLo9eQj/rmXQZMx1UYI5Eh93DH/1Oyi0H
         2sjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVCKM+4clj6ye/K1HM+3g7LJT/rCtCZ7remDUmB1hEIoxzWy/2X
	BC3yh6dhDZY9PUJT/fPdy5MWw4yoplQV+bc9hWyc+pyLIjn7R+2oIwO49D7LSQBg4lNX83oJ8fI
	u++IwREeVH5c8Dk8GuIWrO/EGTmKF0MdDRpHuAf6Qm5Jc63m8rrqyxlIPk6Oikj9Nlw==
X-Received: by 2002:a63:5349:: with SMTP id t9mr2188048pgl.327.1556219675682;
        Thu, 25 Apr 2019 12:14:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqww7+dn9kbX1T9G4mmiZMfcj4kHQ/oT1a3LN3kBdmeyz+KoHvocQhu8a+/u2uKGxKA4Quby
X-Received: by 2002:a63:5349:: with SMTP id t9mr2187937pgl.327.1556219674139;
        Thu, 25 Apr 2019 12:14:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556219674; cv=none;
        d=google.com; s=arc-20160816;
        b=YzkcUuvRaEgyBrzsoHfmv7mJQoO88ke4KHDm3EalWUdaythwrmhDy6tpFTUimP8c3g
         SVCffVdXGs7xbahHNUfNde0FqeBdRsxvX/Pmtb+03ZjfUlsJVJHbpHRJVudIemk9YHyh
         FMH1trqe7sb/XxD2A32LlpiYLLWA3p8+BlHlwYHDpTI4CFEE1NrLNWovnGVWCRnwBlRo
         2QJ8FKcb2MODgh3HXjQiFyfU3QGlkyyfJciP+2CSB+/zTdxaYWONnXpDWuABNIG5VMOt
         wn9i7IzLtdbFqg1nD4yqyrDMqP4tYkkkGSLfnRdIF88cCXitPpNoiGzNSmhoRnvkqfU+
         21mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=MJ2/+qJkQoCzOEhqSSUNBJImKDLsp06Ga689ZYuXD/0=;
        b=W6Xd/xkC+gaUFR5u+nbJ1fbNalAQ77Cc8idnAg63LuHSTuprjQTBLW08qVkjEwevlG
         INdyasVnRnwxnZbGMiRcnuMOuCFNniZ7Vyb4JY+Z10BevHsHNrpo9OHCiUHCOLkVlVmw
         wtkO4M8G5lbVTctzTzN5mQwzclZFu7iwXAHrTO2LcOSSPbAR60pbd6l9mpylLIOpLpxE
         TS7n8+yUT+edjUZzQguDAEnN1+rvCPfraigVrrdsnRI9tuVsqRGQLW8Ze/F5gKYmz1BQ
         LEkH7PvuPw1dwybgGDHjacQpLC3TLZ8qxSlAehQEW8TiVQfWollO7i/cKRXcWi/tyYBw
         rdIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id a85si23305392pfj.12.2019.04.25.12.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 12:14:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Thu, 25 Apr 2019 12:14:31 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 74328412D1;
	Thu, 25 Apr 2019 12:14:32 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Michael S. Tsirkin"
	<mst@redhat.com>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>,
	<linux-kernel@vger.kernel.org>, <virtualization@lists.linux-foundation.org>,
	<linux-mm@kvack.org>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v4 4/4] vmw_balloon: Split refused pages
Date: Thu, 25 Apr 2019 04:54:45 -0700
Message-ID: <20190425115445.20815-5-namit@vmware.com>
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

