Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 007606B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:46:41 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH 1/2 v5][resend] shmem: provide vm_ops when also providing a mem policy
Date: Mon,  9 Jul 2012 09:46:38 -0500
Message-Id: <1341845199-25677-2-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1341845199-25677-1-git-send-email-nzimmer@sgi.com>
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nathan Zimmer <nzimmer@sgi.com>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

Updating shmem_get_policy to use the vma_policy if provided.
This is to allows us to safely provide shmem_vm_ops to the vma when the vm_file
has not been setup which is the case on the pseudo vmas.

Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
---
 mm/shmem.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index a15a466..d073252 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -921,8 +921,11 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
-	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
+	if (pvma.vm_policy)
+		pvma.vm_ops = &shmem_vm_ops;
+	else
+		pvma.vm_ops = NULL;
 	return swapin_readahead(swap, gfp, &pvma, 0);
 }
 
@@ -934,8 +937,11 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 	/* Create a pseudo vma that just contains the policy */
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
-	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	if (pvma.vm_policy)
+		pvma.vm_ops = &shmem_vm_ops;
+	else
+		pvma.vm_ops = NULL;
 
 	/*
 	 * alloc_page_vma() will drop the shared policy reference
@@ -1296,8 +1302,14 @@ static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *mpol)
 static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 					  unsigned long addr)
 {
-	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	pgoff_t index;
+	struct inode *inode;
+
+	/* If the vma knows what policy it wants use that one. */
+	if (vma->vm_policy)
+		return vma->vm_policy;
+
+	inode = vma->vm_file->f_path.dentry->d_inode;
 
 	index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy, index);
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
