Date: Thu, 24 Jan 2008 15:34:54 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080124143454.GN7141@v2.random>
References: <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <20080123114136.GE15848@v2.random> <Pine.LNX.4.64.0801231149150.13547@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801231149150.13547@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 12:18:45PM -0800, Christoph Lameter wrote:
> On Wed, 23 Jan 2008, Andrea Arcangeli wrote:
> 
> > > [..] The linux instance with the 
> > > secondary mmu must call back to the exporting machine in order to 
> > > reinstantiate the page. PageExported is cleared in invalidate_page() so 
> > > the other linux instance will be told that the page is not available.
> > 
> > Page is not available is not a valid answer. At least with KVM there
> > are three possible ways:
> > 
> > 1) the remote instance will have to wait for the linux pte to go away
> >    before calling follow_page (then the page is gone as a whole so
> >    there won't be any more page flags to check)
> > 2) it will kill the VM
> > 
> > Nothing runs SetPageExported in your VM code, I can't see how the
> > remote instance can know when it can call follow_page again safely on
> > the master node.
> 
> SetPageExported is set when a remote instance of linux establishes a 
> reference to the page (a kind of remote page fault). In the KVM scenario 
> that would occur when memory is made available.

The remote page fault is exactly the thing that has to wait on the
PageExported bit to return on! So how can it be the thing that sets
SetPageExported?

The idea is:

    NODE0			NODE1
    ->invalidate_page()
    ClearPageExported
    GFP_KERNEL (== GFP_ATOMIC in mm/rmap.c, won't ever do any I/O)

				->invalidate_page() arrives and drop
                                  references

    __free_page -> unpin so it can be freed
    go ahead after invalidate_page

    zero locking so previous invalidate_page could schedule (not wait for I/O,
    there' won't be any I/O out of GFP_KERNEL inside PF_MEMALLOC i.e. mm/rmap.c!!!)

				remote page fault
				tries to instantiate more references
    remote page fault arrives
    instantiate more references
    get_page() -> pin
    SetPageExported
				remote page fault succeeded

    zero locking so invalidate_page can schedule (not wait for I/O,
    there' won't be any I/O out of GFP_KERNEL!)

    ptep_clear_flush

After the above your remote references will keep the page pinned in
RAM and it'll be unswappable, mm/rmap.c will never be called on that
page again! That's the guest-memory pinning memory leak in KVM terms.

I immediately told you about the above SMP race when I've seen your
backwards idea of invalidating the page _before_ clearing the linux
pte.

I thought your solution was to have the remote page fault wait on
PG_exported to return ON!! But now you tell me the remote page fault
is the thing that has to SetPageExported, not the linux VM. So make up
your mind about this PG_exported mess...

> > The remote instance is like a secondary TLB what you're doing in your
> > code is as backwards as flushing the TLB _before_ clearing the PTE! If
> > you want to call the secondary tlb flush outside locks we can argue
> > about that, but I think you should do that _after_ clearing the linux
> > pte IMHO. Otherwise you can as well move the tlb_flush_page before
> > clearing the pte and you'll run in the same amount of smp races for
> > the master MMU too.
> > 
> > > Ahhh. Good to hear. But we will still end in a situation where only
> > > the remote ptes point to the page. Maybe the remote instance will dirty
> > > the page at that point?
> > 
> > If you flush the remote instance _after_ clearing the main linux PTE
> > like I suggest and like I'm doing in my patch, I can't see how you
> > could risk to end up in a situation with only the remote ptes pointing
> > the page, that's the whole point of doing the remote-TLB flush _after_
> > clearing the main linux pte, instead of before like in your patch.
> 
> You are saying that clearing the main linux ptes and leaving the remote 
> ptes in place will not allow access to the page via the remote ptes?

No, I'm saying if you clear the main linux pte while there are still
remote ptes in place (in turn the page_count has been boosted by 1
with your current code), and you relay on mm/rmap.c for the
->invalidate_page, you will generate a unswappable-pin-leak.

The linux pte must be present and the page must be mapped in userland
as long as there are remote references to the page and in turn as long
as the page_count has been boosted by 1. Otherwise mm/rmap.c won't be
called.

At the very least you should move your invalidate_page in
mm/vmscan.c and have it called regardless if the page is mapped in
userland or not.

> > This is the same as the tlb flush, there's a reason we normally do:
> > 
> >      pte_clear()
> >      flush_tlb_page()
> >      __free_page()
> >      
> > instead of:
> > 
> >      flush_tlb_page()
> >      pte_clear()
> >      __free_page()
> > 
> > The ordering you're implementing is backwards and unnatural, you can
> > try to serialize it with explicit locking to block the "remote-tlb
> > refills" through page bitflags (something not doable with the core
> > master tlb because the refills are done by the hardware with the
> > master tlb), but it'll remain unnatural and backwards IMHO.
> 
> I do not understand where you actually clear the remote pte or spte. You 
> must do it sometime before the notification to make it work.

