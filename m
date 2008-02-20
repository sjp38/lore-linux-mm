Date: Wed, 20 Feb 2008 13:03:24 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080220120324.GW7128@v2.random>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080220113313.GD11364@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220113313.GD11364@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 05:33:13AM -0600, Robin Holt wrote:
> But won't that other "subsystem" cause us to have two seperate callouts
> that do equivalent things and therefore force a removal of this and go
> back to what Christoph has currently proposed?

The point is that a new kind of notifier that only supports sleeping
users will allow to keep optimizing the mmu notifier patch for the
non-sleeping users. If we keep going Christoph's way of having a
single notifier that fits all he will have to:

1) drop the entire RCU locking from its patches (making all previous
   rcu discussions and fixes void) those discussions only made sense
   if applied to _my_ patch, not Christoph's patches as long as you
   pretend to sleep in any of his mmu notifier methods like invalidate_range_*.

2) probably modify the linux VM to replace the i_mmap_lock and perhaps
   PT lock with a mutex (see Nick's comments for details)

I'm unconvinced both the main linux VM and the mmu notifier should be
changed like this just to support xpmem. All non-sleeping users don't
need that. Nevertheless I'm fully welcome to support xpmem (and it's
not my call nor my interest to comment if allocating skbs in
try_to_unmap in order to unpin pages is workable, let's assume it's
workable for the sake of this discussion) with a new config option
that will also alter how the core VM works, in order to fully support
the sleeping users for filebacked mappings.

This will also create less confusion in the registration. With
Christoph's one-config-option-fits-all you had to half register into
the mmu notifier (the sleeping calls, so not invalidate_page) and full
register in the external rmap notifier, and I had to only half
register into the mmu notifier (not range_begin) and not register in
the rmap external notifier.

With two separate config options for sleeping and non sleeping users,
I'll 100% register in the mmu notifier methods, and the non-sleeping
users will 100% register the xpmem methods. You won't have to have
designed the mmu notifier patches to understand how to use it.

In theory both KVM and GRU are free to use the xpmem methods too (the
invalidate_page will be page_t based instead of [mm,addr] based, but
that's possible to handle with KVM changes if one wants to), but if a
distro only wants to support the sleeping users in their binary kernel
images, they won't be forced to alter how the VM works to do
that.

If there's agreement that the VM should alter its locking from
spinlock to mutex for its own good, then Christoph's
one-config-option-fits-all becomes a lot more appealing (replacing RCU
with a mutex in the mmu notifier list registration locking isn't my
main worry and the non-sleeping-users may be ok to live with it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
