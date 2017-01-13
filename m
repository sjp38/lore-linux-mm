Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD4366B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:26:26 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id d9so51344552itc.4
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:26:26 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i200si515850ioi.119.2017.01.13.00.26.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 00:26:26 -0800 (PST)
Date: Fri, 13 Jan 2017 11:26:08 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2 linux-next] userfaultfd: hugetlbfs: unmap the correct
 pointer
Message-ID: <20170113082608.GA3548@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112193327.GB8558@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

kunmap_atomic() and kunmap() take different pointers.  People often get
these mixed up.

Fixes: 16374db2e9a0 ("userfaultfd: hugetlbfs: fix __mcopy_atomic_hugetlb retry/error processing")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: I was also unmapping the wrong pointer because I had a typo.

diff --git a/mm/memory.c b/mm/memory.c
index 6012a05..aca8ef6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4172,7 +4172,7 @@ long copy_huge_page_from_user(struct page *dst_page,
 				(const void __user *)(src + i * PAGE_SIZE),
 				PAGE_SIZE);
 		if (allow_pagefault)
-			kunmap(page_kaddr);
+			kunmap(page_kaddr + i);
 		else
 			kunmap_atomic(page_kaddr);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
