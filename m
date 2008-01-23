Date: Wed, 23 Jan 2008 12:41:36 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123114136.GE15848@v2.random>
References: <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Tue, Jan 22, 2008 at 02:53:12PM -0800, Christoph Lameter wrote:
> On Tue, 22 Jan 2008, Andrea Arcangeli wrote:
> 
> > First it makes me optimistic this can be merged sooner than later to
> > see a second brand new implementation of this ;).
> 
> Brand new? Well this is borrowing as much as possible from you....

I said "new", not "different" ;).

> > > The problem that I have with this is still that there is no way to sleep 
> > > while running the notifier. We need to invalidate mappings on a remote 
> > > instance of linux. This means sending out a message and waiting for reply 
> > > before the local page is unmapped. So I reworked Andrea's early patch and 
> > > came up with this one:
> > 
> > I guess you missed a problem in unmapping the secondary mmu before the
> > core linux pte is cleared with a zero-locking window in between the
> > two operations. The spte may be instantiated again by a
> > vmexit/secondary-pagefault in another cpu during the zero-locking
> > window (zero locking is zero locking, anything can run in the other
> > cpus, so not exactly sure how you plan to fix that nasty subtle spte
> > leak if you insist calling the mmu_notifier invalidates _before_
> > instead of _after_ ;). All spte invalidates should happen _after_
> > dropping the main linux pte not before, or you never know what else is
> > left mapped in the secondary mmu by the time the linux pte is finally
> > cleared.
> 
> spte is the remote pte in my scheme right? [..]

yes.

> [..] The linux instance with the 
> secondary mmu must call back to the exporting machine in order to 
> reinstantiate the page. PageExported is cleared in invalidate_page() so 
> the other linux instance will be told that the page is not available.

Page is not available is not a valid answer. At least with KVM there
are three possible ways:

1) the remote instance will have to wait for the linux pte to go away
   before calling follow_page (then the page is gone as a whole so
   there won't be any more page flags to check)
2) it will kill the VM

Nothing runs SetPageExported in your VM code, I can't see how the
remote instance can know when it can call follow_page again safely on
the master node.

The remote instance is like a secondary TLB what you're doing in your
code is as backwards as flushing the TLB _before_ clearing the PTE! If
you want to call the secondary tlb flush outside locks we can argue
about that, but I think you should do that _after_ clearing the linux
pte IMHO. Otherwise you can as well move the tlb_flush_page before
clearing the pte and you'll run in the same amount of smp races for
the master MMU too.

> Ahhh. Good to hear. But we will still end in a situation where only
> the remote ptes point to the page. Maybe the remote instance will dirty
> the page at that point?

If you flush the remote instance _after_ clearing the main linux PTE
like I suggest and like I'm doing in my patch, I can't see how you
could risk to end up in a situation with only the remote ptes pointing
the page, that's the whole point of doing the remote-TLB flush _after_
clearing the main linux pte, instead of before like in your patch.

This is the same as the tlb flush, there's a reason we normally do:

     pte_clear()
     flush_tlb_page()
     __free_page()
     
instead of:

     flush_tlb_page()
     pte_clear()
     __free_page()

The ordering you're implementing is backwards and unnatural, you can
try to serialize it with explicit locking to block the "remote-tlb
refills" through page bitflags (something not doable with the core
master tlb because the refills are done by the hardware with the
master tlb), but it'll remain unnatural and backwards IMHO.

> > > - anon_vma/inode and pte locks are held during callbacks.
> > 
> > In a previous email I asked what's wrong in offloading the event, and
> 
> We have internally discussed the possibility of offloading the event but 
> that wont work with the existing callback since we would have to 
> perform atomic allocation and there may be thousands of external 
> references to a page.

