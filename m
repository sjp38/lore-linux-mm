Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6B76B0039
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 16:52:57 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id i7so5846347oag.36
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 13:52:57 -0800 (PST)
Received: from g4t0014.houston.hp.com (g4t0014.houston.hp.com. [15.201.24.17])
        by mx.google.com with ESMTPS id so9si5599391oeb.36.2014.01.31.13.52.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 13:52:56 -0800 (PST)
Message-ID: <1391205168.3475.22.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2 6/6] mm, hugetlb: improve page-fault scalability
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Fri, 31 Jan 2014 13:52:48 -0800
In-Reply-To: <20140131130102.5d785fc8312060a4db8bd5a2@linux-foundation.org>
References: <1391189806-13319-1-git-send-email-davidlohr@hp.com>
	 <1391189806-13319-7-git-send-email-davidlohr@hp.com>
	 <20140131130102.5d785fc8312060a4db8bd5a2@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2014-01-31 at 13:01 -0800, Andrew Morton wrote:
> On Fri, 31 Jan 2014 09:36:46 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:
> 
> > From: Davidlohr Bueso <davidlohr@hp.com>
> > 
> > The kernel can currently only handle a single hugetlb page fault at a time.
> > This is due to a single mutex that serializes the entire path. This lock
> > protects from spurious OOM errors under conditions of low of low availability
> > of free hugepages. This problem is specific to hugepages, because it is
> > normal to want to use every single hugepage in the system - with normal pages
> > we simply assume there will always be a few spare pages which can be used
> > temporarily until the race is resolved.
> > 
> > Address this problem by using a table of mutexes, allowing a better chance of
> > parallelization, where each hugepage is individually serialized. The hash key
> > is selected depending on the mapping type. For shared ones it consists of the
> > address space and file offset being faulted; while for private ones the mm and
> > virtual address are used. The size of the table is selected based on a compromise
> > of collisions and memory footprint of a series of database workloads.
> > 
> > Large database workloads that make heavy use of hugepages can be particularly
> > exposed to this issue, causing start-up times to be painfully slow. This patch
> > reduces the startup time of a 10 Gb Oracle DB (with ~5000 faults) from 37.5 secs
> > to 25.7 secs. Larger workloads will naturally benefit even more.
> 
> hm, no magic bullet.  Where's the rest of the time being spent?

Parallel to this mutex issue, I'm seeing enormous amounts of time being
spent when zeroing pages. This of course also affects thp. For instance,
with these patches applied, I now see things like the following when
instantiating 10Gbs worth of hugepages:

-  21.44%           oracle  [kernel.kallsyms]     [k] clear_page_c                                                                                                               a??
   - clear_page_c                                                                                                                                                                a??
      - 98.51% hugetlb_no_page                                                                                                                                                   a??
           hugetlb_fault                                                                                                                                                         a??
           __handle_mm_fault                                                                                                                                                     a??
           handle_mm_fault                                                                                                                                                       a??
           __do_page_fault                                                                                                                                                       a??
           do_page_fault                                                                                                                                                         a??
         + page_fault                                                                                                                                                            a??
      + 1.20% get_page_from_freelist             

And this can only get worse, 10Gb DBs are rather small nowadays. Other
than not dirtying the cacheline with single-usage variables (rep stos
family), I haven't found a solution/workaround yet.

> >  
> > +#ifdef CONFIG_SMP
> > +	num_fault_mutexes = roundup_pow_of_two(8 * num_possible_cpus());
> > +#else
> > +	num_fault_mutexes = 1;
> > +#endif
> > +	htlb_fault_mutex_table =
> > +		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
> > +	if (!htlb_fault_mutex_table)
> > +		return -ENOMEM;
> 
> If htlb_fault_mutex_table==NULL, the kernel will later oops.  Let's
> just go BUG here.

Good point.

