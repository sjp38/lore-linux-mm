Date: Wed, 23 Jan 2008 18:33:25 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123173325.GG7141@v2.random>
References: <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <20080123114136.GE15848@v2.random> <20080123123230.GH26420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080123123230.GH26420@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 06:32:30AM -0600, Robin Holt wrote:
> Christoph, Maybe you can clear one thing up.  Was this proposal an
> addition to or replacement of Andrea's?  I assumed an addition.  I am
> going to try to restrict my responses to ones appropriate for that
> assumption.

It wasn't immediately obvious that this was an addition but really I
don't mind either ways as long as a feature workable for KVM is
included ;).

> > The remote instance is like a secondary TLB what you're doing in your
> > code is as backwards as flushing the TLB _before_ clearing the PTE! If
> > you want to call the secondary tlb flush outside locks we can argue
> > about that, but I think you should do that _after_ clearing the linux
> > pte IMHO. Otherwise you can as well move the tlb_flush_page before
> > clearing the pte and you'll run in the same amount of smp races for
> > the master MMU too.
> 
> I can agree to doing the flush after as long as I get a flag from the
> mmu notifier saying this flush will be repeated later without locks
> held.  That would be fine with me.  If we don't have that then the

You want to be able to tell the mmu_notifier that you want the flush
repeated without locks later? Sorry but then if you're always going to
set the bitflag unconditionally, why don't you simply implement a
second notifier in addition of my current ->invalidate_page (like
->after_invalidate_page).

We can then implement a method in rmap.c for you to call to do the
final freeing of the page (pagecache/swapcache won't be collected
unless it's a truncate, as long as you keep it pinned and you
certainly don't want to wait a second round of lru scan before freeing
the page after you release the external reference, so you may need to
call this method before returning from the
->after_invalidate_page). Infact I can call that method for you in the
notifier implementation itself after all ->after_invalidate_pages have
been called. (of course only if at least one of them was implemented
and not-null)

> export_notifiers would need to be expanded to cover all cases of pte
> clearing.  Baring one of the two, I would argue we have an unworkable
> solution for XPMEM.  This is because of allocations which is touched
> upon later.

mmu notifiers should already cover all pte clearing cases (export
notifiers definitely don't instead!). It's not as important as for
quadrics, we're mostly interested in rmap.c swapping and do_wp_page
for KVM page sharing. But in the longer term protection changes and
other things happening in the main MMU can also be tracked through mmu
notifiers (something quadrics will likely need). Tracking the
asm-generic/pgtable.h is all about trivially tracking all places
without cluttering mm/*.c, so the mm/*.c remains more hackable and
more readable.

> As an example of thousands, we currently have one customer job that
> has 16880 processors all with the same physical page faulted into their
> address space.  The way XPMEM is currently structured, there is fan-out of
> that PFN information so we would not need to queue up that many messages,
> but it would still be considerable.  Our upcoming version of the hardware
> will potentially make this fanout worse because we are going to allow
> even more fine-grained divisions of the machine to help with memory
> error containment.

Well as long as you send these messages somewhat serially and you
don't pretend to allocate all packets at once it should be ok. Perhaps
you should preallocate all packets statically and serialize the access
to the pool with a lock.

What I'd like to stress to be sure it's crystal clear, is that in the
mm/rmap.c path GFP_KERNEL==GFP_ATOMIC, infact both are = PF_MEMALLOC =
TIF_MEMDIE = if mempool is empty it will crash. The argument that you
need to sleep to allocate memory with GFP_KERNEL is totally bogus. If
that's the only reason, you don't need to sleep at all. alloc_pages
will not invoke the VM when called inside the VM, it will grab ram
from PF_MEMALLOC instead. At most it will schedule so the only benefit
would be lower -rt latency in the end.

> We have a counter associated with a pfn that indicates when the pfn is no
> longer referenced by other partitions.  This counter triggers changing of
> memory protections so any subsequent access to this page will result in
> a memory error on the remote partition (this should be an illegal case).

As long as you keep a reference on the page too, you don't risk
any corruption by flushing after.

> > And how do they know when they can restart adding references if infact
> > the VM _never_ calls into SetPageExported? (perhaps you forgot
> > something in your patch to set PageExported again to notify the
> > external reference that it can "de-freeze" and to restart adding
> > references ;)
> 
> I assumed Christoph intended this to be part of our memory protection
> changing phase.  Once we have raised memory protections for the page,
> clear the bit.  When we lower memory protections, set the bit.

The window that you must close with that bitflag is the request coming
from the remote node to map the page after the linux pte has been
cleared. If you map the page in a remote node after the linux pte has
been cleared ->invalidate_page won't be called again because the page
will look unmapped in the linux VM. Now invalidate_page will clear the
bitflag, so the map requests will block. But where exactly you know
that the linux pte has been cleared so you can "unblock" the map
requests? If a page is not mapped by some linux pte, mm/rmap.c will
never be called and this is why any notification in mm/rmap.c should
track the "address space" and not the "physical page".

In effect you don't care less about the address space of the task in
the master node, so IMHO you're hooking your ->invalidate_page(page)
(instead of my ->invalidate_page(mm, address)) in the very wrong
place. You should hook it in mm/vmscan.c shrink-list so it will be
invoked regardless if the pte is mapped or not. Then your model that
passes the "page" instead of an "mm+address" will start to work
without any need clearing/setting PG_exported bifflags, and you will
automatically close the above race window without the need of ever
clearing the PG_exported bitflag etc.... So again the current design
of Christoph's patch really looks flawed to me.

If you work the "pages" you should stick to pages and to stay away
from mm/rmap.c and ignore whatever is mapped in the master address
space of the task. mm/rmap.c only deals with ptes/sptes and other
_virtual-tracked_ mappings.

If you work with get_user_pages for page allocation (instead of
alloc_pages) and the userland "virtual" addresses are your RAM backing
store, like with KVM, then you should build an rmap structure based on
_virtual_ addresses because the virtual addresses of the task will be
all you care about, and then you will register the notifier in the
"mm" and you will need ->invalidate_page to take an "address" as
parameter and not a "page". All reference counting will be automatic,
the userland task will run with all virtual memory visible
automatically. You should make sure this model tied to the ram mapped
in the userland task can't fit your needs and you really have to care
about building stuff on top of physical pages instead of letting the
VM decide which physical page or swap entry is going back your memory needs.

> As I said before, I was under the assumption that Christoph was proposing
> this as an addition to your notifiers, not a replacement.

Ok. This wasn't my impression but again I'm fine either ways! ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
