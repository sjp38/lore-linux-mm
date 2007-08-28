Message-ID: <46D3C244.7070709@yahoo.com.au>
Date: Tue, 28 Aug 2007 16:35:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org>
In-Reply-To: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

akpm@linux-foundation.org wrote:
> The patch titled
>      Memory controller: memory accounting

What's the plans to deal with other types of pages other than pagecache?
Surely not adding hooks on a case-by-case basis throughout all the kernel?
Or do we not actually care about giving real guarantees about memory
availability? Presumably you do, otherwise you wouldn't be carefully
charging things before you actually insert them and uncharing afterwards
on failure, etc.

If you do, then I would have thought the best way to go would be to start
with the simplest approach, and add things like targetted reclaim after
that.

I just don't want to see little bits to add more and more hooks slowly go
in under the radar ;) So... there is a coherent plan, right?


> +/*
> + * Charge the memory controller for page usage.
> + * Return
> + * 0 if the charge was successful
> + * < 0 if the container is over its limit
> + */
> +int mem_container_charge(struct page *page, struct mm_struct *mm)
> +{
> +	struct mem_container *mem;
> +	struct page_container *pc, *race_pc;
> +
> +	/*
> +	 * Should page_container's go to their own slab?
> +	 * One could optimize the performance of the charging routine
> +	 * by saving a bit in the page_flags and using it as a lock
> +	 * to see if the container page already has a page_container associated
> +	 * with it
> +	 */
> +	lock_page_container(page);
> +	pc = page_get_page_container(page);
> +	/*
> +	 * The page_container exists and the page has already been accounted
> +	 */
> +	if (pc) {
> +		atomic_inc(&pc->ref_cnt);
> +		goto done;
> +	}
> +
> +	unlock_page_container(page);
> +
> +	pc = kzalloc(sizeof(struct page_container), GFP_KERNEL);
> +	if (pc == NULL)
> +		goto err;
> +
> +	rcu_read_lock();
> +	/*
> +	 * We always charge the container the mm_struct belongs to
> +	 * the mm_struct's mem_container changes on task migration if the
> +	 * thread group leader migrates. It's possible that mm is not
> +	 * set, if so charge the init_mm (happens for pagecache usage).
> +	 */
> +	if (!mm)
> +		mm = &init_mm;
> +
> +	mem = rcu_dereference(mm->mem_container);
> +	/*
> +	 * For every charge from the container, increment reference
> +	 * count
> +	 */
> +	css_get(&mem->css);
> +	rcu_read_unlock();

Where's the corresponding rcu_assign_pointer? Oh, in the next patch. That's
unconventional (can you rearrange it so they go in together, please?).


> @@ -1629,6 +1637,9 @@ gotten:
>  		goto oom;
>  	cow_user_page(new_page, old_page, address, vma);
>  
> +	if (mem_container_charge(new_page, mm))
> +		goto oom_free_new;
> +
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> @@ -1660,7 +1671,9 @@ gotten:
>  		/* Free the old page.. */
>  		new_page = old_page;
>  		ret |= VM_FAULT_WRITE;
> -	}
> +	} else
> +		mem_container_uncharge_page(new_page);
> +
>  	if (new_page)
>  		page_cache_release(new_page);
>  	if (old_page)
> @@ -1681,6 +1694,8 @@ unlock:
>  		put_page(dirty_page);
>  	}
>  	return ret;
> +oom_free_new:
> +	__free_page(new_page);
>  oom:
>  	if (old_page)
>  		page_cache_release(old_page);
> @@ -2085,6 +2100,11 @@ static int do_swap_page(struct mm_struct
>  	}
>  
>  	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> +	if (mem_container_charge(page, mm)) {
> +		ret = VM_FAULT_OOM;
> +		goto out;
> +	}

The oom-from-pagefault path is quite crap (not this code, mainline).
It doesn't obey any of the given oom killing policy.

I had a patch to fix this, but nobody else was too concerned at that
stage. I don't expect that path would have been hit very much before,
but with a lot of -EFAULTs coming out of containers, I think
VM_FAULT_OOMs could easily trigger in practice now.

http://lkml.org/lkml/2006/10/12/158

Patch may be a little outdated, but the basics should still work. You
might be in a good position to test it with these container patches?


