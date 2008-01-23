Date: Wed, 23 Jan 2008 12:27:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
In-Reply-To: <20080123173325.GG7141@v2.random>
Message-ID: <Pine.LNX.4.64.0801231220590.13547@schroedinger.engr.sgi.com>
References: <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random>
 <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random>
 <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
 <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
 <20080123114136.GE15848@v2.random> <20080123123230.GH26420@sgi.com>
 <20080123173325.GG7141@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Andrea Arcangeli wrote:

> You want to be able to tell the mmu_notifier that you want the flush
> repeated without locks later? Sorry but then if you're always going to
> set the bitflag unconditionally, why don't you simply implement a
> second notifier in addition of my current ->invalidate_page (like
> ->after_invalidate_page).

Because there is no mm_struct available at that point. So we cannot do a 
callback based on the mmu_ops in that fasion. We would have to build a 
list of notifiers while scanning the reverse maps.

> We can then implement a method in rmap.c for you to call to do the
> final freeing of the page (pagecache/swapcache won't be collected
> unless it's a truncate, as long as you keep it pinned and you
> certainly don't want to wait a second round of lru scan before freeing
> the page after you release the external reference, so you may need to
> call this method before returning from the

The page count is elevated because of the remote pte so the page is 
effectively pinned.

> ->after_invalidate_page). Infact I can call that method for you in the
> notifier implementation itself after all ->after_invalidate_pages have
> been called. (of course only if at least one of them was implemented
> and not-null)

Ok.

> > As an example of thousands, we currently have one customer job that
> > has 16880 processors all with the same physical page faulted into their
> > address space.  The way XPMEM is currently structured, there is fan-out of
> > that PFN information so we would not need to queue up that many messages,
> > but it would still be considerable.  Our upcoming version of the hardware
> > will potentially make this fanout worse because we are going to allow
> > even more fine-grained divisions of the machine to help with memory
> > error containment.
> 
> Well as long as you send these messages somewhat serially and you
> don't pretend to allocate all packets at once it should be ok. Perhaps
> you should preallocate all packets statically and serialize the access
> to the pool with a lock.
> 
> What I'd like to stress to be sure it's crystal clear, is that in the
> mm/rmap.c path GFP_KERNEL==GFP_ATOMIC, infact both are = PF_MEMALLOC =
> TIF_MEMDIE = if mempool is empty it will crash. The argument that you
> need to sleep to allocate memory with GFP_KERNEL is totally bogus. If
> that's the only reason, you don't need to sleep at all. alloc_pages
> will not invoke the VM when called inside the VM, it will grab ram
> from PF_MEMALLOC instead. At most it will schedule so the only benefit
> would be lower -rt latency in the end.

If you are holding a lock then you have to use GFP_ATOMIC and the number 
of GFP_ATOMIC allocs is limited. PF_MEMALLOC does not do reclaim so we are 
in trouble if too many allocs occur.


> > We have a counter associated with a pfn that indicates when the pfn is no
> > longer referenced by other partitions.  This counter triggers changing of
> > memory protections so any subsequent access to this page will result in
> > a memory error on the remote partition (this should be an illegal case).
> 
> As long as you keep a reference on the page too, you don't risk
> any corruption by flushing after.

There are still dirty bit issues.

> The window that you must close with that bitflag is the request coming
> from the remote node to map the page after the linux pte has been
> cleared. If you map the page in a remote node after the linux pte has
> been cleared ->invalidate_page won't be called again because the page
> will look unmapped in the linux VM. Now invalidate_page will clear the
> bitflag, so the map requests will block. But where exactly you know
> that the linux pte has been cleared so you can "unblock" the map
> requests? If a page is not mapped by some linux pte, mm/rmap.c will
> never be called and this is why any notification in mm/rmap.c should
> track the "address space" and not the "physical page".

The subsystem needs to establish proper locking for that case.

> In effect you don't care less about the address space of the task in
> the master node, so IMHO you're hooking your ->invalidate_page(page)
> (instead of my ->invalidate_page(mm, address)) in the very wrong
> place. You should hook it in mm/vmscan.c shrink-list so it will be
> invoked regardless if the pte is mapped or not. Then your model that

Then page migration and other uses of try_to_unmap wont get there. Also 
the page lock is an item that helps with serialization of new faults.

> If you work the "pages" you should stick to pages and to stay away
> from mm/rmap.c and ignore whatever is mapped in the master address
> space of the task. mm/rmap.c only deals with ptes/sptes and other
> _virtual-tracked_ mappings.

It also deals f.e. with page dirty status.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
