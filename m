Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14875C32750
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D974520843
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D974520843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8A26B0006; Tue, 13 Aug 2019 22:18:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 589176B0007; Tue, 13 Aug 2019 22:18:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 477BC6B0008; Tue, 13 Aug 2019 22:18:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0107.hostedemail.com [216.40.44.107])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF046B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:18:25 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B9EC38248AA1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:24 +0000 (UTC)
X-FDA: 75819424128.06.land30_f2dc9d1d032b
X-HE-Tag: land30_f2dc9d1d032b
X-Filterd-Recvd-Size: 2413
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:24 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 19:18:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="181365545"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga006.jf.intel.com with ESMTP; 13 Aug 2019 19:18:21 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mgorman@techsingularity.net,
	vbabka@suse.cz,
	osalvador@suse.de
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH 2/3] mm/mmap.c: __vma_unlink_prev is not necessary now
Date: Wed, 14 Aug 2019 10:17:54 +0800
Message-Id: <20190814021755.1977-2-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190814021755.1977-1-richardw.yang@linux.intel.com>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The third parameter of __vma_unlink_common could differentiate these two
types. __vma_unlink_prev is not necessary now.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/mmap.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3d56340fea36..3fde0ec18554 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -693,13 +693,6 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 	vmacache_invalidate(mm);
 }
 
-static inline void __vma_unlink_prev(struct mm_struct *mm,
-				     struct vm_area_struct *vma,
-				     struct vm_area_struct *prev)
-{
-	__vma_unlink_common(mm, vma, vma);
-}
-
 /*
  * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
  * is already present in an i_mmap tree without adjusting the tree.
@@ -874,7 +867,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 		 * us to remove next before dropping the locks.
 		 */
 		if (remove_next != 3)
-			__vma_unlink_prev(mm, next, vma);
+			__vma_unlink_common(mm, next, next);
 		else
 			/*
 			 * vma is not before next if they've been
-- 
2.17.1


