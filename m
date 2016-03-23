Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6286D6B0253
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:49:51 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id n5so26357514pfn.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:49:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id yi4si4186346pac.177.2016.03.23.05.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:49:50 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 5/6] tile: mm: Use hugetlb_bad_size
Date: Wed, 23 Mar 2016 18:07:07 +0530
Message-Id: <1458736627-16155-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cmetcalf@ezchip.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

Update the setup_hugepagesz function to call the routine
hugetlb_bad_size when unsupported hugepage size is found.

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
- Please note that the patch is tested for x86 only. But as this
  is one line change I just changed them. So, it would be good if
  the patch can be tested for other architectures before adding
  this in to mainline.
Changes since v1:
        - Separate different arch specific changes in different
          patches instead of one
---
 arch/tile/mm/hugetlbpage.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index e212c64..77ceaa3 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -308,11 +308,16 @@ static bool saw_hugepagesz;
 
 static __init int setup_hugepagesz(char *opt)
 {
+	int rc;
+
 	if (!saw_hugepagesz) {
 		saw_hugepagesz = true;
 		memset(huge_shift, 0, sizeof(huge_shift));
 	}
-	return __setup_hugepagesz(memparse(opt, NULL));
+	rc = __setup_hugepagesz(memparse(opt, NULL));
+	if (rc)
+		hugetlb_bad_size();
+	return rc;
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
