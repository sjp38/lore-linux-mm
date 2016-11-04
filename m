Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43877280278
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 04:59:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ro13so35589204pac.7
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 01:59:49 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id w65si15223188pgw.107.2016.11.04.01.59.47
        for <linux-mm@kvack.org>;
        Fri, 04 Nov 2016 01:59:48 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-26-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-26-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 25/33] userfaultfd: shmem: add userfaultfd hook for shared memory faults
Date: Fri, 04 Nov 2016 16:59:32 +0800
Message-ID: <07ce01d23679$c2be2670$483a7350$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, 'Mike Kravetz' <mike.kravetz@oracle.com>, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

> @@ -1542,7 +1544,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
>   */
>  static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
> -	struct mm_struct *fault_mm, int *fault_type)
> +	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
>  {
>  	struct address_space *mapping = inode->i_mapping;
>  	struct shmem_inode_info *info;
> @@ -1597,7 +1599,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  	 */
>  	info = SHMEM_I(inode);
>  	sbinfo = SHMEM_SB(inode->i_sb);
> -	charge_mm = fault_mm ? : current->mm;
> +	charge_mm = vma ? vma->vm_mm : current->mm;
> 
>  	if (swap.val) {
>  		/* Look it up and read it in.. */
> @@ -1607,7 +1609,8 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
>  			if (fault_type) {
>  				*fault_type |= VM_FAULT_MAJOR;
>  				count_vm_event(PGMAJFAULT);
> -				mem_cgroup_count_vm_event(fault_mm, PGMAJFAULT);
> +				mem_cgroup_count_vm_event(vma->vm_mm,
> +							  PGMAJFAULT);
Seems vma is not valid in some cases.

>  			}
>  			/* Here we actually start the io */
>  			page = shmem_swapin(swap, gfp, info, index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
