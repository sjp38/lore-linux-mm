Received: by nf-out-0910.google.com with SMTP id e27so585528nfd
        for <linux-mm@kvack.org>; Thu, 30 Aug 2007 16:41:03 -0700 (PDT)
Message-ID: <49e98fc50708301641h16b8dc6fsce7a4b4dadf9ec60@mail.gmail.com>
Date: Fri, 31 Aug 2007 01:41:03 +0200
From: "=?ISO-8859-1?Q?Javier_Cabezas_Rodr=EDguez?=" <jcabezas@ac.upc.edu>
Reply-To: jcabezas@ac.upc.edu
Subject: Re: Selective swap out of processes
In-Reply-To: <46D66E31.9030202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1188320070.11543.85.camel@bastion-laptop>
	 <46D4DBF7.7060102@yahoo.com.au>
	 <1188383827.11270.36.camel@bastion-laptop>
	 <1188410818.9682.2.camel@bastion-laptop>
	 <46D66E31.9030202@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, haveblue@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have modified the code so it now uses get_user_pages. I'm also using
the function posted by Dave Hansen in this thread to free each page.
However my module is still not able to free any page. I inspect the
smaps entries of each process in /proc before/after executing my code
to check it. The full code is posted next; don't worry, it's quite
short. The entry point is free_procs, called from a procfs handler
when a number is written to "/proc/swapper" (created by my module).
The processes are in UNINTERRUPTIBLE_SLEEP state before I try to swap
them out.

Can someone find any obvious problem in the code?

Thanks.

Javi


int try_to_put_page_in_swap(struct page *page)
{
  get_page(page);

  if (page_count(page) == 1) /* page was freed from under us. So we are done. */
    return -EAGAIN;

  lock_page(page);

  if (PageWriteback(page))
    wait_on_page_writeback(page);

  try_to_unmap(page, 0);

  unlock_page(page);
  put_page(page);
  return 0;
}


int free_process(struct vm_area_struct * vma, struct task_struct * p)
{
  int write;
  int npages;
  struct page ** pages;
  int i;

  spin_lock(&p->mm->page_table_lock);
  write = (vma->vm_flags & VM_WRITE) != 0;
  npages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
  pages = kmalloc(npages * sizeof(struct page *), GFP_KERNEL);

  if (!pages)
    return -ENOMEM;

  npages = get_user_pages(p, p->mm, vma->vm_start, npages, write, 0,
pages, NULL);

  kfree(pages);
  spin_unlock(&p->mm->page_table_lock);

  for (i = 0; i < npages; i++)
    try_to_put_page_in_swap(pages[i]);

  return npages;
}

void free_procs(void)
{
  struct task_struct *g, *p;
  struct vm_area_struct * vma;
  int c, count;

  read_lock(&tasklist_lock);
  do_each_thread(g, p) {
    if (!p->pinned) { /* This process can be swapped out */
      down_read(&p->mm->mmap_sem);
      for (vma = p->mm->mmap, count = 0; vma; vma = vma->vm_next) {
        if ((c = free_process(vma, p)) == -ENOMEM) {
          printk("VMC: Out of Memory\n");
          up_read(&p->mm->mmap_sem);
          goto out;
        }
        count += c;
      }
      up_read(&p->mm->mmap_sem);
      printk("VMC: Process %d. %d pages freed\n", p->pid, count);
    }
  } while_each_thread(g, p);

out:
  read_unlock(&tasklist_lock);
}

On 8/30/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Javier Cabezas Rodriguez wrote:
> >>My code calls the following function for each VMA of the process.  Are
> >>there errors in the function?:
> >
> >
> > Sorry. I forgot some lines:
> >
> > int my_free_pages(struct vm_area_struct * vma, struct mm_struct * mm)
> > {
> >       LIST_HEAD(page_list);
> >       unsigned long nr_taken;
> >       struct zone * zone = NULL;
> >       int ret;
> >       pte_t *pte_k;
> >       pud_t *pud;
> >       pmd_t *pmd;
> >       unsigned long addr;
> >       struct page * p;
> >       struct scan_control sc;
> >
> >       sc.gfp_mask = __GFP_FS;
> >       sc.may_swap = 1;
> >       sc.may_writepage = 1;
> >
> >       for (addr = vma->vm_start, nr_taken = 0; addr < vma->vm_end; addr +=
> > PAGE_SIZE, nr_taken++) {
> >               pgd_t *pgd = pgd_offset(mm, addr);
> >               if (pgd_none(*pgd))
> >                       return;
> >               pud = pud_offset(pgd, addr);
> >               if (pud_none(*pud))
> >                       return;
> >               pmd = pmd_offset(pud, addr);
> >               if (pmd_none(*pmd))
> >                       return;
> >               if (pmd_large(*pmd))
> >                       pte_k = (pte_t *)pmd;
> >               else
> >                       pte_k = pte_offset_kernel(pmd, addr);
> >
> >               if (pte_k && pte_present(*pte_k)) {
> >                       p = pte_page(*pte_k);
> >                       if (!zone)
> >                               zone = page_zone(p);
> >
> >                       ptep_clear_flush_young(vma, addr, pte_k);
> >                       del_page_from_lru(zone, p);
> >                       list_add(&p->lru, &page_list);
> >               }
> >       }
> >
> >       spin_lock_irq(&zone->lru_lock);
> >       __mod_zone_page_state(zone, NR_INACTIVE, -nr_taken);
> >       zone->pages_scanned += nr_taken;
> >       spin_unlock_irq(&zone->lru_lock);
> >
> >       printk("VMC: %lu pages set to be freed\n", nr_taken);
> >       printk("VMC: %d pages freed\n", ret =
> > shrink_page_list_vmswap(&page_list, &sc, PAGEOUT_IO_SYNC));
> > }
>
> I don't know if that's right or not really, without more context,
> but it doesn't look like you have the right page table walking
> locking or page refcounting (and you probably don't want to simply
> be returning when you encounter the first empty page table entry).
>
> Anyway. I'd be inclined to not do your own page table walking at
> this stage and begin by using get_user_pages() to do it for you.
> Then if you get to the stage of wanting to optimise it, you could
> copy the get_user_pages code, and use that as a starting point.
>
> --
> SUSE Labs, Novell Inc.
>


-- 


Javi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