> 
> > +	for (i = 0; i < num_fault_mutexes; i++)
> > +		mutex_init(&htlb_fault_mutex_table[i]);
> >  	return 0;
> >  }
> >  module_init(hugetlb_init);
> > @@ -2767,15 +2790,14 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
> >  }
> >  
> >  static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > -			unsigned long address, pte_t *ptep, unsigned int flags)
> > +			   struct address_space *mapping, pgoff_t idx,
> > +			   unsigned long address, pte_t *ptep, unsigned int flags)
> >  {
> >  	struct hstate *h = hstate_vma(vma);
> >  	int ret = VM_FAULT_SIGBUS;
> >  	int anon_rmap = 0;
> > -	pgoff_t idx;
> >  	unsigned long size;
> >  	struct page *page;
> > -	struct address_space *mapping;
> >  	pte_t new_pte;
> >  	spinlock_t *ptl;
> >  
> > @@ -2790,9 +2812,6 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		return ret;
> >  	}
> >  
> > -	mapping = vma->vm_file->f_mapping;
> > -	idx = vma_hugecache_offset(h, vma, address);
> > -
> >  	/*
> >  	 * Use page lock to guard against racing truncation
> >  	 * before we get page_table_lock.
> > @@ -2902,17 +2921,53 @@ backout_unlocked:
> >  	goto out;
> >  }
> >  
> > +#ifdef CONFIG_SMP
> > +static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
> > +			    struct vm_area_struct *vma,
> > +			    struct address_space *mapping,
> > +			    pgoff_t idx, unsigned long address)
> > +{
> > +	unsigned long key[2];
> > +	u32 hash;
> > +
> > +	if (vma->vm_flags & VM_SHARED) {
> > +		key[0] = (unsigned long) mapping;
> > +		key[1] = idx;
> > +	} else {
> > +		key[0] = (unsigned long) mm;
> > +		key[1] = address >> huge_page_shift(h);
> > +	}
> > +
> > +	hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
> 
> This looks a bit overengineered to me.  What happens if we just do

IMO the key method better documents the hashing.

> 	hash = jhash2((u32 *)vma, sizeof(vma)/sizeof(u32), 0);
> 
> ?
> 
> > +	return hash & (num_fault_mutexes - 1);
> > +}
> > +#else
> > +/*
> > + * For uniprocesor systems we always use a single mutex, so just
> > + * return 0 and avoid the hashing overhead.
> > + */
> > +static u32 fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
> > +			    struct vm_area_struct *vma,
> > +			    struct address_space *mapping,
> > +			    pgoff_t idx, unsigned long address)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  			unsigned long address, unsigned int flags)
> >  {
> > -	pte_t *ptep;
> > -	pte_t entry;
> > +	pte_t *ptep, entry;
> >  	spinlock_t *ptl;
> >  	int ret;
> > +	u32 hash;
> > +	pgoff_t idx;
> >  	struct page *page = NULL;
> >  	struct page *pagecache_page = NULL;
> > -	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
> >  	struct hstate *h = hstate_vma(vma);
> > +	struct address_space *mapping;
> >  
> >  	address &= huge_page_mask(h);
> >  
> > @@ -2931,15 +2986,20 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	if (!ptep)
> >  		return VM_FAULT_OOM;
> >  
> > +	mapping = vma->vm_file->f_mapping;
> > +	idx = vma_hugecache_offset(h, vma, address);
> > +
> >  	/*
> >  	 * Serialize hugepage allocation and instantiation, so that we don't
> >  	 * get spurious allocation failures if two CPUs race to instantiate
> >  	 * the same page in the page cache.
> >  	 */
> > -	mutex_lock(&hugetlb_instantiation_mutex);
> > +	hash = fault_mutex_hash(h, mm, vma, mapping, idx, address);
> > +	mutex_lock(&htlb_fault_mutex_table[hash]);
> > +
> >  	entry = huge_ptep_get(ptep);
> >  	if (huge_pte_none(entry)) {
> > -		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
> > +		ret = hugetlb_no_page(mm, vma, mapping, idx, address, ptep, flags);
> >  		goto out_mutex;
> >  	}
> >  
> > @@ -3008,8 +3068,7 @@ out_ptl:
> >  	put_page(page);
> >  
> >  out_mutex:
> > -	mutex_unlock(&hugetlb_instantiation_mutex);
> > -
> > +	mutex_unlock(&htlb_fault_mutex_table[hash]);
> >  	return ret;
> 
> That's nice and simple.
> 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-hugetlb-improve-page-fault-scalability-fix
> 
> remove stray + characters, go BUG if hugetlb_init() kmalloc fails
> 
> Cc: Davidlohr Bueso <davidlohr@hp.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Looks good, thanks Andrew!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
