Received: from edge04.upc.biz ([192.168.13.239]) by viefep18-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080409135131.UXXC18951.viefep18-int.chello.at@edge04.upc.biz>
          for <linux-mm@kvack.org>; Wed, 9 Apr 2008 15:51:31 +0200
Subject: Re: [RFC PATCH 1/2] futex: rely on get_user_pages() for shared
	futexes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200804082140.04356.nickpiggin@yahoo.com.au>
References: <20080404193332.348493000@chello.nl>
	 <20080404193817.574188000@chello.nl>
	 <200804082140.04356.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 09 Apr 2008 15:51:18 +0200
Message-Id: <1207749078.24562.4.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-08 at 21:40 +1000, Nick Piggin wrote:

> @@ -191,7 +191,6 @@ static int get_futex_key(u32 __user *uad
>  {
>         unsigned long address = (unsigned long)uaddr;
>         struct mm_struct *mm = current->mm;
> -       struct vm_area_struct *vma;
>         struct page *page;
>         int err;
> 
> @@ -210,27 +209,26 @@ static int get_futex_key(u32 __user *uad
>          * Note : We do have to check 'uaddr' is a valid user address,
>          *        but access_ok() should be faster than find_vma()
>          */
> -       if (!fshared) {
> +       if (likely(!fshared)) {
>                 if (unlikely(!access_ok(VERIFY_WRITE, uaddr, sizeof(u32))))
>                         return -EFAULT;
>                 key->private.mm = mm;
>                 key->private.address = address;
>                 return 0;
>         }
> -       /*
> -        * The futex is hashed differently depending on whether
> -        * it's in a shared or private mapping.  So check vma first.
> -        */
> -       vma = find_extend_vma(mm, address);
> -       if (unlikely(!vma))
> -               return -EFAULT;
> -
> -       /*
> -        * Permissions.
> -        */
> -       if (unlikely((vma->vm_flags & (VM_IO|VM_READ)) != VM_READ))
> -               return (vma->vm_flags & VM_IO) ? -EPERM : -EACCES;
> 
> +again:
> +       err = fast_gup(address, 1, 0, &page);
> +       if (err < 0)
> +               return err;
> +
> +       lock_page(page);
> +       if (!page->mapping) { /* PageAnon pages shouldn't get caught here */
> +               unlock_page(page);
> +               put_page(page);
> +               goto again;
> +       }
> +
>         /*
>          * Private mappings are handled in a simple way.
>          *
> @@ -240,38 +238,19 @@ static int get_futex_key(u32 __user *uad
>          * VM_MAYSHARE here, not VM_SHARED which is restricted to shared
>          * mappings of _writable_ handles.
>          */
> -       if (likely(!(vma->vm_flags & VM_MAYSHARE))) {
> -               key->both.offset |= FUT_OFF_MMSHARED; /* reference taken on mm 
> *
> /
> +       if (PageAnon(page)) {
> +               key->both.offset |= FUT_OFF_MMSHARED; /* ref taken on mm */
>                 key->private.mm = mm;
>                 key->private.address = address;
> -               return 0;
> -       }
> -
> -       /*
> -        * Linear file mappings are also simple.
> -        */
> -       key->shared.inode = vma->vm_file->f_path.dentry->d_inode;
> -       key->both.offset |= FUT_OFF_INODE; /* inode-based key. */
> -       if (likely(!(vma->vm_flags & VM_NONLINEAR))) {
> -               key->shared.pgoff = (((address - vma->vm_start) >> PAGE_SHIFT)
> -                                    + vma->vm_pgoff);
> -               return 0;
> -       }
> -
> -       /*
> -        * We could walk the page table to read the non-linear
> -        * pte, and get the page index without fetching the page
> -        * from swap.  But that's a lot of code to duplicate here
> -        * for a rare case, so we simply fetch the page.
> -        */
> -       err = get_user_pages(current, mm, address, 1, 0, 0, &page, NULL);
> -       if (err >= 0) {
> -               key->shared.pgoff =
> -                       page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> -               put_page(page);
> -               return 0;
> +       } else {
> +               key->both.offset |= FUT_OFF_INODE; /* inode-based key. */
> +               key->shared.inode = page->mapping->inode;
> +               key->shared.pgoff = page->index;
>         }
> -       return err;
> +out:
> +       unlock_page(page);
> +       put_page(page);
> +       return 0;
>  }

Right, so staring at this for a while makes me feel uneasy. The thing
is, once we exit get_futex_key() there is nothing stopping the mm of
inode from going away.

So I'm going to have to take a ref while we have the page locked, and do
the put_futex_key() thing to release it.

Code at (uncompiled and untested):
http://programming.kicks-ass.net/kernel-patches/futex-fast_gup/v2.6.24.4-rt4-2/

The thing is, it now needs to take a reference on a rather large object
(mm/inode), giving a rather large opportunity to bounce that cacheline.

What problems do you see with just keeping a ref on the page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
