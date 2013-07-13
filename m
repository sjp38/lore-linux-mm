Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 548CB6B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 20:54:44 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v14so9077005pde.32
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 17:54:43 -0700 (PDT)
Date: Fri, 12 Jul 2013 17:54:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
In-Reply-To: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
Message-ID: <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Adding the essential David Gibson to the Cc list.

On Fri, 12 Jul 2013, Davidlohr Bueso wrote:

> The hugetlb_instantiation_mutex serializes hugepage allocation and instantiation
> in the page directory entry. It was found that this mutex can become quite contended
> during the early phases of large databases which make use of huge pages - for instance
> startup and initial runs. One clear example is a 1.5Gb Oracle database, where lockstat
> reports that this mutex can be one of the top 5 most contended locks in the kernel during
> the first few minutes:
> 
> hugetlb_instantiation_mutex:      10678     10678
>              ---------------------------
>              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
>              ---------------------------
>              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e>] hugetlb_fault+0x9e/0x340
> 
> contentions:          10678
> acquisitions:         99476
> waittime-total: 76888911.01 us
> 
> Instead of serializing each hugetlb fault, we can deal with concurrent faults for pages
> in different vmas. The per-vma mutex is initialized when creating a new vma. So, back to
> the example above, we now get much less contention:
> 
>  &vma->hugetlb_instantiation_mutex:  1         1
>        ---------------------------------
>        &vma->hugetlb_instantiation_mutex       1   [<ffffffff8115e216>] hugetlb_fault+0xa6/0x350
>        ---------------------------------
>        &vma->hugetlb_instantiation_mutex       1    [<ffffffff8115e216>] hugetlb_fault+0xa6/0x350
> 
> contentions:          1
> acquisitions:    108092
> waittime-total:  621.24 us
> 
> Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>

I agree this is a problem worth solving,
but I doubt this patch is the right solution.

> ---
>  include/linux/mm_types.h |  3 +++
>  mm/hugetlb.c             | 12 +++++-------
>  mm/mmap.c                |  3 +++
>  3 files changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index fb425aa..b45fd87 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -289,6 +289,9 @@ struct vm_area_struct {
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +#ifdef CONFIG_HUGETLB_PAGE
> +	struct mutex hugetlb_instantiation_mutex;
> +#endif
>  };

Bloating every vm_area_struct with a rarely useful mutex:
I'm sure you can construct cases where per-vma mutex would win over
per-mm mutex, but they will have to be very common to justify the bloat.

>  
>  struct core_thread {
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 83aff0a..12e665b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -137,12 +137,12 @@ static inline struct hugepage_subpool *subpool_vma(struct vm_area_struct *vma)
>   * The region data structures are protected by a combination of the mmap_sem
>   * and the hugetlb_instantion_mutex.  To access or modify a region the caller
>   * must either hold the mmap_sem for write, or the mmap_sem for read and
> - * the hugetlb_instantiation mutex:
> + * the vma's hugetlb_instantiation mutex:

Reading the existing comment, this change looks very suspicious to me.
A per-vma mutex is just not going to provide the necessary exclusion, is
it?  (But I recall next to nothing about these regions and reservations.)

>   *
>   *	down_write(&mm->mmap_sem);
>   * or
>   *	down_read(&mm->mmap_sem);
> - *	mutex_lock(&hugetlb_instantiation_mutex);
> + *	mutex_lock(&vma->hugetlb_instantiation_mutex);
>   */
>  struct file_region {
>  	struct list_head link;
> @@ -2547,7 +2547,7 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  /*
>   * Hugetlb_cow() should be called with page lock of the original hugepage held.
> - * Called with hugetlb_instantiation_mutex held and pte_page locked so we
> + * Called with the vma's hugetlb_instantiation_mutex held and pte_page locked so we
>   * cannot race with other handlers or page migration.
>   * Keep the pte_same checks anyway to make transition from the mutex easier.
>   */
> @@ -2847,7 +2847,6 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret;
>  	struct page *page = NULL;
>  	struct page *pagecache_page = NULL;
> -	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
>  	struct hstate *h = hstate_vma(vma);
>  
>  	address &= huge_page_mask(h);
> @@ -2872,7 +2871,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * get spurious allocation failures if two CPUs race to instantiate
>  	 * the same page in the page cache.
>  	 */
> -	mutex_lock(&hugetlb_instantiation_mutex);
> +	mutex_lock(&vma->hugetlb_instantiation_mutex);
>  	entry = huge_ptep_get(ptep);
>  	if (huge_pte_none(entry)) {
>  		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
> @@ -2943,8 +2942,7 @@ out_page_table_lock:
>  	put_page(page);
>  
>  out_mutex:
> -	mutex_unlock(&hugetlb_instantiation_mutex);
> -
> +	mutex_unlock(&vma->hugetlb_instantiation_mutex);
>  	return ret;
>  }
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index fbad7b0..8f0b034 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1543,6 +1543,9 @@ munmap_back:
>  	vma->vm_page_prot = vm_get_page_prot(vm_flags);
>  	vma->vm_pgoff = pgoff;
>  	INIT_LIST_HEAD(&vma->anon_vma_chain);
> +#ifdef CONFIG_HUGETLB_PAGE
> +	mutex_init(&vma->hugetlb_instantiation_mutex);
> +#endif
>  
>  	error = -EINVAL;	/* when rejecting VM_GROWSDOWN|VM_GROWSUP */
>  
> -- 
> 1.7.11.7

The hugetlb_instantiation_mutex has always been rather an embarrassment:
it would be much more satisfying to remove the need for it, than to split
it in this way.  (Maybe a technique like THP sometimes uses, marking an
entry as in transition while the new entry is prepared.)

But I suppose it would not have survived so long if that were easy,
and I think it may have grown some subtle dependants over the years -
as the region comment indicates.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
