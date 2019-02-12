Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EF9EC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:14:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEC3B222C7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 22:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pypCt11B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEC3B222C7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72F728E0002; Tue, 12 Feb 2019 17:14:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DE678E0001; Tue, 12 Feb 2019 17:14:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A7108E0002; Tue, 12 Feb 2019 17:14:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6AD8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 17:14:20 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 35so294100qty.12
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 14:14:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=tx8yofQ7GDtc8w7ZnLR4b4Phwy1fVbZgK2ukQvv27ZE=;
        b=j24yT0AVKbLvCR2NytTD+QIWjND2yi5m71d/ffLuU+ViH9/XM+89IqW/Qn2pgDI4Kf
         81bhDw0kAVul5QfdYb9eaSjHiMkPeA+EVTHviyEx6hmehoY0gfJEJnnz79GQkHB9EUlU
         2WI0t2lzbjXWlcoZkqf7pFfGAZjibusH8JFJ7JnfkTpl8n0KLWDuL0SBwXZHBtI1/MAP
         cU2eWl2Xc3DB0/2J/uZNhRwt+6kXD8BI3QEEVMXgCGq0WZro0J/t2ORS4crzRD0pBPdT
         7OMY7kyoi76UGMDUFGSgyIAbwp8CPEwaF2p42xRCXG4tsqoY3Izm6Z/3uKYgwnCVcWqW
         QNyA==
X-Gm-Message-State: AHQUAubspV5i1cHKlNJven2Q3fv1MqEIlBqE8zcuFAIk4oIwXXy4q/7P
	uMrpfBbewy+toAQMxBA53wLbCVRw5OE2Vv4TI2SuttzhUhPb5D6rSx9mOlQzqxha2H6QwSr9Rrb
	T4H7hK799TX4GbHBjXqxxKcF1550gv1GpVzDLH0TyM3K+orfund4RbkCOT8A+j/ZdBg==
X-Received: by 2002:a0c:bb98:: with SMTP id i24mr4564550qvg.129.1550009659899;
        Tue, 12 Feb 2019 14:14:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZq3Kpy3fQkosdiFe/a4V3FUlxBGvQyNVcBRruAkZs1ybrqmjizirZou45O48z5QkfBotZV
X-Received: by 2002:a0c:bb98:: with SMTP id i24mr4564507qvg.129.1550009659094;
        Tue, 12 Feb 2019 14:14:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550009659; cv=none;
        d=google.com; s=arc-20160816;
        b=Dg78diKDAlm7XP/+A5i8gx/AbmMsizZE5qqkjgO4IAPZ/ys+MS0SzMDyOm3XSsY9OR
         c6G77f9Gar5t90vTrM9uzchaKlMiGdjnUsNL+FRK/7LDqGAUqPIhX30nsyqhuvRRXnmJ
         xiG7k8dBS4krkKowPvmbtjeiTI2866Yqngppw0hY9mkL8t3xLA3RcPwZRkZuDokM6+lp
         mrr4yqDUnbju5WpbvNrMGlNK+nYQlg1hHIkOhK+UtMFjHgJJigKvpVLDc1hf73q8+5gb
         hewRSoG8PA51/ELHEKHDFuB2LXKoDXqqxZrQmDwbR4D2XCn0xY/YLvok3g2okMTL85Cc
         tfIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=tx8yofQ7GDtc8w7ZnLR4b4Phwy1fVbZgK2ukQvv27ZE=;
        b=d1n1DLkNAHysFhAMiWVPn7w7O/kEQsD9Gxx2GfmgAWNqSVlUTp6ILHrs7ck0lHN+ZW
         gkZNvSalI8kykzYGlMgVWRbZe33dIGDit8nNi7ArzJj1hg6F/WyFABQucFwXvDBuu5vE
         ZTB7ssINIC9Bkci58rAQsmYmaTXNbxSJKsYHxKPkfiTaappQT/7xSkRCwBz5j/WEjyIt
         IBR+WxD8VGSe6WyfQB7K3DpGaGUgsGm1tb/rAe/B3UoGzlIEXFYmGnoR0T4gD25Icr5P
         n6ekLCWc1ySyDNK2jwg/075PKYFVounvBCZqiOlclTxlwXnPDIG8t7svSFK4x4tI28Xh
         DszQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pypCt11B;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t126si5446183qkc.5.2019.02.12.14.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 14:14:19 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pypCt11B;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1CM3hMC027722;
	Tue, 12 Feb 2019 22:14:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=tx8yofQ7GDtc8w7ZnLR4b4Phwy1fVbZgK2ukQvv27ZE=;
 b=pypCt11B+jkaTl4hUp/50uGx/FaaXb5YnO7F5AsPLoiqyyf24wvyQQ9nw+Rdj4p30g8R
 D723oZVd7WlUGccYEhjn4V3F8rRryYD1UbTZNasaa0SowSM5POQHDgWplkRjp3kLDNcF
 U6HxiQup+0IFZ68VQcUzQFS2DXzEYKjS5SRHV60gpP07AFSpNog0U7PQ4aZhHeNf6l09
 bzIHIin9qLV5OWOkCiDP8t1oyaLlSx6IdZ4C94uSkmZd73nveSfXEyOqWbhrnN1Gw9Cr
 Ewbwjhhvykq5+k7qTDf3sT9wlrIeFrLFvGWML9jS6/i2EOoYE9vYt5blib6WCr8gtZ6L 9Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2qhrekepuk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 22:14:11 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1CME9Oj026407
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 22:14:09 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1CME7mS016086;
	Tue, 12 Feb 2019 22:14:07 GMT
