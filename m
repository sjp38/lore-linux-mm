Date: Mon, 28 Jan 2008 17:19:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080129000534.GT3058@sgi.com>
Message-ID: <Pine.LNX.4.64.0801281718160.19533@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com>
 <20080129000534.GT3058@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008, Robin Holt wrote:

> USE_AFTER_FREE!!!  I made this same comment as well as other relavent
> comments last week.

Must have slipped somehow. Patch needs to be applied after the rcu fix.

Please repeat the other relevant comments if they are still relevant.... I 
thought I had worked through them.



mmu_notifier_release: remove mmu_notifier struct from list before calling ->release

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/mmu_notifier.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c	2008-01-28 17:17:05.000000000 -0800
+++ linux-2.6/mm/mmu_notifier.c	2008-01-28 17:17:10.000000000 -0800
@@ -21,9 +21,9 @@ void mmu_notifier_release(struct mm_stru
 		rcu_read_lock();
 		hlist_for_each_entry_safe_rcu(mn, n, t,
 					  &mm->mmu_notifier.head, hlist) {
+			hlist_del_rcu(&mn->hlist);
 			if (mn->ops->release)
 				mn->ops->release(mn, mm);
-			hlist_del_rcu(&mn->hlist);
 		}
 		rcu_read_unlock();
 		synchronize_rcu();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
