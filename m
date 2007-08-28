Message-ID: <46D3EADE.3080001@yahoo.com.au>
Date: Tue, 28 Aug 2007 19:29:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org> <46D3C244.7070709@yahoo.com.au> <46D3CE29.3030703@linux.vnet.ibm.com>
In-Reply-To: <46D3CE29.3030703@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Nick Piggin wrote:
> 
>>akpm@linux-foundation.org wrote:
>>
>>>The patch titled
>>>     Memory controller: memory accounting
>>
>>What's the plans to deal with other types of pages other than pagecache?
>>Surely not adding hooks on a case-by-case basis throughout all the kernel?
>>Or do we not actually care about giving real guarantees about memory
>>availability? Presumably you do, otherwise you wouldn't be carefully
>>charging things before you actually insert them and uncharing afterwards
>>on failure, etc.
>>
> 
> 
> We deal with RSS and Page/Swap Cache in this controller.

Sure. And if all you intend is workload management, then that's probably
fine. If you want guarantees, then its useless on its own.


>>If you do, then I would have thought the best way to go would be to start
>>with the simplest approach, and add things like targetted reclaim after
>>that.
>>
> 
> 
> I think the kernel accounting/control system will have to be an independent
> controller (since we cannot reclaim kernel pages, just limit them by
> accounting (except for some slab pages which are free)).

I don't see why accounting would have to be different.

Control obviously will, but for the purposes of using a page, it doesn't
matter to anybody else in the system whether some container has used it
for a pagecache page, or for something else like page tables. The end
result obviously is only that you can either kill the container or
reclaim its reclaimablememory, but before you get to that point, you
need to do the actual  accounting, and AFAIKS it would be identical for
all pages (at least for this basic first-touch charging scheme).


>>I just don't want to see little bits to add more and more hooks slowly go
>>in under the radar ;) So... there is a coherent plan, right?
>>
> 
> 
> Nothing will go under the radar :-) Everything will be posted to linux-mm
> and linux-kernel. We'll make sure you don't wake up one day and see
> the mm code has changed to something you cannot recognize ;)

I don't mean to say it would be done on purpose, but without a coherent
strategy then things might slowly just get added as people think they are
needed. I'm fairly sure several people want to really guarantee memory
resources in an untrusted environment, don't they? And that's obviously
not going to scale by putting calls all throughout the kernel.


>>>+    mem = rcu_dereference(mm->mem_container);
>>>+    /*
>>>+     * For every charge from the container, increment reference
>>>+     * count
>>>+     */
>>>+    css_get(&mem->css);
>>>+    rcu_read_unlock();
>>
>>Where's the corresponding rcu_assign_pointer? Oh, in the next patch. That's
>>unconventional (can you rearrange it so they go in together, please?).
>>
>>
> 
> 
> The movement is associated with task migration, it should be easy to move
> the patch around.

Thanks.


>>>+    if (mem_container_charge(page, mm)) {
>>>+        ret = VM_FAULT_OOM;
>>>+        goto out;
>>>+    }
>>
>>The oom-from-pagefault path is quite crap (not this code, mainline).
>>It doesn't obey any of the given oom killing policy.
>>
>>I had a patch to fix this, but nobody else was too concerned at that
>>stage. I don't expect that path would have been hit very much before,
>>but with a lot of -EFAULTs coming out of containers, I think
>>VM_FAULT_OOMs could easily trigger in practice now.
>>
>>http://lkml.org/lkml/2006/10/12/158
>>
>>Patch may be a little outdated, but the basics should still work. You
>>might be in a good position to test it with these container patches?
>>
> 
> 
> 
> I'll test the patch. Thanks for pointing me in the right direction.

OK, thanks. Let me know how it goes and we could try again to get it
merged.


