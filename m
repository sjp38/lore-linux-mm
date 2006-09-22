Date: Fri, 22 Sep 2006 14:21:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] shared page table for hugetlb page - v2
Message-Id: <20060922142117.eebc5e94.akpm@osdl.org>
In-Reply-To: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
References: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006 17:57:33 -0700
"Chen, Kenneth W" <kenneth.w.chen@intel.com> wrote:

> Following up with the work on shared page table, here is a re-post of
> shared page table for hugetlb memory.  Dave's latest patch restricts
> the page table sharing at pmd level in order to simplify some of the
> complexity for normal page, but that simplification cuts out all the
> performance benefit for hugetlb on x86-64 and ia32.
> 
> The following patch attempt to kick that optimization back in for hugetlb
> memory and allow pt sharing at second level.  It is nicely self-contained
> within hugetlb subsystem.  With no impact to generic VM at all, I think
> this patch is ready for mainline consideration.
> 
> Imprecise RSS accounting is an irritating ill effect with pt sharing.
> After consulted with several VM experts, I have tried various methods to
> solve that problem: (1) iterate through all mm_structs that share the PT
> and increment count; (2) keep RSS count in page table structure and then
> sum them up at reporting time. None of the above methods yield any
> satisfactory implementation.
> 
> Since process RSS accounting is pure information only, I propose we don't
> count them at all for hugetlb page. rlimit has such field, though there is
> absolutely no enforcement on limiting that resource. One other method is
> to account all RSS at hugetlb mmap time regardless they are faulted or not.
> I opt for the simplicity of no accounting at all.
> 
> 
> +/*
> + * search for a shareable pmd page for hugetlb.
> + */
> +void pmd_share(struct vm_area_struct *vma, pud_t *pud, unsigned long addr)
> +{
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	struct prio_tree_iter iter;
> +	struct vm_area_struct *svma;
> +	pte_t *spte = NULL;
> +
> +	if (!vma->vm_flags & VM_SHARED)
> +		return;
> +
> +	spin_lock(&mapping->i_mmap_lock);
> +	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap,
> +			      vma->vm_pgoff, vma->vm_pgoff) {
> +		if (svma == vma ||
> +		    !page_table_shareable(svma, vma, addr, PUD_SIZE))
> +			continue;
> +
> +		spin_lock(&svma->vm_mm->page_table_lock);
> +		spte = huge_pte_offset(svma->vm_mm, addr);
> +		if (spte)
> +			get_page(virt_to_page(spte));
> +		spin_unlock(&svma->vm_mm->page_table_lock);
> +		if (spte)
> +			break;
> +	}
> +	spin_unlock(&mapping->i_mmap_lock);
> +
> +	if (!spte)
> +		return;
> +
> +	spin_lock(&vma->vm_mm->page_table_lock);
> +	if (pud_none(*pud))
> +		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
> +	else
> +		put_page(virt_to_page(spte));
> +	spin_unlock(&vma->vm_mm->page_table_lock);
> +}

The locking in here makes me a bit queasy.  What causes *spte to still be
shareable after we've dropped i_mmap_lock?

(A patch which adds appropriate comments would be the preferred answer,
please...)


> +int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)

I think this function could do with a comment describing its
responsibilities.

> +{
> +	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
> +	pud_t *pud = pud_offset(pgd, *addr);
> +
> +	if (page_count(virt_to_page(ptep)) <= 1)
> +		return 0;

And this test.  It's testing the refcount of the pte page, yes?  Why?  What
does it mean when that refcount is zero?  Bug?  And when it's one?  We're
the last user, so the above test is an optimisation, yes?

Please, consider your code from the point of view of someone who is trying
to come up to speed with what it's doing, and be merciful ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
