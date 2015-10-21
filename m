Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BE1286B0038
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 20:11:58 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so37157553pac.3
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 17:11:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id hm17si8798888pad.218.2015.10.20.17.11.57
        for <linux-mm@kvack.org>;
        Tue, 20 Oct 2015 17:11:58 -0700 (PDT)
Subject: Re: [PATCH v2 2/4] mm/hugetlb: Setup hugetlb_falloc during fallocate
 hole punch
References: <1445385142-29936-1-git-send-email-mike.kravetz@oracle.com>
 <1445385142-29936-3-git-send-email-mike.kravetz@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5626D84C.6060204@intel.com>
Date: Tue, 20 Oct 2015 17:11:56 -0700
MIME-Version: 1.0
In-Reply-To: <1445385142-29936-3-git-send-email-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>

On 10/20/2015 04:52 PM, Mike Kravetz wrote:
>  	if (hole_end > hole_start) {
>  		struct address_space *mapping = inode->i_mapping;
> +		DECLARE_WAIT_QUEUE_HEAD_ONSTACK(hugetlb_falloc_waitq);
> +		/*
> +		 * Page faults on the area to be hole punched must be stopped
> +		 * during the operation.  Initialize struct and have
> +		 * inode->i_private point to it.
> +		 */
> +		struct hugetlb_falloc hugetlb_falloc = {
> +			.waitq = &hugetlb_falloc_waitq,
> +			.start = hole_start >> hpage_shift,
> +			.end = hole_end >> hpage_shift
> +		};
...
> @@ -527,6 +550,12 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>  						hole_end  >> PAGE_SHIFT);
>  		i_mmap_unlock_write(mapping);
>  		remove_inode_hugepages(inode, hole_start, hole_end);
> +
> +		spin_lock(&inode->i_lock);
> +		inode->i_private = NULL;
> +		wake_up_all(&hugetlb_falloc_waitq);
> +		spin_unlock(&inode->i_lock);

I see the shmem code doing something similar.  But, in the end, we're
passing the stack-allocated 'hugetlb_falloc_waitq' over to the page
faulting thread.  Is there something subtle that keeps
'hugetlb_falloc_waitq' from becoming invalid while the other task is
sleeping?

That wake_up_all() obviously can't sleep, but it seems like the faulting
thread's finish_wait() *HAS* to run before wake_up_all() can return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
