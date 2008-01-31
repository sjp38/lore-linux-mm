Date: Wed, 30 Jan 2008 17:46:21 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [patch 2/6] mmu_notifier: Callbacks to invalidate
 address ranges
In-Reply-To: <20080131003434.GE7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801301728110.2454@schroedinger.engr.sgi.com>
References: <20080129220212.GX7233@v2.random>
 <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com>
 <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com>
 <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com>
 <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
 <20080130235214.GC7185@v2.random> <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com>
 <20080131003434.GE7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Andrea Arcangeli wrote:

> On Wed, Jan 30, 2008 at 04:01:31PM -0800, Christoph Lameter wrote:
> > How we offload that? Before the scan of the rmaps we do not have the 
> > mmstruct. So we'd need another notifier_rmap_callback.
> 
> My assumption is that that "int lock" exists just because
> unmap_mapping_range_vma exists. If I'm right then my suggestion was to
> move the invalidate_range after dropping the i_mmap_lock and not to
> invoke it inside zap_page_range.

There is still no pointer to the mm_struct available there because pages 
of a mapping may belong to multiple processes. So we need to add another 
rmap method?

The same issue is also occurring for unmap_hugepages().
 
> There's no reason why KVM should take any risk of corrupting memory
> due to a single missing mmu notifier, with not taking the
> refcount. get_user_pages will take it for us, so we have to pay the
> atomic-op anyway. It sure worth doing the atomic_dec inside the mmu
> notifier, and not immediately like this:

Well the GRU uses follow_page() instead of get_user_pages. Performance is 
a major issue for the GRU. 


> 	  get_user_pages(pages)
> 	  __free_page(pages[0])
> 
> The idea is that what works for GRU, works for KVM too. So we do a
> single invalidate_page and clustered invalidate_pages, we add that,
> and then we make sure all places are covered so GRU will not
> kernel-crash, and KVM won't risk to run oom or to generate _userland_
> corruption.

Hmmmm.. Could we go to a scheme where we do not have to increase the page 
count? Modifications of the page struct require dirtying a cache line and 
it seems that we do not need an increased page count if we have an
invalidate_range_start() that clears all the external references 
and stops the establishment of new ones and invalidate_range_end() that 
reenables new external references?

Then we do not need the frequent invalidate_page() calls.

The typical case would be anyways that invalidate_all() is called 
before anything else on exit. Invalidate_all() would remove all pages 
and disable creation of new references to the memory in the mm_struct.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
