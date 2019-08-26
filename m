Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B9A5C41514
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C78B206BA
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C78B206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D86E6B0537; Mon, 26 Aug 2019 03:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AFD56B0539; Mon, 26 Aug 2019 03:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C52A6B053A; Mon, 26 Aug 2019 03:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 680536B0537
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:31:46 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1217D181AC9AE
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:31:46 +0000 (UTC)
X-FDA: 75863759412.22.iron02_66a9b6817143f
X-HE-Tag: iron02_66a9b6817143f
X-Filterd-Recvd-Size: 3512
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:31:45 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Aug 2019 00:31:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,431,1559545200"; 
   d="scan'208";a="196992425"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga001.fm.intel.com with ESMTP; 26 Aug 2019 00:31:43 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	vbabka@suse.cz,
	kirill.shutemov@linux.intel.com,
	yang.shi@linux.alibaba.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH 1/2] mm/mmap.c: update *next* gap after itself
Date: Mon, 26 Aug 2019 15:31:05 +0800
Message-Id: <20190826073106.29971-2-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190826073106.29971-1-richardw.yang@linux.intel.com>
References: <20190826073106.29971-1-richardw.yang@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since we link a vma to the leaf of a rb_tree, *next* must be a parent of
vma if *next* is not NULL. This means if we update *next* gap first, it
will be re-update again if vma's gap is bigger.

For example, we have a vma tree like this:

                a
                [0x9000, 0x10000]
            /            \
        b                 c
        [0x8000, 0x9000]  [0x10000, 0x11000]

The gap for each node is:

  a's gap = 0x8000
  b's gap = 0x8000
  c's gap = 0x0

Now we want to insert d [0x6000, 0x7000], then the tree look like this:

                a
                [0x9000, 0x10000]
            /            \
        b                 c
        [0x8000, 0x9000]  [0x10000, 0x11000]
     /
    d
    [0x6000, 0x7000]

b is the *next* of d. If we update b's gap first, it would be 0x1000 and
propagate to a. And then when update d's gap, which is 0x6000 and
propagate through b to a again.

If we update d's gap first, the un-consistent gap 0x1000 will not be
propagated.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/mmap.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index aa66753b175e..672ad7dc6b3c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -587,12 +587,6 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
-	/* Update tracking information for the gap following the new vma. */
-	if (vma->vm_next)
-		vma_gap_update(vma->vm_next);
-	else
-		mm->highest_vm_end = vm_end_gap(vma);
-
 	/*
 	 * vma->vm_prev wasn't known when we followed the rbtree to find the
 	 * correct insertion point for that vma. As a result, we could not
@@ -605,6 +599,13 @@ void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	vma->rb_subtree_gap = 0;
 	vma_gap_update(vma);
+
+	/* Update tracking information for the gap following the new vma. */
+	if (vma->vm_next)
+		vma_gap_update(vma->vm_next);
+	else
+		mm->highest_vm_end = vm_end_gap(vma);
+
 	vma_rb_insert(vma, &mm->mm_rb);
 }
 
-- 
2.17.1


