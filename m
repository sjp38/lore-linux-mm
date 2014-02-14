Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 255E26B0038
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 20:03:17 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so9439738wiw.9
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:03:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fu7si2495871wjb.118.2014.02.13.17.03.14
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 17:03:15 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 3/4] hugetlb: add parse_pagesize_str()
Date: Thu, 13 Feb 2014 20:02:07 -0500
Message-Id: <1392339728-13487-4-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
References: <1392339728-13487-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com, davidlohr@hp.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, rientjes@google.com

From: Luiz capitulino <lcapitulino@redhat.com>

This commit moves current setup_hugepagez() logic to function called
parse_pagesize_str(), so that it can be used by the next commit.

There should be no functional changes, except for the following:

 - When calling memparse(), setup_hugepagesz() was passing the retptr
   argument, but the result was unused. So parse_pagesize_str() pass NULL
   instead

 - Change printk(KERN_ERR) to pr_err() and make the error message a little
   bit nicer for bad command-lines like "hugepagesz=1X"

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 arch/x86/mm/hugetlbpage.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8c9f647..968db71 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -173,18 +173,31 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 #endif /* CONFIG_HUGETLB_PAGE */
 
 #ifdef CONFIG_X86_64
-static __init int setup_hugepagesz(char *opt)
+static __init int parse_pagesize_str(char *str, unsigned *order)
 {
-	unsigned long ps = memparse(opt, &opt);
+	unsigned long ps = memparse(str, NULL);
 	if (ps == PMD_SIZE) {
-		hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
+		*order = PMD_SHIFT - PAGE_SHIFT;
 	} else if (ps == PUD_SIZE && cpu_has_gbpages) {
-		hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
+		*order = PUD_SHIFT - PAGE_SHIFT;
 	} else {
-		printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
-			ps >> 20);
+		/* invalid page size */
+		return -1;
+	}
+
+	return 0;
+}
+
+static __init int setup_hugepagesz(char *opt)
+{
+	unsigned order;
+
+	if (parse_pagesize_str(opt, &order)) {
+		pr_err("hugepagesz: Unsupported page size %s\n", opt);
 		return 0;
 	}
+
+	hugetlb_add_hstate(order);
 	return 1;
 }
 __setup("hugepagesz=", setup_hugepagesz);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
