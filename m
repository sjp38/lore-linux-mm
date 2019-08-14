Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15888C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A29ED20843
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A29ED20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2206B0005; Tue, 13 Aug 2019 22:18:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E62616B0006; Tue, 13 Aug 2019 22:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D76F76B0007; Tue, 13 Aug 2019 22:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0190.hostedemail.com [216.40.44.190])
	by kanga.kvack.org (Postfix) with ESMTP id B1A066B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:18:23 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 45C7F485F
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:23 +0000 (UTC)
X-FDA: 75819424086.05.eyes21_ef3f024fb74e
X-HE-Tag: eyes21_ef3f024fb74e
X-Filterd-Recvd-Size: 3340
Received: from mga05.intel.com (mga05.intel.com [192.55.52.43])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:22 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 19:18:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="205293131"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga002.fm.intel.com with ESMTP; 13 Aug 2019 19:18:19 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mgorman@techsingularity.net,
	vbabka@suse.cz,
	osalvador@suse.de
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH 1/3] mm/mmap.c: prev could be retrieved from vma->vm_prev
Date: Wed, 14 Aug 2019 10:17:53 +0800
Message-Id: <20190814021755.1977-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently __vma_unlink_common handles two cases:

  * has_prev
  * or not

When has_prev is false, it is obvious prev is calculated from
vma->vm_prev in __vma_unlink_common.

When has_prev is true, the prev is passed through from __vma_unlink_prev
in __vma_adjust for non-case 8. And at the beginning next is calculated
from vma->vm_next, which implies vma is next->vm_prev.

The above statement sounds a little complicated, while to think in
another point of view, no matter whether vma and next is swapped, the
mmap link list still preserves its property. It is proper to access
vma->vm_prev.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/mmap.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b8072630766f..3d56340fea36 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -675,23 +675,17 @@ static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 
 static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 						struct vm_area_struct *vma,
-						struct vm_area_struct *prev,
-						bool has_prev,
 						struct vm_area_struct *ignore)
 {
-	struct vm_area_struct *next;
+	struct vm_area_struct *prev, *next;
 
 	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
 	next = vma->vm_next;
-	if (has_prev)
+	prev = vma->vm_prev;
+	if (prev)
 		prev->vm_next = next;
-	else {
-		prev = vma->vm_prev;
-		if (prev)
-			prev->vm_next = next;
-		else
-			mm->mmap = next;
-	}
+	else
+		mm->mmap = next;
 	if (next)
 		next->vm_prev = prev;
 
@@ -703,7 +697,7 @@ static inline void __vma_unlink_prev(struct mm_struct *mm,
 				     struct vm_area_struct *vma,
 				     struct vm_area_struct *prev)
 {
-	__vma_unlink_common(mm, vma, prev, true, vma);
+	__vma_unlink_common(mm, vma, vma);
 }
 
 /*
@@ -891,7 +885,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			 * "next" (which is stored in post-swap()
 			 * "vma").
 			 */
-			__vma_unlink_common(mm, next, NULL, false, vma);
+			__vma_unlink_common(mm, next, vma);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);
 	} else if (insert) {
-- 
2.17.1


