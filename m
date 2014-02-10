Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id DE3606B0038
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:28:10 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so4342193wgh.11
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:28:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ll10si7976927wjc.79.2014.02.10.09.28.07
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 09:28:08 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 4/4] hugetlb: hugepagesnid=: add 1G huge page support
Date: Mon, 10 Feb 2014 12:27:48 -0500
Message-Id: <1392053268-29239-5-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

From: Luiz capitulino <lcapitulino@redhat.com>

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 mm/hugetlb.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 439c3b7..d759321 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2051,6 +2051,29 @@ void __init hugetlb_add_hstate(unsigned order)
 	parsed_hstate = h;
 }
 
+static void __init hugetlb_hstate_alloc_pages_nid(struct hstate *h,
+						int nid,
+						unsigned long nr_pages)
+{
+	struct huge_bootmem_page *m;
+	unsigned long i;
+	void *addr;
+
+	for (i = 0; i < nr_pages; i++) {
+		addr = memblock_virt_alloc_nid_nopanic(
+				huge_page_size(h), huge_page_size(h),
+				0, BOOTMEM_ALLOC_ACCESSIBLE, nid);
+		if (!addr)
+			break;
+		m = addr;
+		BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
+		list_add(&m->list, &huge_boot_pages);
+		m->hstate = h;
+	}
+
+	h->max_huge_pages += i;
+}
+
 void __init hugetlb_add_nrpages_nid(unsigned order, unsigned long nid,
 				unsigned long nr_pages)
 {
@@ -2080,6 +2103,9 @@ void __init hugetlb_add_nrpages_nid(unsigned order, unsigned long nid,
 	}
 
 	*p = nr_pages;
+
+	if (h->order >= MAX_ORDER)
+		hugetlb_hstate_alloc_pages_nid(h, nid, nr_pages);
 }
 
 static int __init hugetlb_nrpages_setup(char *s)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
