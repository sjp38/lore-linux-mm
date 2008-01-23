Date: Wed, 23 Jan 2008 12:40:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
In-Reply-To: <20080123154130.GC7141@v2.random>
Message-ID: <Pine.LNX.4.64.0801231231400.13547@schroedinger.engr.sgi.com>
References: <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random>
 <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random>
 <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com>
 <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random>
 <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
 <4797384B.7080200@redhat.com> <20080123154130.GC7141@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Gerd Hoffmann <kraxel@redhat.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jan 2008, Andrea Arcangeli wrote:

> I think it has yet to be demonstrated that doing the invalidate
> _before_ clearing the linux pte is workable at all for
> shadow-pte/RDMA. Infact even doing it _after_ still requires some form
> of serialization but it's less obviously broken and perhaps more
> fixable unlike doing it before that seems hardly fixable given the
> refill event running in the remote node is supposed to wait on a
> bitflag of a page in the master node to return ON. What Christoph
> didn't specify after hinting you have to wait for the PageExported
> bitflag to return on, is that such page may be back in the freelist by

Why would you wait for the PageExported flag to return on? You remove the 
remote mappings, the page lock is being held so no new mappings can occur. 
Then you remove the local mappings. A concurrent remote fault would be 
prevented by the subsystem which could involve waiting on the page lock.

> Until there's some more reasonable theory of how invalidating the
> remote tlbs/ptes _before_ the main linux pte can remotely work, I'm
> "quite" skeptical it's the way to go for the invalidate_page callback.

Not sure that I see the problem if the subsystem prevents new references 
from being established.
 
> Like Avi said, Xen is dealing with the linux pte only, so there's no
> racy smp page fault to serialize against. Perhaps we can add another
> notifier for Xen though.

Well I think we need to come up with a set of notifiers that can cover all 
cases. And so far the export notifiers seem to be the most general. But 
they also require more intelligence in the notifiers to do proper 
serialization and reverse mapping.
 
> But I think it's still not enough for Xen to have a method called
> before the ptep_clear_flush: rmap.c would get confused in
> page_mkclean_one for example. It might be possible that vm_ops is the

Why would it get confused? When we get to the operations in rmap.c we 
just need to be sure that remote references do no longer exist. If the 
operations in rmap.c fail then we can reestablish references on demand.

> right way for you even if it further clutters the VM. Like Avi pointed
> me out once, with our current mmu_notifiers we can export the KVM
> address space with remote dma and keep swapping the whole KVM asset
> just fine despite the triple MMU running the system (qemu using linux
> pte, KVM using spte, quadrics using pcimmu). And the core Linux VM
> code (not some obscure hypervisor) will deal with all aging and VM
> issues like a normal task (especially with my last patch that reflects
> the accessed bitflag in the spte the same way the accessed bitflag is
> reflected for the regular ptes).

The problem for us there is that multiple references may exist remotely. 
So the actual remote reference count needs to be calculated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
