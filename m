Date: Thu, 17 Jan 2008 17:23:02 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH] mmu notifiers #v2
Message-ID: <20080117162302.GI7170@v2.random>
References: <20080113162418.GE8736@v2.random> <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <478E4356.7030303@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, clameter@sgi.com, daniel.blueman@quadrics.com, holt@sgi.com, steiner@sgi.com, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, andrea@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 07:48:06PM +0200, Izik Eidus wrote:
> Rik van Riel wrote:
>> On Sun, 13 Jan 2008 17:24:18 +0100
>> Andrea Arcangeli <andrea@qumranet.com> wrote:
>>
>>   
>>> In my basic initial patch I only track the tlb flushes which should be
>>> the minimum required to have a nice linux-VM controlled swapping
>>> behavior of the KVM gphysical memory.     
>>
>> I have a vaguely related question on KVM swapping.
>>
>> Do page accesses inside KVM guests get propagated to the host
>> OS, so Linux can choose a reasonable page for eviction, or is
>> the pageout of KVM guest pages essentially random?

Right, selection of the guest OS pages to swap is partly random but
wait: _only_ for the long-cached and hot spte entries. It's certainly
not entirely random.

As the shadow-cache is a bit dynamic, every new instantiated spte will
refresh the PG_referenced bit in follow_page already (through minor
faults). not-present fault of swapped non-present sptes, can trigger
minor faults from swapcache too and they'll refresh young regular
ptes.

> right now when kvm remove pte from the shadow cache, it mark as access the 
> page that this pte pointed to.

Yes: the referenced bit in the mmu-notifier invalidate case isn't
useful because it's set right before freeing the page.

> it was a good solution untill the mmut notifiers beacuse the pages were 
> pinned and couldnt be swapped to disk

It probably still makes sense for sptes removed because of other
reasons (not mmu notifier invalidates).

> so now it will have to do something more sophisticated or at least mark as 
> access every page pointed by pte
> that get insrted to the shadow cache....

I think that should already be the case, see the mark_page_accessed in
follow_page, isn't FOLL_TOUCH set, isn't it?

The only thing we clearly miss is a logic that refreshes the
PG_referenced bitflag for "hot" sptes that remains instantiated and
cached for a long time. For regular linux ptes this is done by the cpu
through the young bitflag. But note that not all architectures have
the young bitflag support in hardware! So I suppose the swapping of
the KVM task, is like the swapping any other task but on an alpha
CPU. It works good enough in practice even if we clearly have room for
further optimizations in this area (like there would be on archs w/o
young bit updated in hardware too).

To refresh the PG_referenced bit for long lived hot sptes, I think the
easiest solution is to chain the sptes in a lru, and to start dropping
them when memory pressure start. We could drop one spte every X pages
collected by the VM. So the "age" time factor depends on the VM
velocity and we totally avoid useless shadow page faults when there's
no VM pressure. When VM pressure increases, the kvm non-present fault
will then take care to refresh the PG_referenced bit. This should
solve the aging-issue for long lived and hot sptes. This should
improve the responsiveness of the guest OS during "initial" swap
pressure (after the initial swap pressure, the working set finds
itself in ram again). So it should avoid some swapout/swapin not
required jitter during the initial swap. I see this mostly as a kvm
internal optimization, not strictly related to the mmu notifiers
though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