>>>@@ -582,6 +589,12 @@ void page_add_file_rmap(struct page *pag
>>> {
>>>     if (atomic_inc_and_test(&page->_mapcount))
>>>         __inc_zone_page_state(page, NR_FILE_MAPPED);
>>>+    else
>>>+        /*
>>>+         * We unconditionally charged during prepare, we uncharge here
>>>+         * This takes care of balancing the reference counts
>>>+         */
>>>+        mem_container_uncharge_page(page);
>>> }
>>
>>What's "during prepare"? Better would be "before adding the page to
>>page tables" or something.
>>
> 
> 
> Yeah.. I'll change that comment
> 
> 
>>But... why do you do it? The refcounts and charging are alrady taken
>>care of in your charge function, aren't they? Just unconditionally
>>charge at map time and unconditionally uncharge at unmap time, and
>>let your accounting implementation take care of what to actually do.
>>
>>(This is what I mean about mem container creeping into core code --
>>it's fine to have some tasteful hooks, but introducing these more
>>complex interactions between core VM and container accounting details
>>is nasty).
>>
>>I would much prefer this whole thing to _not_ to hook into rmap like
>>this at all. Do the call unconditionally, and your container
>>implementation can do as much weird and wonderful refcounting as its
>>heart desires.
>>
> 
> 
> The reason why we have the accounting this way is because
> 
> After we charge, some other code path could fail and we need
> to uncharge the page. We do most of the refcounting internally.
> mem_container_charge() could fail if the container is over
> its limit and we cannot reclaim enough pages to allow a new
> charge to be added. In that case we go to OOM.

But at this point you have already charged the container, and have put
it in the page tables, if I read correctly. Nothing is going to fail
at this point and the page could get uncharged when it is unmapped?


>>>@@ -80,6 +81,11 @@ static int __add_to_swap_cache(struct pa
>>>     BUG_ON(PagePrivate(page));
>>>     error = radix_tree_preload(gfp_mask);
>>>     if (!error) {
>>>+
>>>+        error = mem_container_charge(page, current->mm);
>>>+        if (error)
>>>+            goto out;
>>>+
>>>         write_lock_irq(&swapper_space.tree_lock);
>>>         error = radix_tree_insert(&swapper_space.page_tree,
>>>                         entry.val, page);
>>>@@ -89,10 +95,13 @@ static int __add_to_swap_cache(struct pa
>>>             set_page_private(page, entry.val);
>>>             total_swapcache_pages++;
>>>             __inc_zone_page_state(page, NR_FILE_PAGES);
>>>-        }
>>>+        } else
>>>+            mem_container_uncharge_page(page);
>>>+
>>>         write_unlock_irq(&swapper_space.tree_lock);
>>>         radix_tree_preload_end();
>>>     }
>>>+out:
>>>     return error;
>>> }
>>
>>Uh. You have to be really careful here (and in add_to_page_cache, and
>>possibly others I haven't really looked)... you're ignoring gfp masks
>>because mem_container_charge allocates with GFP_KERNEL. You can have
>>all sorts of GFP_ATOMIC, GFP_NOIO, NOFS etc. come in these places that
>>will deadlock.
>>
> 
> 
> I ran into some trouble with move_to_swap_cache() and move_from_swap_cache()
> since they use GFP_ATOMIC. Given the page is already accounted for and
> refcounted, the refcounting helped avoid blocking.

add_to_page_cache gets called with GFP_ATOMIC as well, and it gets called
with GFP_NOFS for new pages.

But I don't think you were suggesting that this isn't a problem, where
you? Relying on implementation in the VM would signal more broken layering.


>>I think I would much prefer you make mem_container_charge run atomically,
>>and then have just a single hook at the site of where everything else is
>>checked, rather than having all this pre-charge post-uncharge messiness.
>>Ditto for mm/memory.c... all call sites really... should make them much
>>nicer looking.
>>
> 
> 
> The problem is that we need to charge, before we add the page to the page
> table and that needs to be a blocking context (since we reclaim when
> the container goes over limit). The uncharge part comes in when we
> handle errors from other paths (like I've mentioned earlier in this
> email).

So I don't understand how you'd deal with GFP_ATOMIC and such restricted
masks, then, if you want to block here.

It would be so so much easier and cleaner for the VM if you did all the
accounting in page alloc and freeing hooks, and just put the page
on per-container LRUs when it goes on the regular LRU.

I'm still going to keep pushing for that approach until either someone
explains why it can't be done or the current patch gets a fair bit
cleaner. Has that already been tried and shown not to work? I would have
thought so seeing as it would be the simplest patch, however I can't
remember hearing about the actual problems with it.

But anyway I don't have any problems with it getting into -mm at this
stage for more exposure and review. Maybe my concerns will get
overridden anyway ;)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