Received: from monkey.oracle.com (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 14:14:07 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>, stable@vger.kernel.org
Subject: [PATCH] huegtlbfs: fix races and page leaks during migration
Date: Tue, 12 Feb 2019 14:14:00 -0800
Message-Id: <20190212221400.3512-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=717 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hugetlb pages should only be migrated if they are 'active'.  The routines
set/clear_page_huge_active() modify the active state of hugetlb pages.
When a new hugetlb page is allocated at fault time, set_page_huge_active
is called before the page is locked.  Therefore, another thread could
race and migrate the page while it is being added to page table by the
fault code.  This race is somewhat hard to trigger, but can be seen by
strategically adding udelay to simulate worst case scheduling behavior.
Depending on 'how' the code races, various BUG()s could be triggered.

To address this issue, simply delay the set_page_huge_active call until
after the page is successfully added to the page table.

Hugetlb pages can also be leaked at migration time if the pages are
associated with a file in an explicitly mounted hugetlbfs filesystem.
For example, a test program which hole punches, faults and migrates
pages in such a file (1G in size) will eventually fail because it
can not allocate a page.  Reported counts and usage at time of failure:

node0
537     free_hugepages
1024    nr_hugepages
0       surplus_hugepages
node1
1000    free_hugepages
1024    nr_hugepages
0       surplus_hugepages

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G  4.0G     0 100% /var/opt/hugepool

Note that the filesystem shows 4G of pages used, while actual usage is
511 pages (just under 1G).  Failed trying to allocate page 512.

If a hugetlb page is associated with an explicitly mounted filesystem,
this information in contained in the page_private field.  At migration
time, this information is not preserved.  To fix, simply transfer
page_private from old to new page at migration time if necessary.

Cc: <stable@vger.kernel.org>
Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 12 ++++++++++++
 mm/hugetlb.c         |  9 ++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..a7fa037b876b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -859,6 +859,18 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
+
+	/*
+	 * page_private is subpool pointer in hugetlb pages.  Transfer to
+	 * new page.  PagePrivate is not associated with page_private for
+	 * hugetlb pages and can not be set here as only page_huge_active
+	 * pages can be migrated.
+	 */
+	if (page_private(page)) {
+		set_page_private(newpage, page_private(page));
+		set_page_private(page, 0);
+	}
+
 	if (mode != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a80832487981..f859e319e3eb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3625,7 +3625,6 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
-	set_page_huge_active(new_page);
 
 	mmun_start = haddr;
 	mmun_end = mmun_start + huge_page_size(h);
@@ -3647,6 +3646,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, haddr);
+		set_page_huge_active(new_page);
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
@@ -3792,7 +3792,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
-		set_page_huge_active(page);
 
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err = huge_add_to_page_cache(page, mapping, idx);
@@ -3863,6 +3862,10 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	spin_unlock(ptl);
+
+	/* May already be set if not newly allocated page */
+	set_page_huge_active(page);
+
 	unlock_page(page);
 out:
 	return ret;
@@ -4097,7 +4100,6 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	 * the set_pte_at() write.
 	 */
 	__SetPageUptodate(page);
-	set_page_huge_active(page);
 
 	mapping = dst_vma->vm_file->f_mapping;
 	idx = vma_hugecache_offset(h, dst_vma, dst_addr);
@@ -4165,6 +4167,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	update_mmu_cache(dst_vma, dst_addr, dst_pte);
 
 	spin_unlock(ptl);
+	set_page_huge_active(page);
 	if (vm_shared)
 		unlock_page(page);
 	ret = 0;
-- 
2.17.2

