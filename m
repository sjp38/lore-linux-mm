Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id F022D6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:11:27 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id d134so9254010vka.9
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:11:27 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 63si5644155vka.60.2018.01.09.12.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 12:11:26 -0800 (PST)
Date: Tue, 9 Jan 2018 23:06:00 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] mm, hugetlb: Fix a double unlock bug in
 alloc_surplus_huge_page()
Message-ID: <20180109200559.g3iz5kvbdrz7yydp@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Punit Agrawal <punit.agrawal@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

We aren't holding the hugetlb_lock so there is no need to unlock.

Fixes: b27f11e5e675 ("mm, hugetlb: get rid of surplus page accounting tricks")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ffcae114ceed..742a929f2311 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1567,7 +1567,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 
 	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
 	if (!page)
-		goto out_unlock;
+		return NULL;
 
 	spin_lock(&hugetlb_lock);
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
