Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id lA9HVDKJ014609
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 17:31:14 GMT
Received: from rv-out-0910.google.com (rvbg11.prod.google.com [10.140.83.11])
	by zps35.corp.google.com with ESMTP id lA9HVC4p023732
	for <linux-mm@kvack.org>; Fri, 9 Nov 2007 09:31:13 -0800
Received: by rv-out-0910.google.com with SMTP id g11so507212rvb
        for <linux-mm@kvack.org>; Fri, 09 Nov 2007 09:31:12 -0800 (PST)
Message-ID: <b040c32a0711090931v76c3c230k886639b14574f978@mail.gmail.com>
Date: Fri, 9 Nov 2007 09:31:12 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] hugetlb: fix i_blocks accounting
In-Reply-To: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0711082343t2b94b495r1608d99ec0e28a4c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

resent as I mistakenly bcc'ed linux-mm mailing list, where I really meant to cc.

---------- Forwarded message ----------
From: Ken Chen <kenchen@google.com>
Date: Nov 8, 2007 11:43 PM
Subject: [patch] hugetlb: fix i_blocks accounting
To: Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>


rebase i_blocks bug fix on top of Adam's recent fs quota work.

------
For administrative purpose, we want to query actual block usage for
hugetlbfs file via fstat.  Currently, hugetlbfs always return 0.  Fix
that up since kernel already has all the information to track it
properly.


Signed-off-by: Ken Chen <kenchen@google.com>

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 770dbed..65371bd 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -168,6 +168,8 @@ struct file *hugetlb_file_setup(const char *name, size_t);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);

+#define BLOCKS_PER_HUGEPAGE	(HPAGE_SIZE / 512)
+
 static inline int is_file_hugepages(struct file *file)
 {
 	if (file->f_op == &hugetlbfs_file_operations)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b58edd0..0d54370 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -801,6 +801,7 @@ retry:

 		if (vma->vm_flags & VM_SHARED) {
 			int err;
+			struct inode *inode = mapping->host;

 			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
 			if (err) {
@@ -809,6 +810,10 @@ retry:
 					goto retry;
 				goto out;
 			}
+
+			spin_lock(&inode->i_lock);
+			inode->i_blocks += BLOCKS_PER_HUGEPAGE;
+			spin_unlock(&inode->i_lock);
 		} else
 			lock_page(page);
 	}
@@ -1159,6 +1164,11 @@ int hugetlb_reserve_pages(struct inode *inode,
long from, long to)
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
 {
 	long chg = region_truncate(&inode->i_mapping->private_list, offset);
+
+	spin_lock(&inode->i_lock);
+	inode->i_blocks -= BLOCKS_PER_HUGEPAGE * freed;
+	spin_unlock(&inode->i_lock);
+
 	hugetlb_put_quota(inode->i_mapping, (chg - freed));
 	hugetlb_acct_memory(-(chg - freed));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
