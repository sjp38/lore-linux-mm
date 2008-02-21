Date: Thu, 21 Feb 2008 15:40:23 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080221144023.GC9427@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080221045430.GC15215@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2008 at 05:54:30AM +0100, Nick Piggin wrote:
> will send you incremental changes that can be discussed more easily
> that way (nothing major, mainly style and minor things).

I don't need to say you're very welcome ;).

> I agree: your coherent, non-sleeping mmu notifiers are pretty simple
> and unintrusive. The sleeping version is fundamentally going to either
> need to change VM locks, or be non-coherent, so I don't think there is
> a question of making one solution fit everybody. So the sleeping /
> xrmap patch should be kept either completely independent, or as an
> add-on to this one.

The need to change the VM locks to fit the sleepable "mmu notifier"
needs, I think is the major reason why the sleeping patch should be a
separate config option unless you think the i_mmap_lock will benefit
the VM for its own good regardless of the sleepable mmu
notifiers. Otherwise we'll end up merging in mainline an API that can
only satisfy the needs of the "sleeping users" that are only
interested about anonymous memory. While the basic concept of the mmu
notifiers is to cover the whole user visible address space, not just
anonymous memory! Furthermore XPMEM users already asked to work on
tmpfs/MAP_SHARED too...

Originally the trick that I was trying to remove the "atomic" param,
was to defer the invalidate_range after dropping the i_mmap_lock. But
clearly in truncate we'll have no more guarantees that nor the vma nor
the MM still exists after spin_unlock(i_mmap_lock) is called... So
it's simply impossible to call the mmu notifier out of the i_mmap_lock
for truncate, and Christoph's patch looks unfixable without altering
the VM core locking. Christoph's API one-config-fits-all can't really
fit-all, but only the anonymous memory.

However if I wear a KVM hat, I cannot care less what is merged as long
as .25 will be able to fully swap reliably a virtualized guest OS ;).
This is why I'm totally willing to support any decision in favor of
anything (including your own patch that would only work for KVM) that
can be merged.

> I will post some suggestions to you when I get a chance.

I really want suggestions on Jack's concern about issuing an
invalidate per pte entry or per-pte instead of per-range. I'll answer
that in a separate email. For KVM my patch is already close to optimal
because each single spte invalidate requires a fixed amount of work,
but for GRU a large invalidate-range would be more efficient.

To address the GRU _valid_ concern, I can create a second version of
my patch with range_begin/end instead of invalidate_pages, that still
won't support sleeping users like XPMEM but only KVM and GRU. Then
it's up to Christoph when he comes back to alter the vm locking so
that those calls can sleep too... But that will require a much bigger
change and then perhaps xpmem can share the same mmu notifiers when
the config option to make the mmu notifier sleepable is enabled. But
that part would better be incremental as it's not so obviously safe to
merge as the mmu notifier themself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
