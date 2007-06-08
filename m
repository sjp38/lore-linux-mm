Date: Thu, 7 Jun 2007 22:47:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
In-Reply-To: <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, KAMEZAWA Hiroyuki wrote:

> Index: devel-2.6.22-rc4-mm2/include/linux/rmap.h
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/include/linux/rmap.h
> +++ devel-2.6.22-rc4-mm2/include/linux/rmap.h
> @@ -42,6 +42,36 @@ static inline void anon_vma_free(struct 
>  	kmem_cache_free(anon_vma_cachep, anon_vma);
>  }
>  
> +#ifdef  CONFIG_MIGRATION
> +/*
> + * anon_vma->head works as refcnt for anon_vma struct.
> + * Migration needs one reference to anon_vma while unmapping -> remapping.
> + * dummy vm_area_struct is used for adding one ref to anon_vma.
> + *
> + * This means a list-walker of anon_vma->head have to check vma is dummy
> + * or not. please use is_dummy_vma() for check.
> + */
> +
> +extern struct anon_vma *anon_vma_hold(struct page *, struct vm_area_struct *);
> +extern void anon_vma_release(struct anon_vma *, struct vm_area_struct *);
> +
> +static inline void init_dummy_vma(struct vm_area_struct *vma)
> +{
> +	vma->vm_mm = NULL;
> +}
> +
> +static inline int is_dummy_vma(struct vm_area_struct *vma)
> +{
> +	if (unlikely(vma->vm_mm == NULL))
> +		return 1;
> +	return 0;
> +}
> +#else
> +static inline int is_dummy_vma(struct vm_area_struct *vma) {
> +	return 0;
> +}
> +#endif
> +
>  static inline void anon_vma_lock(struct vm_area_struct *vma)
>  {
>  	struct anon_vma *anon_vma = vma->anon_vma;

Could you fold as much as possible into mm/migrate.c?

> Index: devel-2.6.22-rc4-mm2/mm/rmap.c
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/mm/rmap.c
> +++ devel-2.6.22-rc4-mm2/mm/rmap.c
> @@ -203,6 +203,35 @@ static void page_unlock_anon_vma(struct 
>  	spin_unlock(&anon_vma->lock);
>  	rcu_read_unlock();
>  }
> +#ifdef CONFIG_MIGRATION
> +/*
> + * Record anon_vma in holder->anon_vma.
> + * Returns 1 if vma is linked to anon_vma. otherwise 0.
> + */
> +struct anon_vma *
> +anon_vma_hold(struct page *page, struct vm_area_struct *holder)
> +{
> +	struct anon_vma *anon_vma = NULL;
> +	holder->anon_vma = NULL;
> +	anon_vma = page_lock_anon_vma(page);
> +	if (anon_vma && !list_empty(&anon_vma->head)) {
> +		init_dummy_vma(holder);
> +		holder->anon_vma = anon_vma;
> +		__anon_vma_link(holder);
> +	}
> +	if (anon_vma)
> +		page_unlock_anon_vma(anon_vma);
> +	return holder->anon_vma;
> +}
> +
> +void anon_vma_release(struct anon_vma *anon_vma, struct vm_area_struct *holder)
> +{
> +	if (!anon_vma)
> +		return;
> +	BUG_ON(anon_vma != holder->anon_vma);
> +	anon_vma_unlink(holder);
> +}
> +#endif

This is mostly also specific to page migration?

> @@ -333,6 +362,8 @@ static int page_referenced_anon(struct p
>  
>  	mapcount = page_mapcount(page);
>  	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> +		if (is_dummy_vma(vma))
> +			continue;
>  		referenced += page_referenced_one(page, vma, &mapcount);
>  		if (!mapcount)
>  			break;
> @@ -864,6 +895,8 @@ static int try_to_unmap_anon(struct page
>  		return ret;
>  
>  	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
> +		if (is_dummy_vma(vma))
> +			continue;
>  		ret = try_to_unmap_one(page, vma, migration);
>  		if (ret == SWAP_FAIL || !page_mapped(page))
>  			break;

Could you avoid these checks by having page_referend_one fail
appropriately on the dummy vma?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
