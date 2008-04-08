Subject: Re: [RFC PATCH 1/2] futex: rely on get_user_pages() for shared
	futexes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200804082140.04356.nickpiggin@yahoo.com.au>
References: <20080404193332.348493000@chello.nl>
	 <20080404193817.574188000@chello.nl>
	 <200804082140.04356.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 08 Apr 2008 18:59:19 +0200
Message-Id: <1207673959.15579.77.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-08 at 21:40 +1000, Nick Piggin wrote:
> On Saturday 05 April 2008 06:33, Peter Zijlstra wrote:
> > On the way of getting rid of the mmap_sem requirement for shared futexes,
> > start by relying on get_user_pages().
> >
> > This requires we get the page associated with the key, and put the page
> > when we're done with it.
> 
> Hi Peter,
> 
> Cool.
> 
> I'm all for removing mmap_sem requirement from shared futexes...
> Are there many apps which make a non-trivial use of them I wonder?

No idea. I've heard some stories, but I've never seen any code..

> I guess it will help legacy (pre-FUTEX_PRIVATE) usespaces in
> performance too, though.

Yeah, that was one of the motivations for this patch.

> What I'm worried about with this is invalidate or truncate races.
> With direct IO, it obviously doesn't matter because the only
> requirement is that the page existed at the address at some point
> during the syscall... 
> 
> So I'd really like you to not carry the page around in the key, but
> just continue using the same key we have now. Also, lock the page
> and ensure it hasn't been truncated before taking the inode from the
> key and incrementing its count (page lock's extra atomics should be
> more or less cancelled out by fewer mmap_sem atomic ops).
> 
> get_futex_key should look something like this I would have thought:?

Does look nicer, will have to ponder it a bit though.

I must admit to not fully understanding why we take inode/mm references
in the key anyway as neither will stop unmapping the futex.

Will make this into a nice patch.. thanks!

> BTW. I like that it removes a lot of fshared crap from around
> the place. And also this is a really good user of fast_gup
> because I guess it should usually be faulted in. The problem is
> that this could be a little more expensive for architectures that
> don't implement fast_gup. Though most should be able to.

Yeah, if that really becomes a problem (but I doubt it will) we could
possibly make the old and new scheme work based on ARCH_HAVE_PTE_SPECIAL
or something ugly like that.

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
> 
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
