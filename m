Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDCDE6B0253
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 14:23:48 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id a16so24973190qkc.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:23:48 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d27si6785427qtb.11.2017.01.12.11.23.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 11:23:48 -0800 (PST)
Date: Thu, 12 Jan 2017 22:20:52 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch linux-next] userfaultfd: hugetlbfs: unmap the correct pointer
Message-ID: <20170112192052.GB12157@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

kunmap_atomic() and kunmap() take different pointers.  People often get
these mixed up.

Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/memory.c b/mm/memory.c
index 6012a05..dfd3604 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
 				(const void __user *)(src + i * PAGE_SIZE),
 				PAGE_SIZE);
 		if (allow_pagefault)
-			kunmap(page_kaddr);
+			kunmap(dst_page + 1);
 		else
 			kunmap_atomic(page_kaddr);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
