Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F41FA8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:26:09 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t7so4698644edr.21
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 02:26:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a26-v6si34347ejg.119.2018.12.17.02.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 02:26:08 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBHAOKGS099496
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:26:07 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pe84fcusy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:26:06 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 17 Dec 2018 10:26:05 -0000
Subject: Re: [PATCH 2/3] hugetlbfs: Use i_mmap_rwsem to fix page
 fault/truncate race
References: <20181203200850.6460-1-mike.kravetz@oracle.com>
 <20181203200850.6460-3-mike.kravetz@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Mon, 17 Dec 2018 15:55:28 +0530
MIME-Version: 1.0
In-Reply-To: <20181203200850.6460-3-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <27f8893b-57b3-088d-2d48-9e8acc5987bd@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 12/4/18 1:38 AM, Mike Kravetz wrote:
> hugetlbfs page faults can race with truncate and hole punch operations.
> Current code in the page fault path attempts to handle this by 'backing
> out' operations if we encounter the race.  One obvious omission in the
> current code is removing a page newly added to the page cache.  This is
> pretty straight forward to address, but there is a more subtle and
> difficult issue of backing out hugetlb reservations.  To handle this
> correctly, the 'reservation state' before page allocation needs to be
> noted so that it can be properly backed out.  There are four distinct
> possibilities for reservation state: shared/reserved, shared/no-resv,
> private/reserved and private/no-resv.  Backing out a reservation may
> require memory allocation which could fail so that needs to be taken
> into account as well.
> 
> Instead of writing the required complicated code for this rare
> occurrence, just eliminate the race.  i_mmap_rwsem is now held in read
> mode for the duration of page fault processing.  Hold i_mmap_rwsem
> longer in truncation and hold punch code to cover the call to
> remove_inode_hugepages.
> 
> Cc: <stable@vger.kernel.org>
> Fixes: ebed4bfc8da8 ("hugetlb: fix absurd HugePages_Rsvd")
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>   fs/hugetlbfs/inode.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 32920a10100e..3244147fc42b 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -505,8 +505,8 @@ static int hugetlb_vmtruncate(struct inode *inode, loff_t offset)
>   	i_mmap_lock_write(mapping);
>   	if (!RB_EMPTY_ROOT(&mapping->i_mmap.rb_root))
>   		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
> -	i_mmap_unlock_write(mapping);
>   	remove_inode_hugepages(inode, offset, LLONG_MAX);
> +	i_mmap_unlock_write(mapping);
>   	return 0;
>   }


We used to do remove_inode_hugepages()

	mutex_lock(&hugetlb_fault_mutex_table[hash]);
	i_mmap_lock_write(mapping);
	hugetlb_vmdelete_list(&mapping->i_mmap,
	i_mmap_unlock_write(mapping);

did we change the lock ordering with this patch?


> 
> @@ -540,8 +540,8 @@ static long hugetlbfs_punch_hole(struct inode *inode, loff_t offset, loff_t len)
>   			hugetlb_vmdelete_list(&mapping->i_mmap,
>   						hole_start >> PAGE_SHIFT,
>   						hole_end  >> PAGE_SHIFT);
> -		i_mmap_unlock_write(mapping);
>   		remove_inode_hugepages(inode, hole_start, hole_end);
> +		i_mmap_unlock_write(mapping);
>   		inode_unlock(inode);
>   	}
> 

-aneesh
