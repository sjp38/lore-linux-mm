Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B79AAC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 10:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F202173B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 10:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F202173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12D006B0005; Thu, 18 Jul 2019 06:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DF548E0001; Thu, 18 Jul 2019 06:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0EEB6B000A; Thu, 18 Jul 2019 06:10:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBDB96B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 06:10:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d3so16420558pgc.9
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 03:10:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=IPnm+I9Usx31xFunRgPUzQdL2I/DsOB7LdpHa8iXcZk=;
        b=sevTGn8wYc1xVoPv8aaU+oKiRHfoWSdTfHz5Rk66KuQKwZ2fbBeRdzj4f4lSnibLIm
         7NiaOykjyFE28I4upK1DZPMEoK9/PnWfz5DMYlVvcl53ZGHS3eaLPckCnoPSmw7YqAEC
         rvUMojuDnfMoz9eTEduutUmH+krMlwP2/M/yNbLmR1pp6HSSurakh8byU949FzLFnMeJ
         yXJpPzDSo5IuIFYdSwt1OR+Us09kiS6OJzeWNEFNsPET9VmBpy5PwRoexP4O1SYbfz3h
         VQvT0yEi2wMofAFBh2Eo5Yvd9LzHGrP5m8xFiC0WE5283NLxepFO/IIwbB03fPqVutCw
         vZ8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUQ5fSDfHNAo5hNe2WACCV9ZIzXPmLSH5F7HPf3Gao5/u47/Xfx
	IPHaMH3Kdyp0Plrj4Om4nkPY5qBXLgTzWnn0Ut+be90emBrTFdddRPmFTQ3jXE3kvGDt8lztBvR
	VIt3bJIiirnozqN2zn3ivdf6/4TRrNe4Xo0q+Oi8Z4GNFXCDmK3Ys/fRfJnulgQkF/A==
X-Received: by 2002:a63:c751:: with SMTP id v17mr31175335pgg.264.1563444645310;
        Thu, 18 Jul 2019 03:10:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnJ0+SGe2GjsiEWPq+wNHK3FQn/JQQ+cKMtSdo20slj9uwNwDrHw0VOrwTSkFKdl+fMbTv
X-Received: by 2002:a63:c751:: with SMTP id v17mr31175232pgg.264.1563444643907;
        Thu, 18 Jul 2019 03:10:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563444643; cv=none;
        d=google.com; s=arc-20160816;
        b=O3skjRo9TWKQW0h1AMX3igr6LH/3sAh6ovq3U84Pzk/eQFKHdg/jfkS5Iy+Er2j1/e
         qEUYGKimsX2PaJPgzsRq3bCxO7/4nycErZMHTq3ruGWUjSI0DLW5QO8Y7lgpkn7pQa9B
         Va08ObYwR+wTOpVOZBqpQbeBMoGdg55C9afoK2M7xWWKfUKDGaubqBSHNKoJUGQfHBcr
         lh/YASmtQBhZviilnG44RthrslzLMsma88PwCFyD9FVZDVi2GiUckSO1/D4wsR+LMH/D
         j+7M9t8KfnR6EwBDpYtyVqACxHHryeiF3muTCq+o5D307VouXWkuXy5ulbFwwwMvw2CU
         zs8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=IPnm+I9Usx31xFunRgPUzQdL2I/DsOB7LdpHa8iXcZk=;
        b=1E7gN+7Dqb0e+/OLz0Cs8y8XhG0J+oggNTRdO8KF8T1K3wBvMksom9P7wpec6C1T/V
         7LqGDT2sJVISw6ITafu4r19rPQgyVcfkyQ8cxOHBgPOo/VawFEAc08Z921DM5dxHf11k
         AhaJmB1dmwTHsd4FpD2UiJAANFpXRwJD2Llc3+xHimjRi4bott3EMGwe9ycLlkvIe+Bn
         D8CJPiqm9jlUuMQu8nUUzKR8HxlVrAKanGX/7YOPTvyFSRf4t9IvEtqJhVNhC0eD3XCR
         76apEhQOPbNlbcmI5j3wpxILGvJAfDfwDO9CWBCbvbxLopGOleqoQbSm4TEy/Wpp3HNt
         o3fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c1si750797pgw.444.2019.07.18.03.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 03:10:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jul 2019 03:10:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,276,1559545200"; 
   d="scan'208";a="162031470"
Received: from devel-ww.sh.intel.com ([10.239.48.128])
  by orsmga008.jf.intel.com with ESMTP; 18 Jul 2019 03:10:39 -0700
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
Subject: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Date: Thu, 18 Jul 2019 17:27:20 +0800
Message-Id: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
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
This is necessary when it's used from balloon_page_enqueue_list, but
not from balloon_page_enqueue_one.

So remove the list_del balloon_page_enqueue_one, and update some
comments as a reminder.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
ChangeLong:
v1->v2: updated some comments

 mm/balloon_compaction.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 83a7b61..8639bfc 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -21,7 +21,6 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
 	 * memory corruption is possible and we should stop execution.
 	 */
 	BUG_ON(!trylock_page(page));
-	list_del(&page->lru);
 	balloon_page_insert(b_dev_info, page);
 	unlock_page(page);
 	__count_vm_event(BALLOON_INFLATE);
@@ -33,7 +32,7 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
  * @b_dev_info: balloon device descriptor where we will insert a new page to
  * @pages: pages to enqueue - allocated using balloon_page_alloc.
  *
- * Driver must call it to properly enqueue a balloon pages before definitively
+ * Driver must call it to properly enqueue balloon pages before definitively
  * removing it from the guest system.
  *
  * Return: number of pages that were enqueued.
@@ -47,6 +46,7 @@ size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
 
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
 	list_for_each_entry_safe(page, tmp, pages, lru) {
+		list_del(&page->lru);
 		balloon_page_enqueue_one(b_dev_info, page);
 		n_pages++;
 	}
@@ -128,13 +128,19 @@ struct page *balloon_page_alloc(void)
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
 
 /*
- * balloon_page_enqueue - allocates a new page and inserts it into the balloon
- *			  page list.
+ * balloon_page_enqueue - inserts a new page into the balloon page list.
+ *
  * @b_dev_info: balloon device descriptor where we will insert a new page to
  * @page: new page to enqueue - allocated using balloon_page_alloc.
  *
  * Driver must call it to properly enqueue a new allocated balloon page
  * before definitively removing it from the guest system.
+ *
+ * Drivers must not call balloon_page_enqueue on pages that have been
+ * pushed to a list with balloon_page_push before removing them with
+ * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
+ * instead.
+ *
  * This function returns the page address for the recently enqueued page or
  * NULL in the case we fail to allocate a new page this turn.
  */
-- 
2.7.4

