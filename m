Date: Wed, 23 Jan 2008 06:32:30 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123123230.GH26420@sgi.com>
References: <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <20080123114136.GE15848@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080123114136.GE15848@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Christoph, Maybe you can clear one thing up.  Was this proposal an
addition to or replacement of Andrea's?  I assumed an addition.  I am
going to try to restrict my responses to ones appropriate for that
assumption.

> The remote instance is like a secondary TLB what you're doing in your
> code is as backwards as flushing the TLB _before_ clearing the PTE! If
> you want to call the secondary tlb flush outside locks we can argue
> about that, but I think you should do that _after_ clearing the linux
> pte IMHO. Otherwise you can as well move the tlb_flush_page before
> clearing the pte and you'll run in the same amount of smp races for
> the master MMU too.

I can agree to doing the flush after as long as I get a flag from the
mmu notifier saying this flush will be repeated later without locks
held.  That would be fine with me.  If we don't have that then the
export_notifiers would need to be expanded to cover all cases of pte
clearing.  Baring one of the two, I would argue we have an unworkable
solution for XPMEM.  This is because of allocations which is touched
upon later.

> The ordering you're implementing is backwards and unnatural, you can
> try to serialize it with explicit locking to block the "remote-tlb
> refills" through page bitflags (something not doable with the core
> master tlb because the refills are done by the hardware with the
> master tlb), but it'll remain unnatural and backwards IMHO.

Given one of the two compromises above, I believe this will then work
for XPMEM.  The callouts were placed as they are now to prevent the
mmu_notifier callouts from having to do work.

> > > > - anon_vma/inode and pte locks are held during callbacks.
> > > 
> > > In a previous email I asked what's wrong in offloading the event, and
> > 
> > We have internally discussed the possibility of offloading the event but 
> > that wont work with the existing callback since we would have to 
> > perform atomic allocation and there may be thousands of external 
> > references to a page.

As an example of thousands, we currently have one customer job that
has 16880 processors all with the same physical page faulted into their
address space.  The way XPMEM is currently structured, there is fan-out of
that PFN information so we would not need to queue up that many messages,
but it would still be considerable.  Our upcoming version of the hardware
will potentially make this fanout worse because we are going to allow
even more fine-grained divisions of the machine to help with memory
error containment.

> With KVM it doesn't work that way. Anyway you must be keeping a
> "secondary" count if you know when it's time to call
> __free_page/put_page, so why don't you use the main page_count instead?

We have a counter associated with a pfn that indicates when the pfn is no
longer referenced by other partitions.  This counter triggers changing of
memory protections so any subsequent access to this page will result in
a memory error on the remote partition (this should be an illegal case).

> And how do they know when they can restart adding references if infact
> the VM _never_ calls into SetPageExported? (perhaps you forgot
> something in your patch to set PageExported again to notify the
> external reference that it can "de-freeze" and to restart adding
> references ;)

I assumed Christoph intended this to be part of our memory protection
changing phase.  Once we have raised memory protections for the page,
clear the bit.  When we lower memory protections, set the bit.

> The thing is, we can add notifiers to my patch to fit your needs, but
> those will be _different_ notifiers and they really should be after
> the linux pte updates... I think fixing your code so it'll work with
> the sleeping-notifiers getting the "page" instead of a virtual address
> called _after_ clearing the main linux pte, is the way to go. Then
> hopefully won't have to find a way to enable the PageExported bitflag
> anymore in the linux VM and it may remain always-on for the exported
> pages etc.... it makes life a whole lot easier for you too IMHO.

As I said before, I was under the assumption that Christoph was proposing
this as an addition to your notifiers, not a replacement.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
