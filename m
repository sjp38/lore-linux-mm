Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6D74C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 03:06:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8955204EC
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 03:06:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8955204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 455868E0001; Wed, 17 Jul 2019 23:06:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4080F6B000C; Wed, 17 Jul 2019 23:06:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F6108E0001; Wed, 17 Jul 2019 23:06:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECB1F6B000A
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:06:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so13149110pla.18
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 20:06:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Uz7KYsL+7jV0ZNh7sINRT1FSeHHySffyy9Z9T7LnA+Q=;
        b=C9Ead9EFG/OEOkxfJFcJVlKtR3g+xiH+ytbxKjwtpWTGD8zSJDpPArWBKGRi6kVmUN
         nvlFBgfXkRsgjU2OVbinsNczfk6ZuFW1twYIsDz4U1vh5EdHeQw2t3YdVmGTg7/cXT8V
         151KZs0iGvyjZzSV6koNWdZ/gYE9hH+4wRJugtGYn6Sa3E0GnDwlGoUqbzi+lMsuG/DS
         rikZ/maE9URNnvUeNcMQt4Cl1imuapEIEbvLmc4DSLVyGoxdNsTf9Pcz8EfPhGHUDWiC
         LoEA+zozp4WdnGl83Sibdef6QvlCVWwVOoj5vn9QzN1VspPLr8DPk7aqhOkn0bUOkgO3
         rWIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUP7z5GaBcKgdL0Zlxu2JX0MQ7ATKZu3bJTkeklSRyo6s+dT6Xm
	nNfhs8ioHFr2Y1V5nGQyp2TD7sJ6Cu0cHcx3Hu1ce4e4knCY7CQ6EhtSoH+pkz/05/bC66hmzsL
	bZPy8QuDM90bJriZv81dJbyWHnd6QaPmnhEybqAzzMFviBPwRyCXr/Jf8MIVR6YX9Pw==
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr47389647pju.67.1563419213604;
        Wed, 17 Jul 2019 20:06:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGi0gTMDydsMkBpKGMt5xobQgnhggG5zD5YGtyB4hB1r0NjZuEppEkkA1Y9JNF9fPlQt4y
X-Received: by 2002:a17:90a:cb97:: with SMTP id a23mr47389581pju.67.1563419212767;
        Wed, 17 Jul 2019 20:06:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563419212; cv=none;
        d=google.com; s=arc-20160816;
        b=W72G1sziTFyXY/kRckpZyiuIbptl52VKqBVI64Izp95dxQk9X68MV3BlXYrTLf+QzZ
         wg3VpNNuain2xDJQ1X7OxWaPrcu0gVlwYGHhBVsxO6dUcMHfO/SwG9o5bM2fdx9lZ31T
         vfSBiq+bLbKRRN19Tx5PZKqCl/XBH3oWJs8ASKCCn2h9HR+KvhrGVizF+zVL61vEcObF
         e75hGFTvOuNEHWGW/bkVAHdWsPbHYGU4SQiQWoI6sXYnPpIE1BXUDA9VojYicue8tKB/
         v5zI2qKbUhX2BBW1PyeZO8SkBsnW0ck/0/ONW+r3dziOJkKWeetRQdvSdXccQhyowb9u
         MISg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Uz7KYsL+7jV0ZNh7sINRT1FSeHHySffyy9Z9T7LnA+Q=;
        b=R2KmX2YQeOsaZPoG1fByRleQceBl89eR0BIYp4r1JW9WpCsGUGuIQteq3oGgqjCROg
         eHKm4Xmtgr03bJudr82RrdX35LaERJYzGL4CN3+O37Yg49dL56RQ5GX+nyjXtTWWlLOa
         +yvta/Pq45TRE57SncAbEwowz4WGdesCbMbhmGWUZNVNK+fwyrD8QVMtqvt+UyrpIRu1
         4sWL+5bzlaWn67K9YWD8pRnSkC478nifmKG9neQVHq78p1UrY2K+PE/yBYzUCw5A5qI1
         iYHWFBJ0hOEGcvdQ965Fo+VQ8JUfHiFbem1eQeu9vZQxm79YVAqedyL+oygaM4MyedJy
         oNuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id y14si1233284pfr.82.2019.07.17.20.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 20:06:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jul 2019 20:06:52 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="175892069"
Received: from devel-ww.sh.intel.com ([10.239.48.128])
  by FMSMGA003.fm.intel.com with ESMTP; 17 Jul 2019 20:06:49 -0700
From: Wei Wang <wei.w.wang@intel.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org,
	mst@redhat.com,
	xdeguillard@vmware.com,
	namit@vmware.com
Cc: akpm@linux-foundation.org,
	pagupta@redhat.com,
	riel@surriel.com,
	dave.hansen@intel.com,
	david@redhat.com,
	konrad.wilk@oracle.com,
	yang.zhang.wz@gmail.com,
	nitesh@redhat.com,
	lcapitulino@redhat.com,
	aarcange@redhat.com,
	pbonzini@redhat.com,
	alexander.h.duyck@linux.intel.com,
	dan.j.williams@intel.com
Subject: [PATCH v1] mm/balloon_compaction: avoid duplicate page removal
Date: Thu, 18 Jul 2019 10:23:30 +0800
Message-Id: <1563416610-11045-1-git-send-email-wei.w.wang@intel.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)

A #GP is reported in the guest when requesting balloon inflation via
virtio-balloon. The reason is that the virtio-balloon driver has
removed the page from its internal page list (via balloon_page_pop),
but balloon_page_enqueue_one also calls "list_del"  to do the removal.
So remove the list_del in balloon_page_enqueue_one, and have the callers
do the page removal from their own page lists.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 mm/balloon_compaction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 83a7b61..1a5ddc4 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -11,6 +11,7 @@
 #include <linux/export.h>
 #include <linux/balloon_compaction.h>
 
+/* Callers ensure that @page has been removed from its original list. */
 static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
 				     struct page *page)
 {
@@ -21,7 +22,6 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
 	 * memory corruption is possible and we should stop execution.
 	 */
 	BUG_ON(!trylock_page(page));
-	list_del(&page->lru);
 	balloon_page_insert(b_dev_info, page);
 	unlock_page(page);
 	__count_vm_event(BALLOON_INFLATE);
@@ -47,6 +47,7 @@ size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
 
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	list_for_each_entry_safe(page, tmp, pages, lru) {
+		list_del(&page->lru);
 		balloon_page_enqueue_one(b_dev_info, page);
 		n_pages++;
 	}
-- 
2.7.4

