Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5DAD2806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 12:55:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k87so134613531ioi.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 09:55:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k8si3067206itf.35.2017.04.21.09.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 09:55:50 -0700 (PDT)
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v3LGtnur032568
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:55:49 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.13.8/8.14.4) with ESMTP id v3LGtmpF026287
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:55:48 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id v3LGtmda029146
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 16:55:48 GMT
Subject: Re: [bug report] hugetlbfs: fix offset overflow in hugetlbfs mmap
References: <20170421105724.j4o2j5zj2jjkjges@mwanda>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <aa82140c-248f-143d-2b14-142e4775df65@oracle.com>
Date: Fri, 21 Apr 2017 09:55:46 -0700
MIME-Version: 1.0
In-Reply-To: <20170421105724.j4o2j5zj2jjkjges@mwanda>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On 04/21/2017 03:57 AM, Dan Carpenter wrote:
> Hello Mike Kravetz,
> 
> The patch 045c7a3f53d9: "hugetlbfs: fix offset overflow in hugetlbfs
> mmap" from Apr 13, 2017, leads to the following static checker
> warning:
> 
> 	fs/hugetlbfs/inode.c:152 hugetlbfs_file_mmap()
> 	warn: signed overflow undefined. 'vma_len + (vma->vm_pgoff << 12) < vma_len'
> 
> fs/hugetlbfs/inode.c
>    121  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
>    122  {
>    123          struct inode *inode = file_inode(file);
>    124          loff_t len, vma_len;
>    125          int ret;
>    126          struct hstate *h = hstate_file(file);
>    127  
>    128          /*
>    129           * vma address alignment (but not the pgoff alignment) has
>    130           * already been checked by prepare_hugepage_range.  If you add
>    131           * any error returns here, do so after setting VM_HUGETLB, so
>    132           * is_vm_hugetlb_page tests below unmap_region go the right
>    133           * way when do_mmap_pgoff unwinds (may be important on powerpc
>    134           * and ia64).
>    135           */
>    136          vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
>    137          vma->vm_ops = &hugetlb_vm_ops;
>    138  
>    139          /*
>    140           * Offset passed to mmap (before page shift) could have been
>    141           * negative when represented as a (l)off_t.
>    142           */
>    143          if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
>    144                  return -EINVAL;
>    145  
>    146          if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>    147                  return -EINVAL;
>    148  
>    149          vma_len = (loff_t)(vma->vm_end - vma->vm_start);
>    150          len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>    151          /* check for overflow */
>    152          if (len < vma_len)
>                     ^^^^^^^^^^^^^
> This is undefined in C.  I think with kernel GCC options it's safe these
> days, but I can't swear on it.
> 

Thanks Dan,

We discussed this a bit when the patch was submitted.  I'm just curious
if your static checker is checking all code or just new patches?  The
reason for asking is that there are similar issues later on in this
routine that ware not changed by this patch.  In fact, there are several
instances of this type of 'undefined behavior' in the hugetlbfs code.

I can go through the code and try to change all such instances.  However,
by code inspection alone I am likely to miss some.  If you or others can
point out a tool (or compiler options) to look for all such instances that
would make such an exercise easier.

-- 
Mike Kravetz

>    153                  return -EINVAL;
>    154  
>    155          inode_lock(inode);
>    156          file_accessed(file);
> 
> regards,
> dan carpenter
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
