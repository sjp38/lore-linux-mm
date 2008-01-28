Date: Mon, 28 Jan 2008 14:06:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080128202923.609249585@sgi.com>
Message-ID: <Pine.LNX.4.64.0801281405250.13963@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.609249585@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

mmu core: Need to use hlist_del

Wrong type of list del in mmu_notifier_release()

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/mmu_notifier.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c	2008-01-28 14:02:18.000000000 -0800
+++ linux-2.6/mm/mmu_notifier.c	2008-01-28 14:02:30.000000000 -0800
@@ -23,7 +23,7 @@ void mmu_notifier_release(struct mm_stru
 					  &mm->mmu_notifier.head, hlist) {
 			if (mn->ops->release)
 				mn->ops->release(mn, mm);
-			hlist_del(&mn->hlist);
+			hlist_del_rcu(&mn->hlist);
 		}
 		rcu_read_unlock();
 		synchronize_rcu();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
