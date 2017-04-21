Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id F14C06B0038
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 06:57:36 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k1so20994780qtb.20
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 03:57:36 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r185si9167131qkc.202.2017.04.21.03.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 03:57:35 -0700 (PDT)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v3LAvYN7010063
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:57:34 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v3LAvX1a012303
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:57:34 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.13.8/8.13.8) with ESMTP id v3LAvVT2005193
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:57:32 GMT
Date: Fri, 21 Apr 2017 13:57:24 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] hugetlbfs: fix offset overflow in hugetlbfs mmap
Message-ID: <20170421105724.j4o2j5zj2jjkjges@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mike.kravetz@oracle.com
Cc: linux-mm@kvack.org

Hello Mike Kravetz,

The patch 045c7a3f53d9: "hugetlbfs: fix offset overflow in hugetlbfs
mmap" from Apr 13, 2017, leads to the following static checker
warning:

	fs/hugetlbfs/inode.c:152 hugetlbfs_file_mmap()
	warn: signed overflow undefined. 'vma_len + (vma->vm_pgoff << 12) < vma_len'

fs/hugetlbfs/inode.c
   121  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
   122  {
   123          struct inode *inode = file_inode(file);
   124          loff_t len, vma_len;
   125          int ret;
   126          struct hstate *h = hstate_file(file);
   127  
   128          /*
   129           * vma address alignment (but not the pgoff alignment) has
   130           * already been checked by prepare_hugepage_range.  If you add
   131           * any error returns here, do so after setting VM_HUGETLB, so
   132           * is_vm_hugetlb_page tests below unmap_region go the right
   133           * way when do_mmap_pgoff unwinds (may be important on powerpc
   134           * and ia64).
   135           */
   136          vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
   137          vma->vm_ops = &hugetlb_vm_ops;
   138  
   139          /*
   140           * Offset passed to mmap (before page shift) could have been
   141           * negative when represented as a (l)off_t.
   142           */
   143          if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
   144                  return -EINVAL;
   145  
   146          if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
   147                  return -EINVAL;
   148  
   149          vma_len = (loff_t)(vma->vm_end - vma->vm_start);
   150          len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
   151          /* check for overflow */
   152          if (len < vma_len)
                    ^^^^^^^^^^^^^
This is undefined in C.  I think with kernel GCC options it's safe these
days, but I can't swear on it.

   153                  return -EINVAL;
   154  
   155          inode_lock(inode);
   156          file_accessed(file);

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
