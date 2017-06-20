Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 10B396B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p190so14245406wme.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 23:21:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l7si2683672wml.156.2017.06.19.23.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 23:21:06 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K6Ii41068580
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:05 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b6qen6q0e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 02:21:05 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 20 Jun 2017 07:21:02 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/7] shmem: shmem_charge: verify max_block is not exceeded before inode update
Date: Tue, 20 Jun 2017 09:20:46 +0300
In-Reply-To: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1497939652-16528-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1497939652-16528-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Currently we update inode and shmem_inode_info before verifying that
used_blocks will not exceed max_blocks. In case it will, we undo the
update. Let's switch the order and move the verification of the blocks
count before the inode and shmem_inode_info update.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/shmem.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index e67d6ba..40a43ae 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -265,6 +265,14 @@ bool shmem_charge(struct inode *inode, long pages)
 
 	if (shmem_acct_block(info->flags, pages))
 		return false;
+
+	if (sbinfo->max_blocks) {
+		if (percpu_counter_compare(&sbinfo->used_blocks,
+					   sbinfo->max_blocks - pages) > 0)
+			goto unacct;
+		percpu_counter_add(&sbinfo->used_blocks, pages);
+	}
+
 	spin_lock_irqsave(&info->lock, flags);
 	info->alloced += pages;
 	inode->i_blocks += pages * BLOCKS_PER_PAGE;
@@ -272,20 +280,11 @@ bool shmem_charge(struct inode *inode, long pages)
 	spin_unlock_irqrestore(&info->lock, flags);
 	inode->i_mapping->nrpages += pages;
 
-	if (!sbinfo->max_blocks)
-		return true;
-	if (percpu_counter_compare(&sbinfo->used_blocks,
-				sbinfo->max_blocks - pages) > 0) {
-		inode->i_mapping->nrpages -= pages;
-		spin_lock_irqsave(&info->lock, flags);
-		info->alloced -= pages;
-		shmem_recalc_inode(inode);
-		spin_unlock_irqrestore(&info->lock, flags);
-		shmem_unacct_blocks(info->flags, pages);
-		return false;
-	}
-	percpu_counter_add(&sbinfo->used_blocks, pages);
 	return true;
+
+unacct:
+	shmem_unacct_blocks(info->flags, pages);
+	return false;
 }
 
 void shmem_uncharge(struct inode *inode, long pages)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
