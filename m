Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF2896B0292
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:38:22 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id f68so1325072vkg.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 13:38:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c126si1091395vkg.228.2017.07.20.13.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 13:38:20 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2] mm/mremap: Fail map duplication attempts for private mappings
Date: Thu, 20 Jul 2017 13:37:59 -0700
Message-Id: <1500583079-26504-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <20170720082058.GF9058@dhcp22.suse.cz>
References: <20170720082058.GF9058@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Linux API <linux-api@vger.kernel.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>

mremap will create a 'duplicate' mapping if old_size == 0 is
specified.  Such duplicate mappings make no sense for private
mappings.  If duplication is attempted for a private mapping,
mremap creates a separate private mapping unrelated to the
original mapping and makes no modifications to the original.
This is contrary to the purpose of mremap which should return
a mapping which is in some way related to the original.

Therefore, return EINVAL in the case where if an attempt is
made to duplicate a private mapping.  Also, print a warning
message (once) if such an attempt is made.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/mremap.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b1..949f6a7 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -383,6 +383,15 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (!vma || vma->vm_start > addr)
 		return ERR_PTR(-EFAULT);
 
+	/*
+	 * !old_len  is a special case where a mapping is 'duplicated'.
+	 * Do not allow this for private mappings.
+	 */
+	if (!old_len && !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE))) {
+		pr_warn_once("%s (%d): attempted to duplicate a private mapping with mremap.  This is not supported.\n", current->comm, current->pid);
+		return ERR_PTR(-EINVAL);
+	}
+
 	if (is_vm_hugetlb_page(vma))
 		return ERR_PTR(-EINVAL);
 
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
