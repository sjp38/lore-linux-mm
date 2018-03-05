Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5AF96B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:26:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v8so7534991pgs.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:26:28 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q24si10299553pff.301.2018.03.05.08.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:26:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCH 14/22] mm, khugepaged: Do not collapse pages in encrypted VMAs
Date: Mon,  5 Mar 2018 19:26:02 +0300
Message-Id: <20180305162610.37510-15-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Pages for encrypted VMAs have to be allocated in a special way:
we would need to propagate down not only desired NUMA node but also
whether the page is encrypted.

It complicates not-so-trivial routine of huge page allocation in
khugepaged even more. I also puts more pressure on page allocator:
we cannot re-use pages allocated for encrypted VMA to collapse
page in unencrypted one or vice versa.

I think for now it worth skipping encrypted VMAs. We can return
to this topic later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index b7e2268dfc9a..601151678414 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -830,6 +830,8 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
+	if (vma_is_encrypted(vma))
+		return false;
 	return !(vma->vm_flags & VM_NO_KHUGEPAGED);
 }
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
