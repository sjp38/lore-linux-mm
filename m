Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id D0D986B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 09:00:02 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id xj3so11227093obb.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:00:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id fn9si4261926pab.163.2016.03.23.05.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:59:40 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 4/6] powerpc: mm: Use hugetlb_bad_size
Date: Wed, 23 Mar 2016 18:04:27 +0530
Message-Id: <1458736467-15995-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

Update the setup_hugepagesz function to call the routine
hugetlb_bad_size when unsupported hugepage size is found.

Misc:
   - Silent checkpatch.pl's 80 characters and printk warning

Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
---
Please note that the patch is tested for x86 only. But as this
is one line change I just changed them. So, it would be good if
the patch can be tested for other architectures before adding
this in to mainline.
Changes since v1:
        - Separate different arch specific changes in different
          patches instead of one
---
 arch/powerpc/mm/hugetlbpage.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 6dd272b..3e5e128 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -772,8 +772,10 @@ static int __init hugepage_setup_sz(char *str)
 
 	size = memparse(str, &str);
 
-	if (add_huge_page_size(size) != 0)
-		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n", size);
+	if (add_huge_page_size(size) != 0) {
+		hugetlb_bad_size();
+		pr_err("Invalid huge page size specified(%llu)\n", size);
+	}
 
 	return 1;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
