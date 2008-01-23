Date: Wed, 23 Jan 2008 16:41:30 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123154130.GC7141@v2.random>
References: <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <4797384B.7080200@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4797384B.7080200@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerd Hoffmann <kraxel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Kraxel,

On Wed, Jan 23, 2008 at 01:51:23PM +0100, Gerd Hoffmann wrote:
> That would render the notifies useless for Xen too.  Xen needs to
> intercept the actual pte clear and instead of just zapping it use the
> hypercall to do the unmap and release the grant.

I think it has yet to be demonstrated that doing the invalidate
_before_ clearing the linux pte is workable at all for
shadow-pte/RDMA. Infact even doing it _after_ still requires some form
of serialization but it's less obviously broken and perhaps more
fixable unlike doing it before that seems hardly fixable given the
refill event running in the remote node is supposed to wait on a
bitflag of a page in the master node to return ON. What Christoph
didn't specify after hinting you have to wait for the PageExported
bitflag to return on, is that such page may be back in the freelist by
the time the secondary-tlb page fault starts checking that bit. And
nobody is setting that bit anyway in the VM so good luck waiting that
bit to return on in a page in the freelist (nothing keeps that page
pinned anymore by the time the ->invalidate_page returns: the whole
point of the invalidate is so the VM code can finally free it and put
it in the freelist).

Until there's some more reasonable theory of how invalidating the
remote tlbs/ptes _before_ the main linux pte can remotely work, I'm
"quite" skeptical it's the way to go for the invalidate_page callback.

Like Avi said, Xen is dealing with the linux pte only, so there's no
racy smp page fault to serialize against. Perhaps we can add another
notifier for Xen though.

But I think it's still not enough for Xen to have a method called
before the ptep_clear_flush: rmap.c would get confused in
page_mkclean_one for example. It might be possible that vm_ops is the
right way for you even if it further clutters the VM. Like Avi pointed
me out once, with our current mmu_notifiers we can export the KVM
address space with remote dma and keep swapping the whole KVM asset
just fine despite the triple MMU running the system (qemu using linux
pte, KVM using spte, quadrics using pcimmu). And the core Linux VM
code (not some obscure hypervisor) will deal with all aging and VM
issues like a normal task (especially with my last patch that reflects
the accessed bitflag in the spte the same way the accessed bitflag is
reflected for the regular ptes).

Nevertheless if you've any idea on how to use the notifiers for Xen
I'd be glad to help. Perhaps one workable way to change my patch to
work for you could be to pass the retval of ptep_clear_flush to the
notifiers themself. something like:

#define ptep_clear_flush(__vma, __address, __ptep)			\
({									\
	pte_t __pte;							\
	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
	flush_tlb_page(__vma, __address);				\
	__pte = mmu_notifier(invalidate_page, (__vma)->vm_mm, __address, __pte, __ptep);	\
	__pte;								\
})

But this would kind of need an exclusive registration or this loop
wouldn't work well if everyone pretends to overwrite the memory
pointed by __ptep with its own value calculated in function of __pte.

    for_each_notifier(mn,mm)
        mn->invalidate_page(mm, __address, __pte, __ptep);

You could get a pte_none page fault in between the old value and the
new value though. (but you wouldn't need to flush the tlb inside
invalidate_pte, only us need to flush the secondary tlb for the spte
inside the invalidate_page obviously)

Let me know if you're interested in the above.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
