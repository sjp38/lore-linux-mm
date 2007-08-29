Message-ID: <46D52030.9080605@yahoo.com.au>
Date: Wed, 29 Aug 2007 17:28:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org> <46D3C244.7070709@yahoo.com.au> <46D3CE29.3030703@linux.vnet.ibm.com> <46D3EADE.3080001@yahoo.com.au> <46D4097A.7070301@linux.vnet.ibm.com>
In-Reply-To: <46D4097A.7070301@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Nick Piggin wrote:

>>Sure. And if all you intend is workload management, then that's probably
>>fine. If you want guarantees, then its useless on its own.
>>
> 
> 
> Yes. Guarantees are hard to do with just this controller (due to non-reclaimable
> pages). It should be easy to add a mlock() controller on top of this one.
> Pavel is planning to work on a kernel memory controller. With that in place,
> guarantees might be possible.

So it doesn't sound like they are necessarily a requirement for linux
kernel memory control -- that's fine, I just want to know where you
stand with that.


>>I don't mean to say it would be done on purpose, but without a coherent
>>strategy then things might slowly just get added as people think they are
>>needed. I'm fairly sure several people want to really guarantee memory
>>resources in an untrusted environment, don't they? And that's obviously
>>not going to scale by putting calls all throughout the kernel.
>>
> 
> 
> We sent out an RFC last year and got several comments from stake holders
> 
> 1. Pavel Emelianov
> 2. Paul Menage
> 3. Vaidyanathan Srinivasan
> 4. YAMAMOTO Takshi
> 5. KAMEZAWA Hiroyuki
> 
> 
> At the OLS resource management BoF, we had a broader participation and
> several comments and suggestions.
> 
> We've incorporated suggestions and comments from all stake holders

:) I know everyone's really worked hard at this and is trying to do the
right thing. But for example some of the non-container VM people may not
know exactly what you are up to or planning (I don't). It can make things
a bit harder to review IF there is an expectation that more functionality
is going to be required (which is what my expectation is).

Anyway, let's not continue this tangent. Instead, I'll try to be more
constructive and ask for eg. your future plans if they are not clear.


>>But at this point you have already charged the container, and have put
>>it in the page tables, if I read correctly. Nothing is going to fail
>>at this point and the page could get uncharged when it is unmapped?
>>
>>
> 
> 
> Here's the sequence of steps
> 
> 1. Charge (we might need to block on reclaim)
> 2. Check to see if there is a race in updating the PTE
> 3. Add to the page table, update _mapcount under a lock
> 
> Several times the error occurs in step 2, due to which we need to uncharge
> the memory container.

Oh yeah, I understand all _those_ uncharging calls you do. But let me
just quote the code again:

diff -puN mm/rmap.c~memory-controller-memory-accounting-v7 mm/rmap.c
--- a/mm/rmap.c~memory-controller-memory-accounting-v7
+++ a/mm/rmap.c
@@ -48,6 +48,7 @@
  #include <linux/rcupdate.h>
  #include <linux/module.h>
  #include <linux/kallsyms.h>
+#include <linux/memcontrol.h>

  #include <asm/tlbflush.h>

@@ -550,8 +551,14 @@ void page_add_anon_rmap(struct page *pag
      VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
      if (atomic_inc_and_test(&page->_mapcount))
          __page_set_anon_rmap(page, vma, address);
-    else
+    else {
          __page_check_anon_rmap(page, vma, address);
+        /*
+         * We unconditionally charged during prepare, we uncharge here
+         * This takes care of balancing the reference counts
+         */
+        mem_container_uncharge_page(page);
+    }
  }

At the point you are uncharging here, the pte has been updated and
the page is in the pagetables of the process. I guess this uncharging
works on the presumption that you are not the first container to map
the page, but I thought that you already check for that in your
accounting implementation.

Now how does it take care of the refcounts? I guess it is because your
rmap removal function also takes care of refcounts by only uncharging
if mapcount has gone to zero... however that's polluting the VM with
knowledge that your accounting scheme is a first-touch one, isn't it?

Aside, I'm slightly suspicious of whether this is correct against
mapcount races, but I didn't look closely yet. I remember you bringing
that up with me, so I guess you've been careful there...


>>add_to_page_cache gets called with GFP_ATOMIC as well, and it gets called
>>with GFP_NOFS for new pages.
>>
>>But I don't think you were suggesting that this isn't a problem, where
>>you? Relying on implementation in the VM would signal more broken layering.
>>
>>
> 
> 
> Good, thanks for spotting this. It should be possible to fix this case.
> I'll work on a fix and send it out.

OK.


>>It would be so so much easier and cleaner for the VM if you did all the
>>accounting in page alloc and freeing hooks, and just put the page
>>on per-container LRUs when it goes on the regular LRU.
>>
> 
> 
> The advantage of the current approach is that not all page allocations have
> to worry about charges. Only user space pages (unmapped cache and mapped RSS)
> are accounted for.

That could be true. OTOH, if you have a significant amount of non userspace
page allocations happening, the chances are that your userspace-only
accounting is going out the window too :)

You'd still be able to avoid charging if a process isn't in a container
or accounting is turned off, of course.


> We tried syncing the container and the global LRU. Pavel is working on
> that approach. The problem with adding the page at the same time as the
> regular LRU is that we end up calling the addition under the zone->lru_lock.
> Holding the entire zone's lru_lock for list addition might be an overhead.
> Although, we do the list isolation under the zone's lru lock.

Well it may not have to be _exactly_ the same time as the page goes on the
normal lru. You could try doing it in pagevec_lru_add, for example, after
the lru locks have been released?


>>I'm still going to keep pushing for that approach until either someone
>>explains why it can't be done or the current patch gets a fair bit
>>cleaner. Has that already been tried and shown not to work? I would have
>>thought so seeing as it would be the simplest patch, however I can't
>>remember hearing about the actual problems with it.
>>
> 
> 
> I am all eyes and ears to patches/suggestions/improvements to the current
> container.

Well I have made a few. I'm actually not too interested in containers and
resource control myself, but I suspect it may be a fair bit easier to play
around with eg. my ideas for VM hooks with an implementation in -mm, so I
might get motivated to try a patch...

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