Definitely not. spte is just like a second tlb. You never flush the
tlb before clearing the main linux pte! Do like I suggested:

    flush_tlb_page()
    pte_clear()
    __free_page

and you'll see crashes very very soon.

With KVM the backwards order perhaps it wouldn't crash because when
the spte maps the page the page is pinned, but still there would be an
unswappable-pinned-memory-leak.

> > > > > - anon_vma/inode and pte locks are held during callbacks.
> > > > 
> > > > In a previous email I asked what's wrong in offloading the event, and
> > > 
> > > We have internally discussed the possibility of offloading the event but 
> > > that wont work with the existing callback since we would have to 
> > > perform atomic allocation and there may be thousands of external 
> > > references to a page.
> > 
> > You should however also consider a rearming tasklet/softirq invoked by
> > ksoftirqd, if memory allocation fails you retry later. Furthermore you
> > should not require thousands of simultaneous allocations anyway,
> > you're running in the PF_MEMALLOC path and your memory will come from
> > the precious PF_MEMALLOC pool in the objrmap paths! If you ever
> 
> Right. That is why the mmu_ops approach does not work and that is why we 
> need to sleep.

You told me you worried about atomic allocations. Now you tell me you
need to sleep after I just explained you how utterly useless is to
sleep inside GFP_KERNEL allocations when invoked by try_to_unmap in
the mm/rmap.c paths. You will never sleep in any memory allocation
other than to call schedule() because need_resched is set. You will do
zero I/O. all your allocations will come from the PF_MEMALLOC pool
like I said above, not from swapping, not from the VM. The VM will
obviously refuse to be invoked recursively.

> > attempt what you suggest (simultanous allocation of thousands of
> > packets to simultaneously notify the thousand of external reference)
> > depending on the size of the allocation you can instant deadlock
> > regardless if you can sleep or not. Infact if you can't sleep and you
> > rearm the tasklet when GFP_ATOMIC fails you won't instant
> > deadlock.... I think you should have a max-amount of simultanous
> > allocations, and you should notify the external references partially
> > _serially_. Also you can't exceed the max-amount of simultanous
> > allocation even if GFP_ATOMIC/KERNEL fails or you'll squeeze the whole
> > PF_MEMALLOC pool leading to deadlocks elsewhere. You must stop when
> > there's still quite some room in the PF_MEMALLOC pool.
> 
> Good. So we cannot use your mmops approach.

If PF_MEMALLOC from my mmu notifiers isn't enough, the place where you
put your invalidate_page will only get memory from PF_MEMALLOC and it
will also not be enough.

Also not sure why you call my patch mmops, when it's mmu_notifier instead.

> Well that could be avoided by keeping an rmap for that purpose?

This was answered in a separate email.

> Maybe we need two different types of callbacks? It seems that the callback 
> before we begin scanning the rmaps is also necessary for mmops because we 
> need to disable the ptes in some fashion before we shut down the local 
> ptes.

"disable the ptes" "before" "we shut down the local ptes". Not very
clear.

Anyway no, I don't need any call before scanning the rmaps. Doing
anything at all on the sptes before the main linux pte is gone is
backwards and flawed, just like it would be flawed to flush the tlb
before clearing the linux pte:

    flush_tlb_page()
    pte_clear()
    __free_page

I don't need to do anything at all, as long as the main linux pte is
still there.

> > > There is only the need to walk twice for pages that are marked Exported. 
> > 
> > All kvm guest physical pages would need to be marked exported of
> > course.
> 
> Why export all pages? Then you are planning to have mm_struct 
> notifiers for all processes in the system?

KVM is 1 process, not sure how you get to imagine I need to track
process in the system, when infact I only need to track pages
belonging to the KVM process.

But you're right one thing, I could also try to mark PG_exported the
guest pages currently mapped in the sptes, that's a minor optimization
that will save a bit of cpu during swapping but it will make the
non-swap fast-path a bit slower requiring one more atomic bitop for
every spte instantiation and spte unmapping.

> > > And the double walk is only necessary if the exporter does not have its 
> > > own rmap. The cross partition thing that we are doing has such an rmap and 
> > 
> > We've one rmap per-VM, so the same physical pages will have multiple
> > rmap structures, each VM is indipendent and the refcounting happens on
> > the core page_count.
> 
> Ahh. So you are basically okay?

