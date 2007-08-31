Message-ID: <46D76203.303@yahoo.com.au>
Date: Fri, 31 Aug 2007 10:34:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Selective swap out of processes
References: <1188320070.11543.85.camel@bastion-laptop>	 <46D4DBF7.7060102@yahoo.com.au>	 <1188383827.11270.36.camel@bastion-laptop>	 <1188410818.9682.2.camel@bastion-laptop>	 <46D66E31.9030202@yahoo.com.au>	 <49e98fc50708301641h16b8dc6fsce7a4b4dadf9ec60@mail.gmail.com> <49e98fc50708301650q611f9b0fi762f9c5d8d5fae01@mail.gmail.com>
In-Reply-To: <49e98fc50708301650q611f9b0fi762f9c5d8d5fae01@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jcabezas@ac.upc.edu
Cc: haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Javier Cabezas Rodriguez wrote:
> Sorry. It was an old version:
> 
> int try_to_put_page_in_swap(struct page *page)
> {
>  get_page(page);
> 
>  if (page_count(page) == 1) /* page was freed from under us. So we are done. */
>    return -EAGAIN;
> 
>  lock_page(page);
> 
>  if (PageWriteback(page))
>    wait_on_page_writeback(page);
> 
>  try_to_unmap(page, 0);
> 
>  unlock_page(page);
>  put_page(page);
>  return 0;
> }

You'd surely have to add_to_swap here, and at some point
will want to also free the swapcache after writing it out.

Look at how the code in mm/vmscan.c does it.


> int free_process(struct vm_area_struct * vma, struct task_struct * p)
> {
>  int write;
>  int npages;
>  struct page ** pages;
>  int i;
> 
>  spin_lock(&p->mm->page_table_lock);

You rather need down_read(&mm->mmap_sem);

>  write = (vma->vm_flags & VM_WRITE) != 0;
>  npages = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
>  pages = kmalloc(npages * sizeof(struct page *), GFP_KERNEL);
> 
>  if (!pages)
>    return -ENOMEM;

Careful of just returning while you're holding a spinlock or
other resources.

> 
>  npages = get_user_pages(p, p->mm, vma->vm_start, npages, write, 0,
> pages, NULL);
> 
>  spin_unlock(&p->mm->page_table_lock);
> 
>  for (i = 0; i < npages; i++)
>    try_to_put_page_in_swap(pages[i]);
> 
>  kfree(pages);
>  return npages;

You have to carefully keep track of what is happening with your
page refcounts and make sure you're doing the right thing here.
For example, get_user_pages increments the refcounts, and it looks
like you don't decrement them again -- this will leave the page
permanently pinned in memory.

> }
> 
> void free_procs(void)
> {
>  struct task_struct *g, *p;
>  struct vm_area_struct * vma;
>  int c, count;
> 
>  read_lock(&tasklist_lock);
>  do_each_thread(g, p) {
>    if (!p->pinned) { /* This process can be swapped out */
>      down_read(&p->mm->mmap_sem);

Ah, you have down_read here. So you don't need ptl above. Unfortunately,
down_read sleeps, while tasklist_lock is a spinlock, so you'll need to
take some other approach here.

>      for (vma = p->mm->mmap, count = 0; vma; vma = vma->vm_next, count += c) {
>        if ((c = free_process(vma, p)) == -ENOMEM) {
>          printk("VMC: Out of Memory\n");
>          up_read(&p->mm->mmap_sem);
>          goto out;
>        }
>      }
>      up_read(&p->mm->mmap_sem);
>      printk("VMC: Process %d. %d pages freed\n", p->pid, count);
>    }
>  } while_each_thread(g, p);
> 
> out:
>  read_unlock(&tasklist_lock);

I won't have time to help more as I'm heading overseas, good luck!

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
