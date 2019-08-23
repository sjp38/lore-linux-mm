Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACAC8C3A589
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 04:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B1772341F
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 04:02:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B1772341F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AEE26B0378; Fri, 23 Aug 2019 00:02:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05F8E6B0379; Fri, 23 Aug 2019 00:02:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB6F16B037A; Fri, 23 Aug 2019 00:02:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0146.hostedemail.com [216.40.44.146])
	by kanga.kvack.org (Postfix) with ESMTP id C582C6B0378
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 00:02:40 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 2BA3E181AC9B4
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:02:40 +0000 (UTC)
X-FDA: 75852346080.09.field70_8a95fbb5ea234
X-HE-Tag: field70_8a95fbb5ea234
X-Filterd-Recvd-Size: 2417
Received: from huawei.com (szxga06-in.huawei.com [45.249.212.32])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 04:02:32 +0000 (UTC)
Received: from DGGEMS404-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 267FDE5CCF27578339CD;
	Fri, 23 Aug 2019 12:02:19 +0800 (CST)
Received: from huawei.com (10.90.53.225) by DGGEMS404-HUB.china.huawei.com
 (10.3.19.204) with Microsoft SMTP Server id 14.3.439.0; Fri, 23 Aug 2019
 12:02:10 +0800
From: zhengbin <zhengbin13@huawei.com>
To: <akpm@linux-foundation.org>, <kirill.shutemov@linux.intel.com>,
	<jglisse@redhat.com>, <mike.kravetz@oracle.com>, <rcampbell@nvidia.com>,
	<ktkhai@virtuozzo.com>, <aryabinin@virtuozzo.com>, <hughd@google.com>,
	<linux-mm@kvack.org>
CC: <yi.zhang@huawei.com>, <zhengbin13@huawei.com>
Subject: [PATCH] mm/rmap.c: remove set but not used variable 'cstart'
Date: Fri, 23 Aug 2019 12:08:41 +0800
Message-ID: <1566533321-23131-1-git-send-email-zhengbin13@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fixes gcc '-Wunused-but-set-variable' warning:

mm/rmap.c: In function page_mkclean_one:
mm/rmap.c:906:17: warning: variable cstart set but not used [-Wunused-but-set-variable]

It is not used since commit 0f10851ea475 ("mm/mmu_notifier:
avoid double notification when it is useless")

Reported-by: Hulk Robot <hulkci@huawei.com>
Signed-off-by: zhengbin <zhengbin13@huawei.com>
---
 mm/rmap.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e..31352bb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -903,10 +903,9 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	mmu_notifier_invalidate_range_start(&range);

 	while (page_vma_mapped_walk(&pvmw)) {
-		unsigned long cstart;
 		int ret = 0;

-		cstart = address = pvmw.address;
+		address = pvmw.address;
 		if (pvmw.pte) {
 			pte_t entry;
 			pte_t *pte = pvmw.pte;
@@ -933,7 +932,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-			cstart &= PMD_MASK;
 			ret = 1;
 #else
 			/* unexpected pmd-mapped page? */
--
2.7.4


