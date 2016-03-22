Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id C9DFD6B025E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 06:11:59 -0400 (EDT)
Received: by mail-oi0-f48.google.com with SMTP id w20so112038392oia.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 03:11:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id np8si12319030obc.72.2016.03.22.03.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 03:11:59 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH 2/2] arch:mm: Use hugetlb_bad_size
Date: Tue, 22 Mar 2016 15:35:59 +0530
Message-Id: <1458641159-13643-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

Update the setup_hugepagesz function to call the routine
hugetlb_bad_size when unsupported hugepage size is found.

Misc:
  - Silent 80 characters warning

Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
- Not sure if printk related checkpatch.pl warning should be resolved
  with this patch as code is not consistent in architectures. May be
  one separate patch for changing all printk's to pr_<level> kind of
  debugging functions would be good.
---
 arch/arm64/mm/hugetlbpage.c   | 1 +
 arch/metag/mm/hugetlbpage.c   | 1 +
 arch/powerpc/mm/hugetlbpage.c | 7 +++++--
 arch/tile/mm/hugetlbpage.c    | 7 ++++++-
 arch/x86/mm/hugetlbpage.c     | 1 +
 5 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 589fd28..aa8aee7 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -307,6 +307,7 @@ static __init int setup_hugepagesz(char *opt)
 	} else if (ps == PUD_SIZE) {
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
 	} else {
+		hugetlb_bad_size();
 		pr_err("hugepagesz: Unsupported page size %lu K\n", ps >> 10);
 		return 0;
 	}
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index b38700a..db1b7da 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -239,6 +239,7 @@ static __init int setup_hugepagesz(char *opt)
 	if (ps == (1 << HPAGE_SHIFT)) {
 		hugetlb_add_hstate(HPAGE_SHIFT - PAGE_SHIFT);
 	} else {
+		hugetlb_bad_size();
 		pr_err("hugepagesz: Unsupported page size %lu M\n",
 		       ps >> 20);
 		return 0;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 6dd272b..a437ff7 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -772,8 +772,11 @@ static int __init hugepage_setup_sz(char *str)
 
 	size = memparse(str, &str);
 
-	if (add_huge_page_size(size) != 0)
-		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n", size);
+	if (add_huge_page_size(size) != 0) {
+		hugetlb_bad_size();
+		printk(KERN_WARNING "Invalid huge page size specified(%llu)\n",
+		       size);
+	}
 
 	return 1;
 }
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
 
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 740d7ac..3ec44f8 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -165,6 +165,7 @@ static __init int setup_hugepagesz(char *opt)
 	} else if (ps == PUD_SIZE && cpu_has_gbpages) {
 		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
 	} else {
+		hugetlb_bad_size();
 		printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
 			ps >> 20);
 		return 0;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