If "cat mm/rmap.c >> arch/x86/kvm/mmu.c" means "basically ok" to you,
then yes, I'm basically ok. More details on this in Avi's email.

The other way would be to change the kvm internals to share a single
rmap structure for _all_ VM. I find so elegant to connect the main
linux pte with only the sptes associated with it that it's not very
appealing to go back and instead bind the page_t with all sptes of all
running VM instead, when infact the sptes aren't all equal but each
spte is still associated with a linux pte at runtime. Also considering
I still got to know which "mm/kvm" struct is associated with each spte
reacheable through the page_t in order to do anything with the spte.

> > > I think I explained that above. Remote users effectively are forbidden to 
> > > establish new references to the page by the clearing of the exported bit.
> > 
> > And how do they know when they can restart adding references if infact
> > the VM _never_ calls into SetPageExported? (perhaps you forgot
> > something in your patch to set PageExported again to notify the
> > external reference that it can "de-freeze" and to restart adding
> > references ;)
> 
> Well there is the subsystem missing that provides that piece.

See top of the email on how such subsystem was supposed to freeze as
long as PG_exported was unset.

> > > > with your coarse export_notifier(invalidate_page) called
> > > > unconditionally before checking any young bit at all.
> > > 
> > > The export notifier is called only if the mm_struct or page bit for 
> > > exporting is set. Maybe I missed to add a check somewhere?
> > 
> > try_to_unmap internally is doing:
> > 
> > 	     if any accessed bit is clear:
> > 	     	clear the accessed bit, flush tlb and do nothing else at all
> > 	     else
> > 		ptep_clear_flush
> > 
> > Not sure how you're going to "do nothing else at all" if you've a
> > broad invalidate_page call before even checking the linux pte.
> 
> Look at the code: It checks PageExported before doing any calls. And the 
> list of callbacks is very small. One item typically.

What's the relation between PG_exported and the young bit in the linux
pte? How do you connect the two?

It's utterly useless to call ->invalidate_page(page) on a page that is
still mapped by some linux pte with the young bit set. You must defer
the ->invalidate_page after all young bits are gone. This is what I
do, infact I do tons more than that by also honouring the accessed
bits in all sptes. There's zero chance you can do as remotely as
efficient as my mmu-notifiers are, unless you also do "cat rmap.c >>
/sgi/yoursubsystem/something.c" and you check the young bit in the
linux ptes yourself _before_ deciding if you've to start dropping
remote references or not.

> > But given with your design we'll have to replicate mm/rmap.c inside
> > KVM to find the virtual address where the page is mapped in each "mm"
> 
> The rmap that you are using is likely very much simplified. You just need 
> to track how it was mapped in order to invalidate the kvm ptes.

rmap I'm using is very lightweight, that's a feature not a bug. Why to
duplicate heavyweight info to track sptes from the "page" when I can
keep that heavyweight info just in the kvm structure?

> > Also note KVM will try to generate a core-linux page fault in order to
> > find the "page struct", so I can't see how we could ever check the
> > PageExported bit to know if we can trigger the core-linux page fault
> > or not. Your whole design is backwards as far as I can tell.
> 
> Check it before calling into the vm to generate the core-linux fault? 
> Surely you run some KVM code there.

-ENOTUNDERSTOOD but I doubt it's worth answering until the major flaws
in your #v1 are clearly understood.