You should however also consider a rearming tasklet/softirq invoked by
ksoftirqd, if memory allocation fails you retry later. Furthermore you
should not require thousands of simultaneous allocations anyway,
you're running in the PF_MEMALLOC path and your memory will come from
the precious PF_MEMALLOC pool in the objrmap paths! If you ever
attempt what you suggest (simultanous allocation of thousands of
packets to simultaneously notify the thousand of external reference)
depending on the size of the allocation you can instant deadlock
regardless if you can sleep or not. Infact if you can't sleep and you
rearm the tasklet when GFP_ATOMIC fails you won't instant
deadlock.... I think you should have a max-amount of simultanous
allocations, and you should notify the external references partially
_serially_. Also you can't exceed the max-amount of simultanous
allocation even if GFP_ATOMIC/KERNEL fails or you'll squeeze the whole
PF_MEMALLOC pool leading to deadlocks elsewhere. You must stop when
there's still quite some room in the PF_MEMALLOC pool.

> The approach with the export notifier is page based not based on the 
> mm_struct. We only need a single page count for a page that is exported to 
> a number of remote instances of linux. The page count is dropped when all 
> the remote instances have unmapped the page.

With KVM it doesn't work that way. Anyway you must be keeping a
"secondary" count if you know when it's time to call
__free_page/put_page, so why don't you use the main page_count instead?

