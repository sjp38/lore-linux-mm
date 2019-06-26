Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45798C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8D83214DA
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 13:10:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sJBruFOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8D83214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45A428E0005; Wed, 26 Jun 2019 09:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40A6E8E0002; Wed, 26 Jun 2019 09:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F9FF8E0005; Wed, 26 Jun 2019 09:10:30 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF16D8E0002
	for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 09:10:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so1716195pfo.22
        for <Linux-mm@kvack.org>; Wed, 26 Jun 2019 06:10:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=opO5RMkXYD+cDHitMAzTrap5fSpuloWy8AelrA+yk/o=;
        b=leiCxqLGtdajfq3aK45z7+EDnFec4YY5QUP19xhbIxAAUfPwdoVa700na8AiXINlAn
         ZMi88aHM1f5xGvsk53PQj2PXvFObPVuCUU7BTE7arwVNnUAfAfEcwq0wTx2X3BYVO83t
         SQbxhb3PjnYQZy77GtmcM7grxdv7PmSLOgySi+OgpG6Vp0bjDD+Y0oA7p/IUiYsoJaJf
         WVLAfAJYX4BFDqYF4hejfzt5Txhh39I5TGZGer2zwETJrXCGil2o56JLBSuxFEoBuU2A
         ++mWKjNtYTSEX/vKl5OvA/9VNZHlIJmRB1HVDEFagJYCtuwYj85/QbJ8jLXzXJpm3A03
         lZmA==
X-Gm-Message-State: APjAAAWAZDmzqHJLBB5v/okeMUquGoCjegSobJupTXD29X9GrDypsAcU
	isSKBpZc5UKV4ItwZ3pkePvmhZTMxqqPhjtTzxcQeE7MuOrX9dumFCMfs6PbEohXKtIrRVdLnl7
	+3+FS7yPG7z3mGWCsYaFZ1i6cG4EF2jvq3erw6W4b0NVXWEzoXBhf4glknNqACyaz9g==
X-Received: by 2002:a17:902:24c:: with SMTP id 70mr5434921plc.2.1561554629499;
        Wed, 26 Jun 2019 06:10:29 -0700 (PDT)
X-Received: by 2002:a17:902:24c:: with SMTP id 70mr5434841plc.2.1561554628494;
        Wed, 26 Jun 2019 06:10:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561554628; cv=none;
        d=google.com; s=arc-20160816;
        b=XfmwH1LTdcKsQOnoAFE12J1802l++vChHzgx/iEH6mPCvDQPq88Oyvarp61YQATcz3
         uwRPslbNaTupfN6efwR4JT7jc48gIQWIcRpwjKJEFWTCX69Yuz+wO5BRTptfVxbA/U6z
         fGeO4Rctma7nvDMDTurvSA8l45nSvlzqj56njGeRicgwpbYqJto11k0L7JhaZwwxp9Lp
         OMxbKYDnZjWcf0JaUq8IL37iejGc9NEeKqMoUnolx/rToBoPvl5PmWpoF4Hbio8WOBkM
         hkSbowfumd7/9GAYXfavrRhsV9CJTerUgkVMTUvG6rBkhN6NheTUczozkrDsx1PpMLaM
         6ViA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=opO5RMkXYD+cDHitMAzTrap5fSpuloWy8AelrA+yk/o=;
        b=Kh/vOSOTjggbeByE6Na0nrGs84AQT8r2IwliQZbzyuWs1sLIjKC0WnBkRIJseOz7Iy
         SyXAtBpWDeqLwQxq3Q4rWNAi4rbCcUxhxxU7wdnY3jfwSECd1KFA5N1hRMMlbdoZn52R
         cwsc6zhWwjXxiJsHlhdeLD81An1aDFWCtuZ4HVu+txcns8+j9fU1f/n9lTgiQwHzJpZ8
         nd6fQCH/Y/vqIbqTCa4p+hvP4DUmcVeWJ0SX83wNOYh57GXiASB6G/cniBIYLMMf06wQ
         75vjGH2PbB+Any1zrN2xBx/aRWqyUdkwtXsdEqaFN/JmaK8BjKltZbZsJaT+8qyZjqb9
         4sxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sJBruFOk;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b12sor1120230pgm.75.2019.06.26.06.10.28
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 06:10:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sJBruFOk;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=opO5RMkXYD+cDHitMAzTrap5fSpuloWy8AelrA+yk/o=;
        b=sJBruFOkU1pdY68j41Bmt5j3/69/hEkBrAX4Bp/SPQ6CqwEmjI51KZUNEziJRJmGmI
         E8vsukdW1rIBucMxnN+ym7qQai6Mtu2L4PKIzGzNpIs3ALajss1lnxvIS797IlEcocVy
         CB5SoYCSWJQAqcUwj/kukLpeWhO7TiA5YiMvRMSTVhO5C3ljUGriG/y53zuxCqil4i5t
         bYi9WglS8QScCREAjjCS3ixCsiacTwwfTOiRJ/c1ULq0KNSWc9s00o4VvYS3YoL/DiMt
         oSRSCGGS7cXtDlmIZGlb5ScX44Zoc3KoR5JQxVenDJ2C2WuuIZycPtS6gy6MwP8Y1bTD
         XlCw==
X-Google-Smtp-Source: APXvYqw5SVoQ7Z6nytDeDRYCYO28cK9DunjzJLV+rLqsiNAIPyNrv7UGLab3d/LLwAkh6fOmQEOWiQ==
X-Received: by 2002:a63:fe51:: with SMTP id x17mr3035587pgj.61.1561554627862;
        Wed, 26 Jun 2019 06:10:27 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7820:4fb0:dc47:8733:627e:cd6d])
        by smtp.gmail.com with ESMTPSA id i14sm27533585pfk.0.2019.06.26.06.10.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 06:10:26 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: Linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>,
	Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: [PATCHv4] mm/gup: speed up check_and_migrate_cma_pages() on huge page
Date: Wed, 26 Jun 2019 21:10:00 +0800
Message-Id: <1561554600-5274-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both hugetlb and thp locate on the same migration type of pageblock, since
they are allocated from a free_list[]. Based on this fact, it is enough to
check on a single subpage to decide the migration type of the whole huge
page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
similar on other archs.

Furthermore, when executing isolate_huge_page(), it avoid taking global
hugetlb_lock many times, and meanless remove/add to the local link list
cma_page_list.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux-kernel@vger.kernel.org
---
v3 -> v4: fix C language precedence issue

 mm/gup.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097..ffca55b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1342,19 +1342,22 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 	LIST_HEAD(cma_page_list);
 
 check_again:
-	for (i = 0; i < nr_pages; i++) {
+	for (i = 0; i < nr_pages;) {
+
+		struct page *head = compound_head(pages[i]);
+		long step = 1;
+
+		if (PageCompound(head))
+			step = (1 << compound_order(head)) - (pages[i] - head);
 		/*
 		 * If we get a page from the CMA zone, since we are going to
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
-		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
-			if (PageHuge(head)) {
+		if (is_migrate_cma_page(head)) {
+			if (PageHuge(head))
 				isolate_huge_page(head, &cma_page_list);
-			} else {
+			else {
 				if (!PageLRU(head) && drain_allow) {
 					lru_add_drain_all();
 					drain_allow = false;
@@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 				}
 			}
 		}
+
+		i += step;
 	}
 
 	if (!list_empty(&cma_page_list)) {
-- 
2.7.5

