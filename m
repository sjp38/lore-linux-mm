Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD076B0253
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 08:48:51 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id kf9so4690961obc.1
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 05:48:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k81si1213832oif.147.2016.03.23.05.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 05:48:50 -0700 (PDT)
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Subject: [PATCH v2 1/6] mm/hugetlb: Introduce hugetlb_bad_size
Date: Wed, 23 Mar 2016 17:52:08 +0530
Message-Id: <1458735728-15267-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

When any unsupported hugepage size is specified, 'hugepagesz=' and
'hugepages=' should be ignored during command line parsing until any
supported hugepage size is found. But currently incorrect number of
hugepages are allocated when unsupported size is specified as it fails
to ignore the 'hugepages=' command.

Test case:

Note that this is specific to x86 architecture.

Boot the kernel with command line option 'hugepagesz=256M hugepages=X'.
After boot, dmesg output shows that X number of hugepages of the size 2M
is pre-allocated instead of 0.

So, to handle such command line options, introduce new routine
hugetlb_bad_size. The routine hugetlb_bad_size sets the global variable
parsed_valid_hugepagesz. We are using parsed_valid_hugepagesz to save the
state when unsupported hugepagesize is found so that we can ignore the
'hugepages=' parameters after that and then reset the variable when
supported hugepage size is found.

The routine hugetlb_bad_size can be called while setting 'hugepagesz='
parameter in an architecture specific code.

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
The patch is having 2 checkpatch.pl warnings. I have just followed
the current code to maintain consistency.
Changes since v1:
	- Nothing in this patch, just separated changes done in second
	  patch
---
 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 7d953c2..e44c578 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -338,6 +338,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 /* arch callback */
 int __init alloc_bootmem_huge_page(struct hstate *h);
 
+void __init hugetlb_bad_size(void);
 void __init hugetlb_add_hstate(unsigned order);
 struct hstate *size_to_hstate(unsigned long size);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06058ea..5ebdd869 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -51,6 +51,7 @@ __initdata LIST_HEAD(huge_boot_pages);
 static struct hstate * __initdata parsed_hstate;
 static unsigned long __initdata default_hstate_max_huge_pages;
 static unsigned long __initdata default_hstate_size;
+static bool __initdata parsed_valid_hugepagesz = true;
 
 /*
  * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
@@ -2659,6 +2660,11 @@ static int __init hugetlb_init(void)
 subsys_initcall(hugetlb_init);
 
 /* Should be called on processing a hugepagesz=... option */
+void __init hugetlb_bad_size(void)
+{
+	parsed_valid_hugepagesz = false;
+}
+
 void __init hugetlb_add_hstate(unsigned int order)
 {
 	struct hstate *h;
@@ -2691,11 +2697,17 @@ static int __init hugetlb_nrpages_setup(char *s)
 	unsigned long *mhp;
 	static unsigned long *last_mhp;
 
+	if (!parsed_valid_hugepagesz) {
+		pr_warn("hugepages = %s preceded by "
+			"an unsupported hugepagesz, ignoring\n", s);
+		parsed_valid_hugepagesz = true;
+		return 1;
+	}
 	/*
 	 * !hugetlb_max_hstate means we haven't parsed a hugepagesz= parameter yet,
 	 * so this hugepages= parameter goes to the "default hstate".
 	 */
-	if (!hugetlb_max_hstate)
+	else if (!hugetlb_max_hstate)
 		mhp = &default_hstate_max_huge_pages;
 	else
 		mhp = &parsed_hstate->max_huge_pages;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
