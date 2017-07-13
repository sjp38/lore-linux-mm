Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD9C4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 18:33:59 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id j53so25875531uaa.2
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 15:33:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n2si3257098uaj.93.2017.07.13.15.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 15:33:58 -0700 (PDT)
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <415625d2-1be9-71f0-ca11-a014cef98a3f@oracle.com>
Date: Thu, 13 Jul 2017 15:33:47 -0700
MIME-Version: 1.0
In-Reply-To: <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
> [+CC linux-api]
> 
> On 07/13/2017 05:58 PM, Mike Kravetz wrote:
>> mremap will create a 'duplicate' mapping if old_size == 0 is
>> specified.  Such duplicate mappings make no sense for private
>> mappings.  If duplication is attempted for a private mapping,
>> mremap creates a separate private mapping unrelated to the
>> original mapping and makes no modifications to the original.
>> This is contrary to the purpose of mremap which should return
>> a mapping which is in some way related to the original.
>>
>> Therefore, return EINVAL in the case where if an attempt is
>> made to duplicate a private mapping.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

In another e-mail thread, Andrea makes the case that mremap(old_size == 0)
of private file backed mappings could possibly be used for something useful.
For example to create a private COW mapping.  Of course, a better way to do
this would be simply using the fd to create a private mapping.

If returning EINVAL for all private mappings is too general, the following
patch adds a check to only return EINVAL for private anon mappings.

mm/mremap: Fail map duplication attempts for private anon mappings

mremap will create a 'duplicate' mapping if old_size == 0 is
specified.  Such duplicate mappings make no sense for private
anonymous mappings.  If duplication is attempted for a private
anon mapping, mremap creates a separate private mapping unrelated
to the original mapping and makes no modifications to the original.
This is contrary to the purpose of mremap which should return a
mapping which is in some way related to the original.

Therefore, return EINVAL in the case where an attempt is made to
duplicate a private anon mapping.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/mremap.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/mremap.c b/mm/mremap.c
index cd8a1b1..586ea3d 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -383,6 +383,14 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	if (!vma || vma->vm_start > addr)
 		return ERR_PTR(-EFAULT);
 
+	/*
+	 * !old_len  is a special case where a mapping is 'duplicated'.
+	 * Do not allow this for private anon mappings.
+	 */
+	if (!old_len && vma_is_anonymous(vma) &&
+	    !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
+		return ERR_PTR(-EINVAL);
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
