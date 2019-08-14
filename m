Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5647C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75B222084D
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 02:18:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75B222084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9345D6B0007; Tue, 13 Aug 2019 22:18:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E6B56B0008; Tue, 13 Aug 2019 22:18:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64D3C6B000A; Tue, 13 Aug 2019 22:18:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0111.hostedemail.com [216.40.44.111])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1676B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 22:18:26 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DE4A6180AD7C3
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:25 +0000 (UTC)
X-FDA: 75819424170.25.pies59_f5ab19235d2c
X-HE-Tag: pies59_f5ab19235d2c
X-Filterd-Recvd-Size: 3866
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 02:18:25 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 19:18:25 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,382,1559545200"; 
   d="scan'208";a="181365548"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga006.jf.intel.com with ESMTP; 13 Aug 2019 19:18:23 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mgorman@techsingularity.net,
	vbabka@suse.cz,
	osalvador@suse.de
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part for __vma_link_list
Date: Wed, 14 Aug 2019 10:17:55 +0800
Message-Id: <20190814021755.1977-3-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190814021755.1977-1-richardw.yang@linux.intel.com>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just make the code a little easy to read.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>

---
Note: For nommu part, the code is not tested.
---
 mm/internal.h |  1 +
 mm/mmap.c     | 12 +-----------
 mm/nommu.c    |  8 +-------
 mm/util.c     | 14 ++++++++++++++
 4 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 41a49574acc3..4736aeb37dae 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -291,6 +291,7 @@ static inline bool is_data_mapping(vm_flags_t flags)
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev);
+void __vma_unlink_list(struct mm_struct *mm, struct vm_area_struct *vma);
 
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
diff --git a/mm/mmap.c b/mm/mmap.c
index 3fde0ec18554..aa66753b175e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -677,18 +677,8 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 						struct vm_area_struct *vma,
 						struct vm_area_struct *ignore)
 {
-	struct vm_area_struct *prev, *next;
-
 	vma_rb_erase_ignore(vma, &mm->mm_rb, ignore);
-	next = vma->vm_next;
-	prev = vma->vm_prev;
-	if (prev)
-		prev->vm_next = next;
-	else
-		mm->mmap = next;
-	if (next)
-		next->vm_prev = prev;
-
+	__vma_unlink_list(mm, vma);
 	/* Kill the cache */
 	vmacache_invalidate(mm);
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index 12a66fbeb988..1a403f65b99e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -673,13 +673,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
 	/* remove from the MM's tree and list */
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 
-	if (vma->vm_prev)
-		vma->vm_prev->vm_next = vma->vm_next;
-	else
-		mm->mmap = vma->vm_next;
-
-	if (vma->vm_next)
-		vma->vm_next->vm_prev = vma->vm_prev;
+	__vma_unlink_list(mm, vma);
 }
 
 /*
diff --git a/mm/util.c b/mm/util.c
index 80632db29247..5f113cd0acad 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -281,6 +281,20 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		next->vm_prev = vma;
 }
 
+void __vma_unlink_list(struct mm_struct *mm, struct vm_area_struct *vma)
+{
+	struct vm_area_struct *prev, *next;
+
+	next = vma->vm_next;
+	prev = vma->vm_prev;
+	if (prev)
+		prev->vm_next = next;
+	else
+		mm->mmap = next;
+	if (next)
+		next->vm_prev = prev;
+}
+
 /* Check if the vma is being used as a stack by this task */
 int vma_is_stack_for_current(struct vm_area_struct *vma)
 {
-- 
2.17.1


