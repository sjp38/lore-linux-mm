Date: Tue, 4 Nov 2008 16:04:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: race between o_direct and fork (harder to fix with
	get_user_page_fast)
Message-ID: <20081104150449.GA31975@random.random>
References: <20080925183846.GA6877@duo.random> <20081029004308.GH15599@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081029004308.GH15599@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

Thanks for looking into this, as far as I can tell gup_fast is the
major problem here as you'll see below.

On Wed, Oct 29, 2008 at 01:43:09AM +0100, Nick Piggin wrote:
> I do really like the idea of locking pages before they go under direct
> IO... it also closes a class of real invalidate_mapping_pages bugs where

>From a practical standpoint I always liked it too. It is less clean,
but it allows totally simple serialization of the VM side against the
direct-DMA without having to rely on out of order checks of count vs
mapcount along with stuff that can change under you without any way to
block against it.

The only limitation it has is that it prevents direct reads from the
same page (while writing to disk) and it also limits write parallelism
with sub-page buffer sizes (while reading from disk). Given that for
its must-have usages O_DIRECT is generally cached (either by tmpfs/IPC
or by VM guest OS cache) or it's a guaranteed cache-polluting workload
where it's never going to hit on the same page, it's hard to see how
it would ever be practical problem.

But still current way is a more 'powerful' design (even if probably
not worth it from practical standpoint), so if there's a way to fix
it, I also like to keeping this way as a theoretical exercise.

> the page is going to be dirtied by the direct-IO, but it is still allowed
> to be invalidated from pagecache... As a solution to this problem... I'm not
> sure if it would be entirely trivial still. We could wait on get_user_pages

Invalidate would wait on PG_lock so it'd be entirely trivial. In the
current out of order model w/o PG_lock the usual way to deal with
those events would be to let the invalidate go ahead, and have
O_DIRECT keep working on a page out of pagecache. It shouldn't care,
does it? If it does then it can be taught not to care ;). So the
invalidate vs o-direct I/O doesn't worry me that much. We had those
kind of issues in the past too with certain fs metadata before we had
o-direct (I/O completing on truncated buffer or stuff like that).

> in fork, but would we actually want to, rather than just COW them?

I think waiting in fork would also be ok if it would be simpler, it's
just that we can't wait as there's nothing to wait upon. Whatever is
simpler should be preferred here, if cow is simpler that's fine
too. Either ways it won't make a difference, this is just about not
corrupting data once in a while, it won't ever be measurable in
performance terms.

> @@ -546,11 +547,19 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page, vma, addr);
> +		if (unlikely(page_count(page) != page_mapcount(page))) { /* XXX: also have to check swapcount?! */
> +			if (is_cow_mapping(vm_flags) && PageAnon(page)) {
> +				printk("forcecow!\n");
> +				ret = 1;
> +			}
> +		}

Here we're under PT lock so the follow_page in get_user_pages should
block. Furthermore we're under mmap_sem write on fork side and
get_user_pages will block on mmap_sem read/write.

If follow_page has already completed and o-direct is in flight we'd
see reliably the page count boosted (here ignoring gup_fast for
simplicity), the get_page run by follow_page is run inside the PT
lock.

> -		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
> +		forcecow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
>  		progress += 8;
>  	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
>  
> @@ -597,6 +611,10 @@ again:
>  	add_mm_rss(dst_mm, rss[0], rss[1]);
>  	pte_unmap_unlock(dst_pte - 1, dst_ptl);
>  	cond_resched();
> +	if (forcecow) {
> +		if (handle_mm_fault(dst_mm, vma, addr - PAGE_SIZE, 1) & VM_FAULT_ERROR) /* XXX: should really just do a page copy? */
> +			return -ENOMEM;
> +	}

This isn't enough, we at least need to add something like:

     if (is_cow_mapping(vm_flags)) {
        if (forcecow)
	   ptep_set_wrprotect(src_mm, addr, src_pte);
	pte = pte_wrprotect(pte);
     }

Otherwise the parent context would still break. Setting the child pte
readonly and forcing a cow should still be ok with the child, even if
the parent pte remained read-write the whole time (it has to or
o-direct reads will be lost). Even if the content of the parent page
is changing things should be ok (content is definitely changing). If
anybody forks out of order with memory data contents in the parent, it
means the data that was changing in the parent during fork, can't have
a deterministic value in the child.

With the additional avoidance of ptep_set_wrprotect in the forcecow
case, I think things should be fixed for the parent if follow_page
runs before fork.

If follow_page instead runs after fork (after fork releases mmap_sem,
still ignoring gup_fast for simplicity), things are fine already as
get_user_pages will cow before starting any I/O.

The fundamental problem is in converting any pte from read-write to
readonly while O_DIRECT is in flight, so the fundamental part of the
fix is the removal of that ptep_set_wrprotect, the forcecow in the
child is just a consequence of the parent having to stay read-write
the whole tim.

So your path + my removal of ptep_set_wrprotect should just fix
fork. If it wasn't for gup_fast this is the exact same way that we
would have implemented in KSM too: 1) take PT lock, 2) compare count
vs mapcount 3) mark the pte wrprotected 4) bailout if they aren't the
same, 5) release PT lock.

So now that we agree that the mapcount vs count check under PT lock is
enough for get_user_pages, you've to decide how to make gup_fast
block. It has to block or we can't possibly convert any writeable pte
to readonly ;). Or at least I don't see how you're going to use the
pte_write info to avoid gup_fast block...

> @@ -1216,6 +1234,7 @@ int __get_user_pages(struct task_struct 
>  
>  		do {
>  			struct page *page;
> +			int cow = 0;
>  
>  			/*
>  			 * If tsk is ooming, cut off its access to large memory
> @@ -1229,8 +1248,24 @@ int __get_user_pages(struct task_struct 
>  				foll_flags |= FOLL_WRITE;
>  
>  			cond_resched();
> -			while (!(page = follow_page(vma, start, foll_flags))) {
> +
> +			printk("get_user_pages address=%p\n", (void *)start);
> +			for (;;) {
>  				int ret;
> +
> +				page = follow_page(vma, start, foll_flags);
> +				if (page) {
> +					printk("found page is_cow_mapping=%d PageAnon=%d write=%d cow=%d\n", is_cow_mapping(vma->vm_flags), PageAnon(page), write, cow);
> +
> +					if (is_cow_mapping(vma->vm_flags) &&
> +						PageAnon(page) && !write && !cow) {
> +						foll_flags |= FOLL_WRITE;
> +						printk("gup break cow\n");
> +						cow = 1;
> +					} else
> +						break;
> +				}
> +
>  				ret = handle_mm_fault(mm, vma, start,
>  						foll_flags & FOLL_WRITE);
>  				if (ret & VM_FAULT_ERROR) {
> @@ -1252,8 +1287,10 @@ int __get_user_pages(struct task_struct 
>  				 * pte_write. We can thus safely do subsequent
>  				 * page lookups as if they were reads.
>  				 */
> -				if (ret & VM_FAULT_WRITE)
> +				if (ret & VM_FAULT_WRITE) {
>  					foll_flags &= ~FOLL_WRITE;
> +					cow = 1;
> +				}
>  

The only purpose of this one seems to be to break cows for memory
reads (disk writes). It's not needed and it can be dropped I think. We
don't care about disk writes ever. We only care about disk reads. The
trick is that if anything tries to modify a buffer that is in-flight,
the result isn't deterministic, so for disk writes we can always
assume that the I/O completed before the cpu triggered the cow.

Thanks a lot for the help!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
