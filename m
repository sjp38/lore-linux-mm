Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDF056B0008
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:56:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o19-v6so3336816pgn.14
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:56:09 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c10-v6si17914027plz.190.2018.05.31.06.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:56:08 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm/shmem: Zero out unused vma fields in shmem_pseudo_vma_init()
Date: Thu, 31 May 2018 16:56:02 +0300
Message-Id: <20180531135602.20321-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

shmem/tmpfs uses pseudo vma to allocate page with correct NUMA policy.

The pseudo vma doesn't have vm_page_prot set. We are going to encode
encryption KeyID in vm_page_prot. Having garbage there causes problems.

Zero out all unused fields in the pseudo vma.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/shmem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 9d6c7e595415..693fb82b4b42 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1404,10 +1404,9 @@ static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
 		struct shmem_inode_info *info, pgoff_t index)
 {
 	/* Create a pseudo vma that just contains the policy */
-	vma->vm_start = 0;
+	memset(vma, 0, sizeof(*vma));
 	/* Bias interleave by inode number to distribute better across nodes */
 	vma->vm_pgoff = index + info->vfs_inode.i_ino;
-	vma->vm_ops = NULL;
 	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
 }
 
-- 
2.17.0
