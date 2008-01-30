Date: Wed, 30 Jan 2008 11:28:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <1201713032.28547.234.camel@lappy>
Message-ID: <Pine.LNX.4.64.0801301125390.27491@schroedinger.engr.sgi.com>
References: <20080130022909.677301714@sgi.com>  <20080130022944.236370194@sgi.com>
  <20080130153749.GN7233@v2.random> <1201713032.28547.234.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

How about just taking the mmap_sem writelock in release? We have only a 
single caller of mmu_notifier_release() in mm/mmap.c and we know that we 
are not holding mmap_sem at that point. So just acquire it when needed?

Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c	2008-01-30 11:21:57.000000000 -0800
+++ linux-2.6/mm/mmu_notifier.c	2008-01-30 11:24:59.000000000 -0800
@@ -18,6 +19,7 @@ void mmu_notifier_release(struct mm_stru
 	struct hlist_node *n, *t;
 
 	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
+		down_write(&mm->mmap_sem);
 		rcu_read_lock();
 		hlist_for_each_entry_safe_rcu(mn, n, t,
 					  &mm->mmu_notifier.head, hlist) {
@@ -26,6 +28,7 @@ void mmu_notifier_release(struct mm_stru
 				mn->ops->release(mn, mm);
 		}
 		rcu_read_unlock();
+		up_write(&mm->mmap_sem);
 		synchronize_rcu();
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
