Message-ID: <47977DCA.3040904@redhat.com>
Date: Wed, 23 Jan 2008 18:47:54 +0100
From: Gerd Hoffmann <kraxel@redhat.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH] export notifier #1
References: <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <4797384B.7080200@redhat.com> <20080123154130.GC7141@v2.random>
In-Reply-To: <20080123154130.GC7141@v2.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> Like Avi said, Xen is dealing with the linux pte only, so there's no
> racy smp page fault to serialize against. Perhaps we can add another
> notifier for Xen though.
> 
> But I think it's still not enough for Xen to have a method called
> before the ptep_clear_flush: rmap.c would get confused in
> page_mkclean_one for example.

The current code sets a bunch of vma flags (VM_RESERVED, VM_DONTCOPY,
VM_FOREIGN) so the VM doesn't try to handle those special mapping.  IIRC
one of them was needed to not make rmap unhappy.

> Nevertheless if you've any idea on how to use the notifiers for Xen
> I'd be glad to help. Perhaps one workable way to change my patch to
> work for you could be to pass the retval of ptep_clear_flush to the
> notifiers themself. something like:
> 
> #define ptep_clear_flush(__vma, __address, __ptep)			\
> ({									\
> 	pte_t __pte;							\
> 	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
> 	flush_tlb_page(__vma, __address);				\
> 	__pte = mmu_notifier(invalidate_page, (__vma)->vm_mm, __address, __pte, __ptep);	\
> 	__pte;								\
> })

Would not work.  Need to pass a pointer to the pte so the xen hypervisor
can do unmap (aka pte_clear) and grant release as atomic operation.
Thus passing the value of the pte entry isn't good enougth.

Another maybe workable approach for Xen is to go through pv_ops
(although pte_clear doesn't go through pv_ops right now, so this would
be an additional hook too ...).

cheers,
  Gerd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