> > > @@ -966,6 +973,9 @@ int try_to_unmap(struct page *page, int 
> > >  
> > >  	BUG_ON(!PageLocked(page));
> > >  
> > > +	if (unlikely(PageExported(page)))
> > > +		export_notifier(invalidate_page, page);
> > > +
> > 
> > Passing the page here will complicate things especially for shared
> > pages across different VM that are already working in KVM. For non
> 
> How?

Because especially for shared pages we'll have to walk
objrmap/anon_vma->vmas->ptes by hand in our lowlevel methods twice to
get to the address where the page is mapped in the address space of
the task etc...

> There is only the need to walk twice for pages that are marked Exported. 

All kvm guest physical pages would need to be marked exported of
course.

> And the double walk is only necessary if the exporter does not have its 
> own rmap. The cross partition thing that we are doing has such an rmap and 

We've one rmap per-VM, so the same physical pages will have multiple
rmap structures, each VM is indipendent and the refcounting happens on
the core page_count.

If multiple KVM images are using the page, then multiple "mm" will
have a mmu notifier registered, and they'll all be called when we walk
the objrmap/anon_vma with the address where the page is mapped in each
"mm". That's what we need to find the rmap structure for the "mm".

> its a matter of walking the exporters rmap to clear out the external 
> references and then we walk the local rmaps. All once.

The problem in having a single rmap for a physical page is that it'd
need to be a data structure shared by all KVM instances, it doesn't
work that way right now and certainly there would be complications.

> > Besides the pinned pages ram leak by having the zero locking window
> > above I'm curious how you are going to take care of the finegrined
> > aging that I'm doing with the accessed bit set by hardware in the spte
> 
> I think I explained that above. Remote users effectively are forbidden to 
> establish new references to the page by the clearing of the exported bit.

And how do they know when they can restart adding references if infact
the VM _never_ calls into SetPageExported? (perhaps you forgot
something in your patch to set PageExported again to notify the
external reference that it can "de-freeze" and to restart adding
references ;)

> > with your coarse export_notifier(invalidate_page) called
> > unconditionally before checking any young bit at all.
> 
> The export notifier is called only if the mm_struct or page bit for 
> exporting is set. Maybe I missed to add a check somewhere?

try_to_unmap internally is doing:

	     if any accessed bit is clear:
	     	clear the accessed bit, flush tlb and do nothing else at all
	     else
		ptep_clear_flush

Not sure how you're going to "do nothing else at all" if you've a
broad invalidate_page call before even checking the linux pte.

But given with your design we'll have to replicate mm/rmap.c inside
KVM to find the virtual address where the page is mapped in each "mm"
that might have a KVM instance running, I guess we can duplicate it
all and check the young bit too. Infact we could duplicate the whole
thing and offload mm/rmap.c inside KVM and perhaps it'll work ok. But
I don't think having to duplicate the whole mm/rmap.c in an external
module is a good design when my model requires zero duplication, zero
"freezing" of the SVM/VMX pagefaults as long as PageExported bitflag
is clear (and nobody knows who's supposed to SetPageExported again to
"unfreeze" the KVM page fault, certainly KVM can't know when the VM
has finished clearing the pte and flushing the core linux tlb).

Also note KVM will try to generate a core-linux page fault in order to
find the "page struct", so I can't see how we could ever check the
PageExported bit to know if we can trigger the core-linux page fault
or not. Your whole design is backwards as far as I can tell.

> > Look how clean it is to hook asm-generic/pgtable.h in my last patch
> > compared to the above leaking code expanded all over the place in the
> > mm/*.c, unnecessary mangling of atomic bitflags in the page struct,
> > etc...
> 
> I think that hunk is particularly bad in your patch. A notification side 
> event in a macro? You would want that explicitly in the code.

Sorry this is the exact opposite. I'm placing all required
invalidate_page with a 1 line change to the kernel source. How can
that be bad? This is exactly the right place to hook into so it
will remain as close as possible to the main linux TLB/MMU without
cluttering mm/*.c with notifiers all over the place. Check how clean
it is the access bit test_and_clear:

#ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
#define ptep_clear_flush_young(__vma, __address, __ptep)		\
({									\
	int __young;							\
	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
	if (__young)							\
		flush_tlb_page(__vma, __address);			\
	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
	__young;							\
})
#endif

This is totally strightforward, clean and 100% optimal too! I fail to
see how this can be considered _inferior_ to your cluttering of
mm/*.c (plus the fact you place your hook _before_ clearing the main
linux pte which is backwards).

> > > +	bool "Export Notifier for notifying subsystems about changes to page mappings"
> > 
> > The word "export notifier" isn't very insightful to me, it doesn't
> > even give an hint we're in the memory management area. If you don't
> > like mmu notifier name I don't mind changing it, but I doubt export
> > notifier is a vast naming improvement. Infact it looks one of those
> > names like RCU that don't tell much of what is really going on
> > (there's no copy 99% of time in RCU).
> 
> What we are doing is effectively allowing external references to pages. 
> This is outside of the regular VM operations. So export came up but we 
> could call it something else. External? Its not really tied to the mmu 
> now.

It's tied to the core linux mmu. Even for KVM it's a secondary tlb not
really a secondary mmu. But we want notifications of the operations on
the master linux mmu so we can export the same data in secondary
subsystems too through the notifiers.

It wasn't a "pte" notifier, not always we notify about pte updates,
sometime we notify about "range of virtual addresses being zapped
without even knowing if a pte existed in the range". It wasn't a "tlb"
notifier because we don't always notify whenever there is a tlb flush
in the main linux VM. we simply notify about certain events that
affect the master MMU that allows to represent the userland memory not
only in the master MMU.

> > > +LIST_HEAD(export_notifier_list);
> > 
> > A global list is not ok IMHO, it's really bad to have a O(N) (N number
> > of mm in the system) complexity here when it's so trivial to go O(1)
> > like in my code. We want to swap 100% of the VM exactly so we can have
> > zillon of idle (or sigstopped) VM on the same system.
> 
> There will only be one or two of those notifiers. There is no need to 
> build long lists of mm_structs like in your patch.

Each KVM will register into this list (they're mostly indipendent),
plus when each notifier is called it will have to check the rmap to
see if the page belongs to its "mm" before doing anything with it,
that's really bad for KVM.

> The mm_struct is not available at the point of my callbacks. There is no 
> way to do a callback that is mm_struct based if you are not scanning the 
> reverse list. And scanning the reverse list requires taking locks.

The thing is, we can add notifiers to my patch to fit your needs, but
those will be _different_ notifiers and they really should be after
the linux pte updates... I think fixing your code so it'll work with
the sleeping-notifiers getting the "page" instead of a virtual address
called _after_ clearing the main linux pte, is the way to go. Then
hopefully won't have to find a way to enable the PageExported bitflag
anymore in the linux VM and it may remain always-on for the exported
pages etc.... it makes life a whole lot easier for you too IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
