Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m0B6ODhD012456
	for <linux-mm@kvack.org>; Fri, 11 Jan 2008 06:24:14 GMT
Received: from wa-out-1112.google.com (wahj4.prod.google.com [10.114.236.4])
	by zps19.corp.google.com with ESMTP id m0B6Nrv1028249
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 22:24:12 -0800
Received: by wa-out-1112.google.com with SMTP id j4so1714718wah.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 22:24:12 -0800 (PST)
Message-ID: <b040c32a0801102224o54da2bfbk4a62b0cfe1d35f37@mail.gmail.com>
Date: Thu, 10 Jan 2008 22:24:12 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] fix hugetlbfs quota leak
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

In the error path of both shared and private hugetlb page allocation,
the file system quota is never undone, leading to fs quota leak.
Patch to fix them up.

Signed-off-by: Ken Chen <kenchen@google.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7224a4f..b2863f3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -420,6 +420,8 @@ static struct page *alloc_huge_page_private(struct
vm_area_struct *vma,
 	spin_unlock(&hugetlb_lock);
 	if (!page)
 		page = alloc_buddy_huge_page(vma, addr);
+	if (!page)
+		hugetlb_put_quota(vma->vm_file->f_mapping, 1);
 	return page ? page : ERR_PTR(-VM_FAULT_OOM);
 }

@@ -1206,8 +1208,10 @@ int hugetlb_reserve_pages(struct inode *inode,
long from, long to)
 	if (hugetlb_get_quota(inode->i_mapping, chg))
 		return -ENOSPC;
 	ret = hugetlb_acct_memory(chg);
-	if (ret < 0)
+	if (ret < 0) {
+		hugetlb_put_quota(inode->i_mapping, chg);
 		return ret;
+	}
 	region_add(&inode->i_mapping->private_list, from, to);
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
