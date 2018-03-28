Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31F4A6B0055
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a4so1716977pff.2
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id x10si2625159pgo.58.2018.03.28.09.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 03/14] mm/shmem: Zero out unused vma fields in shmem_pseudo_vma_init()
Date: Wed, 28 Mar 2018 19:55:29 +0300
Message-Id: <20180328165540.648-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

shmem/tmpfs uses pseudo vma to allocate page with correct NUMA policy.

The pseudo vma doesn't have vm_page_prot set. We are going to encode
encryption KeyID in vm_page_prot. Having garbage there causes problems.

Zero out all unused fields in the pseudo vma.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/shmem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index b85919243399..387b89d9e17a 100644
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
2.16.2
