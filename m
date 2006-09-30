Date: Sat, 30 Sep 2006 20:52:57 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/2] htlb shared page table
In-Reply-To: <000101c6e428$31d44ee0$ff0da8c0@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0609302009270.9929@blonde.wat.veritas.com>
References: <000101c6e428$31d44ee0$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2006, Chen, Kenneth W wrote:

> Following up with the work on shared page table, here is a re-post of
> shared page table for hugetlb memory.  Dave's latest patch restricts the
> page table sharing at pmd level in order to simplify some of the complexity
> for normal page, but that simplification cuts out all the performance
> benefit for hugetlb on x86-64 and ia32.
> 
> The following patch attempt to kick that optimization back in for hugetlb
> memory and allow pt sharing at second level.  It is nicely self-contained
> within hugetlb subsystem.  With no impact to generic VM at all.

I think you need to say a bit more for this description of 1/2.

> 
> Imprecise RSS accounting is an irritating ill effect with pt sharing. 
> After consulted with several VM experts, I have tried various methods to
> solve that problem: (1) iterate through all mm_structs that share the PT
> and increment count; (2) keep RSS count in page table structure and then
> sum them up at reporting time.  None of the above methods yield any
> satisfactory implementation.
> 
> Since process RSS accounting is pure information only, I propose we don't
> count them at all for hugetlb page.  rlimit has such field, though there is
> absolutely no enforcement on limiting that resource.  One other method is
> to account all RSS at hugetlb mmap time regardless they are faulted or not.
> I opt for the simplicity of no accounting at all.

Whereas this is good comment, but it all belongs to your 2/2 and should
move there.  2/2 should also have a distinct subject, "htlb forget rss"
or something like that.  (Though elsewhere I've suggested a 1/3 first,
to fix the existing TLB flush issue.)

> --- ./arch/i386/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
> +++ ./arch/i386/mm/hugetlbpage.c	2006-09-29 14:55:13.000000000 -0700
> @@ -17,6 +17,104 @@
>  #include <asm/tlb.h>
>  #include <asm/tlbflush.h>
>  
> +static unsigned long page_table_shareable(struct vm_area_struct *svma,
> +			 struct vm_area_struct *vma,
> +			 unsigned long addr, unsigned long idx)

Andrew will love it if you make that pgoff_t idx.

> +{
> +	unsigned long base = addr & PUD_MASK;
> +	unsigned long end = base + PUD_SIZE;
> +

Argh, a blank line.

> +	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
> +				svma->vm_start;

Does that work right when svma->vm_pgoff > idx?
I think so, but please make sure.

> +	unsigned long sbase = saddr & PUD_MASK;
> +	unsigned long s_end = sbase + PUD_SIZE;
> +
> +	/*
> +	 * match the virtual addresses, permission and the alignment of the
> +	 * page table page.
> +	 */
> +	if (pmd_index(addr) != pmd_index(saddr) ||
> +	    vma->vm_flags != svma->vm_flags ||
> +	    base < vma->vm_start || vma->vm_end < end ||
> +	    sbase < svma->vm_start || svma->vm_end < s_end)
> +		return 0;
> +
> +	return saddr;
> +}

Thanks for giving that some thought, I expect it's about right now,
though needs testing to be sure.  Though x86_64 is the important case,
does it work right on i386 2level and i386 3level?  Sometimes the
4level fallbacks don't work out quite as one would wish, need to be
checked.

If I've got the levels right, there's no chance of sharing htlb
table on i386 2level, and on i386 3level (PAE) there's a chance,
but only if non-standard address space layout or statically linked
(in the standard layout, text+data+bss occupy the first pmd, shared
libraries the second pmd, stack the third pmd, kernel the fourth).

Though that raises an efficiency issue.  Some of those checks you've
got there in page_table_shareable, the checks on base and end against
vma, are a waste of time to keep repeating here: huge_pte_share should
make those checks, along with when it checks VM_MAYSHARE, and go no
further if they fail.  That will shortcircuit many prio_tree searches:
it's only the interior of _huge_ hugetlb mappings that are going to
get any page table sharing, don't waste time for the rest of them.

> +
> +/*
> + * search for a shareable pmd page for hugetlb.
> + */
> +static void huge_pte_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
> +{
> +	struct vm_area_struct *vma = find_vma(mm, addr);

I claimed in my other mail that I was going to save you more find_vmas;
but no, that's rubbish, you do have to do this one now.

> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	unsigned long idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
> +			    vma->vm_pgoff;

pgoff_t.  Or perhaps not, be careful.  Check with fs/hugetlbfs/inode.c,
I think you'll be surprised to find that PAGE_SHIFT isn't the right
shift to use here, that the vma_prio_tree for a hugetlb area needs
HPAGE_SHIFT instead (it begins to make sense when you consider
efficient use of the radix tree for huge pages).  Test!

> +	struct prio_tree_iter iter;
> +	struct vm_area_struct *svma;
> +	unsigned long saddr;
> +	pte_t *spte = NULL;
> +
> +	if (!vma->vm_flags & VM_MAYSHARE)
> +		return;

So add some base/end checking against vma here.

> +
> +	spin_lock(&mapping->i_mmap_lock);
> +	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
> +		if (svma == vma || !down_read_trylock(&svma->vm_mm->mmap_sem))
> +			continue;

Good, yes: trylocks are never very satisfying,
but this is how it has to be I think.

> +
> +		saddr = page_table_shareable(svma, vma, addr, idx);
> +		if (saddr) {
> +			spte = huge_pte_offset(svma->vm_mm, saddr);
> +			if (spte)
> +				get_page(virt_to_page(spte));
> +		}
> +		up_read(&svma->vm_mm->mmap_sem);
> +		if (spte)
> +			break;
> +	}
> +
> +	if (!spte)
> +		goto out;
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (pud_none(*pud))
> +		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
> +	else
> +		put_page(virt_to_page(spte));
> +	spin_unlock(&mm->page_table_lock);
> +out:
> +	spin_unlock(&mapping->i_mmap_lock);

Yup.  Except that you don't usually have i_mmap_lock at the unsharing
end, have fooled yourself into thinking a random mmap_sem is enough,
need to go back to your Wednesday mods.

> --- ./arch/sh/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
> +++ ./arch/sh/mm/hugetlbpage.c	2006-09-29 14:51:20.000000000 -0700
> @@ -53,6 +53,12 @@ pte_t *huge_pte_offset(struct mm_struct 
>  	return pte;
>  }
>  
> +int
> +huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
> +{
> +	return 0;
> +}
> +

int huge_pte_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
is Linus' preference, all on one line, in each of the arches.  As in the
line you see below.  Except that arch/sh/mm/hugetlbpage.c has moved on
since 2.6.18, that line's gone, you need to rediff against current.

>  void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>  		     pte_t *ptep, pte_t entry)
>  {

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
