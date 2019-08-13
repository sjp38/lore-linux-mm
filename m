Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19879C31E40
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 03:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEA4420843
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 03:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEA4420843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B10F6B0005; Mon, 12 Aug 2019 23:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2618E6B0006; Mon, 12 Aug 2019 23:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1770F6B0007; Mon, 12 Aug 2019 23:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id E52146B0005
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:27:45 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 8B76D180AD7C1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:27:45 +0000 (UTC)
X-FDA: 75815970090.07.slave69_7de177b70823d
X-HE-Tag: slave69_7de177b70823d
X-Filterd-Recvd-Size: 3686
Received: from mga02.intel.com (mga02.intel.com [134.134.136.20])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:27:44 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 20:27:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,380,1559545200"; 
   d="scan'208";a="187646012"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga002.jf.intel.com with ESMTP; 12 Aug 2019 20:27:42 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mgorman@techsingularity.net,
	vbabka@suse.cz
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH] mm/mmap.c: rb_parent is not necessary in __vma_link_list
Date: Tue, 13 Aug 2019 11:26:56 +0800
Message-Id: <20190813032656.16625-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we use rb_parent to get next, while this is not necessary.

When prev is NULL, this means vma should be the first element in the
list. Then next should be current first one (mm->mmap), no matter
whether we have parent or not.

After removing it, the code shows the beauty of symmetry.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/internal.h | 2 +-
 mm/mmap.c     | 2 +-
 mm/nommu.c    | 2 +-
 mm/util.c     | 8 ++------
 4 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index e32390802fd3..41a49574acc3 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -290,7 +290,7 @@ static inline bool is_data_mapping(vm_flags_t flags)
 
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct vm_area_struct *prev, struct rb_node *rb_parent);
+		struct vm_area_struct *prev);
 
 #ifdef CONFIG_MMU
 extern long populate_vma_page_range(struct vm_area_struct *vma,
diff --git a/mm/mmap.c b/mm/mmap.c
index f7ed0afb994c..b8072630766f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -632,7 +632,7 @@ __vma_link(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_area_struct *prev, struct rb_node **rb_link,
 	struct rb_node *rb_parent)
 {
-	__vma_link_list(mm, vma, prev, rb_parent);
+	__vma_link_list(mm, vma, prev);
 	__vma_link_rb(mm, vma, rb_link, rb_parent);
 }
 
diff --git a/mm/nommu.c b/mm/nommu.c
index fed1b6e9c89b..12a66fbeb988 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -637,7 +637,7 @@ static void add_vma_to_mm(struct mm_struct *mm, struct vm_area_struct *vma)
 	if (rb_prev)
 		prev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
 
-	__vma_link_list(mm, vma, prev, parent);
+	__vma_link_list(mm, vma, prev);
 }
 
 /*
diff --git a/mm/util.c b/mm/util.c
index e6351a80f248..80632db29247 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -264,7 +264,7 @@ void *memdup_user_nul(const void __user *src, size_t len)
 EXPORT_SYMBOL(memdup_user_nul);
 
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
-		struct vm_area_struct *prev, struct rb_node *rb_parent)
+		struct vm_area_struct *prev)
 {
 	struct vm_area_struct *next;
 
@@ -273,12 +273,8 @@ void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		next = prev->vm_next;
 		prev->vm_next = vma;
 	} else {
+		next = mm->mmap;
 		mm->mmap = vma;
-		if (rb_parent)
-			next = rb_entry(rb_parent,
-					struct vm_area_struct, vm_rb);
-		else
-			next = NULL;
 	}
 	vma->vm_next = next;
 	if (next)
-- 
2.17.1


