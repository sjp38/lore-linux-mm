Date: Wed, 30 Jan 2008 11:50:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080130182506.GQ7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
References: <20080129162004.GL7233@v2.random>
 <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com>
 <20080129211759.GV7233@v2.random> <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com>
 <20080129220212.GX7233@v2.random> <Pine.LNX.4.64.0801291407380.27104@schroedinger.engr.sgi.com>
 <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com>
 <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com>
 <20080130182506.GQ7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008, Andrea Arcangeli wrote:

> XPMEM requires with invalidate_range (sleepy) +
> before_invalidate_range (sleepy). invalidate_all should also be called
> before_release (both sleepy).
> 
> It sounds we need full overlap of information provided by
> invalidate_page and invalidate_range to fit all three models (the
> opposite of the zero objective that current V3 is taking). And the
> swap will be handled only by invalidate_page either through linux rmap
> or external rmap (with the latter that can sleep so it's ok for you,
> the former not). GRU can safely use the either the linux rmap notifier
> or the external rmap notifier equally well, because when try_to_unmap
> is called the page is locked and obviously pinned by the VM itself.

So put the invalidate_page() callbacks in everywhere.

Then we have 

invalidate_range_start(mm)

and

invalidate_range_finish(mm, start, end)

in addition to the invalidate rmap_notifier?

---
 include/linux/mmu_notifier.h |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h	2008-01-30 11:49:02.000000000 -0800
+++ linux-2.6/include/linux/mmu_notifier.h	2008-01-30 11:49:57.000000000 -0800
@@ -69,10 +69,13 @@ struct mmu_notifier_ops {
 	/*
 	 * lock indicates that the function is called under spinlock.
 	 */
-	void (*invalidate_range)(struct mmu_notifier *mn,
+	void (*invalidate_range_begin)(struct mmu_notifier *mn,
 				 struct mm_struct *mm,
-				 unsigned long start, unsigned long end,
 				 int lock);
+
+	void (*invalidate_range_end)(struct mmu_notifier *mn,
+				 struct mm_struct *mm,
+				 unsigned long start, unsigned long end);
 };
 
 struct mmu_rmap_notifier_ops;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