> 
> > > > Look how clean it is to hook asm-generic/pgtable.h in my last patch
> > > > compared to the above leaking code expanded all over the place in the
> > > > mm/*.c, unnecessary mangling of atomic bitflags in the page struct,
> > > > etc...
> > > 
> > > I think that hunk is particularly bad in your patch. A notification side 
> > > event in a macro? You would want that explicitly in the code.
> > 
> > Sorry this is the exact opposite. I'm placing all required
> > invalidate_page with a 1 line change to the kernel source. How can
> > that be bad? This is exactly the right place to hook into so it
> > will remain as close as possible to the main linux TLB/MMU without
> > cluttering mm/*.c with notifiers all over the place. Check how clean
> > it is the access bit test_and_clear:
> > 
> > #ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
> > #define ptep_clear_flush_young(__vma, __address, __ptep)		\
> > ({									\
> > 	int __young;							\
> > 	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
> > 	if (__young)							\
> > 		flush_tlb_page(__vma, __address);			\
> > 	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
> > 	__young;							\
> > })
> > #endif
> > 
> > This is totally strightforward, clean and 100% optimal too! I fail to
> > see how this can be considered _inferior_ to your cluttering of
> > mm/*.c (plus the fact you place your hook _before_ clearing the main
> > linux pte which is backwards).
> 
> This means that if you do a ptep_clear_flush_young then mmu notifiers run 
> etc etc which may do a lot of things. You want that not hidden in a macro. 
> The flush_tlb_page there is bad enough.

Hiding the tlb flushes and being able to run ptep_clear_flush and
ptep_clear_flush_young without worrying about the arch internals is
totally clean. It's hard to believe you're seriously suggesting that
it would be better to expand all those flush_tlb_page in
mm/*.c. Furthermore this leaves each arch free to implement the
ptep_clear_flush ops like they prefer, which is a very arch lowlevel
thing.

Anyway if you think it'd be cleaner to expand flush_tlb_page in mm/*.c
and remove it from pgtable.h then you're free to send a patch to
achieve such a ""cleanup"" and I leave the comments to others, I
cannot care less about coding style issues frankly, I'm not that kind
of person caring about those things, and especially seeing how much
people opinion could diverge by your claim that cluttering mm/*.c with
tlb flushes would be a "good thing" I'm not too interested to argue
about it either.

>From my POV as long as you keep calling __young |=
mmu_notifier_age_page((__vma)->vm_mm, __address) after your cpp
expansion I'm ok.

> > > What we are doing is effectively allowing external references to pages. 
> > > This is outside of the regular VM operations. So export came up but we 
> > > could call it something else. External? Its not really tied to the mmu 
> > > now.
> > 
> > It's tied to the core linux mmu. Even for KVM it's a secondary tlb not
> > really a secondary mmu. But we want notifications of the operations on
> > the master linux mmu so we can export the same data in secondary
> > subsystems too through the notifiers.
> 
> Hmmm.. tlb notifier? I was wondering at some point if we could not tie 
> this into the tlb subsystem.

I guess I didn't explained myself clearly sorry, I was making the
example of "tlb notifier" as a wrong name for this.

> > > > > +LIST_HEAD(export_notifier_list);
> > > > 
> > > > A global list is not ok IMHO, it's really bad to have a O(N) (N number
> > > > of mm in the system) complexity here when it's so trivial to go O(1)
> > > > like in my code. We want to swap 100% of the VM exactly so we can have
> > > > zillon of idle (or sigstopped) VM on the same system.
> > > 
> > > There will only be one or two of those notifiers. There is no need to 
> > > build long lists of mm_structs like in your patch.
> > 
> > Each KVM will register into this list (they're mostly indipendent),
> > plus when each notifier is called it will have to check the rmap to
> > see if the page belongs to its "mm" before doing anything with it,
> > that's really bad for KVM.
> 
> KVM could maintain its own lists and deal with its series of KVMs in a 
> more effective way when it gets its callback.

Not more effective, but sure in some way it can be made it work.

> > > The mm_struct is not available at the point of my callbacks. There is no 
> > > way to do a callback that is mm_struct based if you are not scanning the 
> > > reverse list. And scanning the reverse list requires taking locks.
> > 
> > The thing is, we can add notifiers to my patch to fit your needs, but
> > those will be _different_ notifiers and they really should be after
> > the linux pte updates... I think fixing your code so it'll work with
> > the sleeping-notifiers getting the "page" instead of a virtual address
> > called _after_ clearing the main linux pte, is the way to go. Then
> > hopefully won't have to find a way to enable the PageExported bitflag
> > anymore in the linux VM and it may remain always-on for the exported
> > pages etc.... it makes life a whole lot easier for you too IMHO.
> 
> If you call it after then the pte will still exist remotely and allow 
> access to the page after the VM has removed processes from the page.
> 
> Just talked to Robin and I think we could work with having a callback 
> after the local ptes have been removed and the locks have been dropped. At 

I know Robin is converging on calling the secondary-MMU invalidate
after clearing the main linux pte. But I answered to the top of this
email anyway, to be sure it's clear _why_ that's the right ordering.

> that point we do not have an mm_struct anymore so the callback would have 

The mm struct wasn't available in the place where you put
invalidate_page either.

> to passs a NULL mm_struct and the page. Also the unmapping of the remote 

I think it's a lot better for it to be an invalidate_page_after(page)
w/o null parameter. Plus I want an (address, mm) pair still out of my
atomic non-sleeping call, not a "page".

> ptes may transfer a dirty bit because writing through the remote pte is 
> possible after the local ptes have been removed. So the callback notifier 
> after needs to be able to return a dirty state?

set_page_dirty can be called inside ->invalidate_page if needed. But
I'm not against artificially setting the dirty bit of the pteval
returned by set_page_dirty, perhaps that's more efficient as it will
require a single locked op on the page_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
