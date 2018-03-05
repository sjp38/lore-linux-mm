Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1D86B0026
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:30 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 1-v6so8288800plv.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:30 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id i35-v6si9489639plg.144.2018.03.05.08.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:29 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 10/22] mm/shmem: Zero out unused vma fields in shmem_pseudo_vma_init()
Date: Mon,  5 Mar 2018 19:25:58 +0300
Message-Id: <20180305162610.37510-11-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
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
index 1907688b75ee..e0e87b6aad26 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1395,10 +1395,9 @@ static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
