Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m17FE0lZ023739
	for <linux-mm@kvack.org>; Thu, 7 Feb 2008 10:14:00 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m17FE01X249988
	for <linux-mm@kvack.org>; Thu, 7 Feb 2008 10:14:00 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m17FE0et022200
	for <linux-mm@kvack.org>; Thu, 7 Feb 2008 10:14:00 -0500
Subject: Re: [PATCH] hugetlb: add locking for overcommit sysctl
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080206230259.GD3477@us.ibm.com>
References: <20080206230259.GD3477@us.ibm.com>
Content-Type: text/plain
Date: Thu, 07 Feb 2008 09:19:44 -0600
Message-Id: <1202397584.11987.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-06 at 15:02 -0800, Nishanth Aravamudan wrote:
> When I replaced hugetlb_dynamic_pool with nr_overcommit_hugepages I used
> proc_doulongvec_minmax() directly. However, hugetlb.c's locking rules
> require that all counter modifications occur under the hugetlb_lock. Add
> a callback into the hugetlb code similar to the one for nr_hugepages.
> Grab the lock around the manipulation of nr_overcommit_hugepages in
> proc_doulongvec_minmax().
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Adam Litke <agl@us.ibm.com>

> ---
> I noticed that the nr_hugepages sysctl uses a helper variable,
> max_huge_pages to do the same thing. Is that because of locking
> requirements (undocmented) for proc_doulongvec_minmax() or because of
> the more complicated manipulation of the pool state for that sysctl? If
> the former, I will need to modify this patch.
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 30d606a..7ca198b 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -17,6 +17,7 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
>  }
> 
>  int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
> +int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
>  int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
>  int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 5e2ad5b..92fef8d 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -973,7 +973,7 @@ static struct ctl_table vm_table[] = {
>  		.data		= &nr_overcommit_huge_pages,
>  		.maxlen		= sizeof(nr_overcommit_huge_pages),
>  		.mode		= 0644,
> -		.proc_handler	= &proc_doulongvec_minmax,
> +		.proc_handler	= &hugetlb_overcommit_handler,
>  	},
>  #endif
>  	{
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1a56420..d9a3803 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -605,6 +605,16 @@ int hugetlb_treat_movable_handler(struct ctl_table *table, int write,
>  	return 0;
>  }
> 
> +int hugetlb_overcommit_handler(struct ctl_table *table, int write,
> +			struct file *file, void __user *buffer,
> +			size_t *length, loff_t *ppos)
> +{
> +	spin_lock(&hugetlb_lock);
> +	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> +	spin_unlock(&hugetlb_lock);
> +	return 0;
> +}
> +
>  #endif /* CONFIG_SYSCTL */
> 
>  int hugetlb_report_meminfo(char *buf)
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