> diff -puN mm/rmap.c~memory-controller-memory-accounting-v7 mm/rmap.c
> --- a/mm/rmap.c~memory-controller-memory-accounting-v7
> +++ a/mm/rmap.c
> @@ -48,6 +48,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/module.h>
>  #include <linux/kallsyms.h>
> +#include <linux/memcontrol.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -550,8 +551,14 @@ void page_add_anon_rmap(struct page *pag
>  	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
>  	if (atomic_inc_and_test(&page->_mapcount))
>  		__page_set_anon_rmap(page, vma, address);
> -	else
> +	else {
>  		__page_check_anon_rmap(page, vma, address);
> +		/*
> +		 * We unconditionally charged during prepare, we uncharge here
> +		 * This takes care of balancing the reference counts
> +		 */
> +		mem_container_uncharge_page(page);
> +	}
>  }
>  
>  /*
> @@ -582,6 +589,12 @@ void page_add_file_rmap(struct page *pag
>  {
>  	if (atomic_inc_and_test(&page->_mapcount))
>  		__inc_zone_page_state(page, NR_FILE_MAPPED);
> +	else
> +		/*
> +		 * We unconditionally charged during prepare, we uncharge here
> +		 * This takes care of balancing the reference counts
> +		 */
> +		mem_container_uncharge_page(page);
>  }

What's "during prepare"? Better would be "before adding the page to
page tables" or something.

But... why do you do it? The refcounts and charging are alrady taken
care of in your charge function, aren't they? Just unconditionally
charge at map time and unconditionally uncharge at unmap time, and
let your accounting implementation take care of what to actually do.

(This is what I mean about mem container creeping into core code --
it's fine to have some tasteful hooks, but introducing these more
complex interactions between core VM and container accounting details
is nasty).

I would much prefer this whole thing to _not_ to hook into rmap like
this at all. Do the call unconditionally, and your container
implementation can do as much weird and wonderful refcounting as its
heart desires.


>  #ifdef CONFIG_DEBUG_VM
> @@ -642,6 +655,8 @@ void page_remove_rmap(struct page *page,
>  			page_clear_dirty(page);
>  			set_page_dirty(page);
>  		}
> +		mem_container_uncharge_page(page);
> +
>  		__dec_zone_page_state(page,
>  				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
>  	}
> diff -puN mm/swap_state.c~memory-controller-memory-accounting-v7 mm/swap_state.c
> --- a/mm/swap_state.c~memory-controller-memory-accounting-v7
> +++ a/mm/swap_state.c
> @@ -17,6 +17,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/pagevec.h>
>  #include <linux/migrate.h>
> +#include <linux/memcontrol.h>
>  
>  #include <asm/pgtable.h>
>  
> @@ -80,6 +81,11 @@ static int __add_to_swap_cache(struct pa
>  	BUG_ON(PagePrivate(page));
>  	error = radix_tree_preload(gfp_mask);
>  	if (!error) {
> +
> +		error = mem_container_charge(page, current->mm);
> +		if (error)
> +			goto out;
> +
>  		write_lock_irq(&swapper_space.tree_lock);
>  		error = radix_tree_insert(&swapper_space.page_tree,
>  						entry.val, page);
> @@ -89,10 +95,13 @@ static int __add_to_swap_cache(struct pa
>  			set_page_private(page, entry.val);
>  			total_swapcache_pages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
> -		}
> +		} else
> +			mem_container_uncharge_page(page);
> +
>  		write_unlock_irq(&swapper_space.tree_lock);
>  		radix_tree_preload_end();
>  	}
> +out:
>  	return error;
>  }

Uh. You have to be really careful here (and in add_to_page_cache, and
possibly others I haven't really looked)... you're ignoring gfp masks
because mem_container_charge allocates with GFP_KERNEL. You can have
all sorts of GFP_ATOMIC, GFP_NOIO, NOFS etc. come in these places that
will deadlock.

I think I would much prefer you make mem_container_charge run atomically,
and then have just a single hook at the site of where everything else is
checked, rather than having all this pre-charge post-uncharge messiness.
Ditto for mm/memory.c... all call sites really... should make them much
nicer looking.

...

I didn't look at all code in all patches. But overall I guess it isn't
looking too bad (though I'd really like people like Andrea and Hugh to
take a look as well, eventually). It is still a lot uglier in terms of
core mm hooks than I would like, but with luck that could be improved
(some of my suggestions might even help a bit).

Haven't looked at the targetted reclaim patches yet (sigh, more
container tentacles :P).

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
