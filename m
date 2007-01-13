Subject: Re: [PATCH 0/29] Page Table Interface Explanation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Content-Type: text/plain
Date: Sat, 13 Jan 2007 20:29:01 +0100
Message-Id: <1168716541.5975.23.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>                 PAGE TABLE INTERFACE
> 
> int create_user_page_table(struct mm_struct *mm);
> 
> void destroy_user_page_table(struct mm_struct *mm);
> 
> pte_t *build_page_table(struct mm_struct *mm, unsigned long address,
> 		pt_path_t *pt_path);
> 
> pte_t *lookup_page_table(struct mm_struct *mm, unsigned long address,
> 		pt_path_t *pt_path);



> void free_pt_range(struct mmu_gather **tlb, unsigned long addr,
> 		unsigned long end, unsigned long floor, unsigned long ceiling);
> 
> int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> 		unsigned long addr, unsigned long end, struct vm_area_struct *vma);
> 
> unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
>         struct vm_area_struct *vma, unsigned long addr, unsigned long end,
>         long *zap_work, struct zap_details *details);
> 
> int zeromap_build_iterator(struct mm_struct *mm,
> 		unsigned long addr, unsigned long end, pgprot_t prot);
> 
> int remap_build_iterator(struct mm_struct *mm,
> 		unsigned long addr, unsigned long end, unsigned long pfn,
> 		pgprot_t prot);
> 
> void change_protection_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, pgprot_t newprot,
> 		int dirty_accountable);
> 
> void vunmap_read_iterator(unsigned long addr, unsigned long end);
> 
> int vmap_build_iterator(unsigned long addr,
> 		unsigned long end, pgprot_t prot, struct page ***pages);
> 
> int unuse_vma_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
> 
> void smaps_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, struct mem_size_stats *mss);
> 
> int check_policy_read_iterator(struct vm_area_struct *vma,
> 		unsigned long addr, unsigned long end, const nodemask_t *nodes,
> 		unsigned long flags, void *private);
> 
> unsigned long move_page_tables(struct vm_area_struct *vma,
> 		unsigned long old_addr, struct vm_area_struct *new_vma,
> 		unsigned long new_addr, unsigned long len);
> 

weird naming, functions are not iterators, if named after what they do
it should be *_iteration.

But still, I would have expected an iterator based interface; something
along the lines of:

typedef struct pti_struct {
  struct mm_struct *mm;
  pgd_t *pgd;
  pud_t *pud;
  pmd_t *pmd;
  pte_t *pte;
  spinlock_t *ptl;
  unsigned long address;
} pti_t

with accessors like:

#define pti_address(pti) (pti).address
#define pti_pte(pti) (pti).pte

and methods like:

bool pti_valid(pti_t *pti);
pti_t pti_lookup(struct mm_struct *mm, unsigned long address);
pti_t pti_acquire(struct mm_struct *mm, unsigned long address);
void pti_release(pti_t *pti);

bool pti_next(pti_t *pti);

so that you could write the typical loops like:

  int ret = 0;

  pti_t *pri = pti_lookup(mm, start);
  do_for_each_pti_range(pti, end) {
    if (per_pte_op(pti_pte(pti))) {
      ret = -EFOO;
      break;
    }
  } while_for_each_pti_range(pti, end);
  pti_release(pti);

  return ret;

where do_for_each_pti_range() and while_for_each_pti_range() look
something like:

#define do_for_each_pti_range(pti, end) \
  if (pti_valid(pti) && pti_address(pti) < end) do

#define while_for_each_pti_range(pti, end) \
  while (pti_next(pti) && pti_valid(pti) && pti_address(pti) < end)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
