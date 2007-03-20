Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l2KNQKOq002669
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 19:26:20 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2KNS3Ve064530
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:28:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2KNS39H015407
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:28:03 -0600
Subject: Re: [PATCH 4/7] unmap_page_range for hugetlb
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070319200544.17168.13231.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
	 <20070319200544.17168.13231.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 20 Mar 2007 16:27:49 -0700
Message-Id: <1174433269.26166.172.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-03-19 at 13:05 -0700, Adam Litke wrote:
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  fs/hugetlbfs/inode.c    |    3 ++-
>  include/linux/hugetlb.h |    4 ++--
>  mm/hugetlb.c            |   12 ++++++++----
>  mm/memory.c             |   10 ++++------
>  4 files changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index d0b4b46..198efa7 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -289,7 +289,7 @@ hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
>  			v_offset = 0;
> 
>  		__unmap_hugepage_range(vma,
> -				vma->vm_start + v_offset, vma->vm_end);
> +				vma->vm_start + v_offset, vma->vm_end, 0);
>  	}
>  }

Did you mean NULL instead of 0 here?

> @@ -568,6 +568,7 @@ const struct file_operations hugetlbfs_file_operations = {
>  static const struct pagetable_operations_struct hugetlbfs_pagetable_ops = {
>  	.copy_vma		= copy_hugetlb_page_range,
>  	.pin_pages		= follow_hugetlb_page,
> +	.unmap_page_range	= unmap_hugepage_range,
>  };
> 
>  static const struct inode_operations hugetlbfs_dir_inode_operations = {
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 3f3e7a6..502c2f8 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -17,8 +17,8 @@ static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
>  int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
>  int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
>  int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
> -void unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
> -void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long);
> +unsigned long unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long, long *);
> +void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned long, long *);
>  int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
>  int hugetlb_report_meminfo(char *);
>  int hugetlb_report_node_meminfo(int, char *);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 36db012..d902fb9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -356,7 +356,7 @@ nomem:
>  }
> 
>  void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> -			    unsigned long end)
> +			    unsigned long end, long *zap_work)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	unsigned long address;
> @@ -399,10 +399,13 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  		list_del(&page->lru);
>  		put_page(page);
>  	}
> +
> +	if (zap_work)
> +		*zap_work -= (end - start) / (HPAGE_SIZE / PAGE_SIZE);
>  }
> 
> -void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> -			  unsigned long end)
> +unsigned long unmap_hugepage_range(struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end, long *zap_work)
>  {
>  	/*
>  	 * It is undesirable to test vma->vm_file as it should be non-null
> @@ -414,9 +417,10 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  	 */
>  	if (vma->vm_file) {
>  		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
> -		__unmap_hugepage_range(vma, start, end);
> +		__unmap_hugepage_range(vma, start, end, zap_work);
>  		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
>  	}
> +	return end;
>  }
> 
>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> diff --git a/mm/memory.c b/mm/memory.c
> index 01256cf..a3bcaf3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -839,12 +839,10 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
>  				tlb_start_valid = 1;
>  			}
> 
> -			if (unlikely(is_vm_hugetlb_page(vma))) {
> -				unmap_hugepage_range(vma, start, end);
> -				zap_work -= (end - start) /
> -						(HPAGE_SIZE / PAGE_SIZE);
> -				start = end;
> -			} else
> +			if (unlikely(has_pt_op(vma, unmap_page_range)))
> +				start = pt_op(vma, unmap_page_range)
> +						(vma, start, end, &zap_work);
> +			else
>  				start = unmap_page_range(*tlbp, vma,
>  						start, end, &zap_work, details);

unmap_vmas() is the sole caller of unmap_page_range().  Would it make
sense to move the hook inside of unmap_page_range()?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
