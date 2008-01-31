Date: Thu, 31 Jan 2008 01:34:34 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [patch 2/6] mmu_notifier: Callbacks to invalidate
	address ranges
Message-ID: <20080131003434.GE7185@v2.random>
References: <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com> <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com> <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com> <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com> <20080130235214.GC7185@v2.random> <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 04:01:31PM -0800, Christoph Lameter wrote:
> How we offload that? Before the scan of the rmaps we do not have the 
> mmstruct. So we'd need another notifier_rmap_callback.

My assumption is that that "int lock" exists just because
unmap_mapping_range_vma exists. If I'm right then my suggestion was to
move the invalidate_range after dropping the i_mmap_lock and not to
invoke it inside zap_page_range.

> The obvious solution does not scale. You will have a callback for every 

Scale is the wrong word. The PT lock will prevent any other cpu to
trash on the mmu_lock, so it's a fixed cost for each pte_clear with no
scalability risk, nor any complexity issue. Certainly we could average
certain fixed costs over more than one pte_clear to boost performance,
and that's good idea. Not really a short term concern, we need to swap
reliably first ;).

> page and there may be a million of those if you have a 4GB process.

That can be optimized adding a __ptep_clear_flush and an
invalidate_pages (let's call it pages to better show it's an
'clustered' version of invalidate_page, to avoid the confusion with
_range_before/after that does an entirely different thing). Also for
_range I tend to like before/after, as a means to say before the
pte_clear and after the pte_clear but any other meaning is ok with me.

We add invalidate_page and invalidate_pages
immediately. invalidate_pages may never be called initially by the
linux VM, we can start calling it later as we replace ptep_clear_flush
with __ptep_clear_flush (or local_ptep_clear_flush).

I don't see any problem with this approach and it looks quite clean to
me and it leaves you full room for experimenting in practice with
range_before/after while knowing those range_before/after won't
require many changes.

And for things like the age_page it will never happen that you could
call the respective ptep_clear_flush_young w/o mmu notifier age_page
after it, so you won't ever risk having to add an age_pages or a
__ptep_clear_flush_young.

> We need to have a coherent notifier solution that works for multiple 
> scenarios. I think a working invalidate_range would also be required for 
> KVM. KVM and GRUB are very similar so they should be able to use the same 
> mechanisms and we need to properly document how that mechanism is safe. 
> Either both take a page refcount or none.

There's no reason why KVM should take any risk of corrupting memory
due to a single missing mmu notifier, with not taking the
refcount. get_user_pages will take it for us, so we have to pay the
atomic-op anyway. It sure worth doing the atomic_dec inside the mmu
notifier, and not immediately like this:

	  get_user_pages(pages)
	  __free_page(pages[0])

The idea is that what works for GRU, works for KVM too. So we do a
single invalidate_page and clustered invalidate_pages, we add that,
and then we make sure all places are covered so GRU will not
kernel-crash, and KVM won't risk to run oom or to generate _userland_
corruption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
