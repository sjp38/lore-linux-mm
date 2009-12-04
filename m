Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DD1C46007BA
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 03:45:45 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB48jhqM007872
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 17:45:43 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF8A145DE60
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:45:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BC2245DE4D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:45:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 649A01DB8049
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:45:42 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E51E01DB8040
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 17:45:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 6/7] wipe_page_reference return SWAP_AGAIN if VM pressulre is low and lock contention is detected.
In-Reply-To: <20091204173233.5891.A69D9226@jp.fujitsu.com>
References: <20091204173233.5891.A69D9226@jp.fujitsu.com>
Message-Id: <20091204174439.58A3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Fri,  4 Dec 2009 17:45:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

=46rom 3fb2a585729a37e205c5ea42ac6c48d4a6c0a29c Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 4 Dec 2009 12:54:37 +0900
Subject: [PATCH 6/7] wipe_page_reference return SWAP_AGAIN if VM pressulre =
is low and lock contention is detected.

Larry Woodman reported AIM7 makes serious ptelock and anon_vma_lock
contention on current VM. because SplitLRU VM (since 2.6.28) remove
calc_reclaim_mapped() test, then shrink_active_list() always call
page_referenced() against mapped page although VM pressure is low.
Lightweight VM pressure is very common situation and it easily makes
ptelock contention with page fault. then, anon_vma_lock is holding
long time and it makes another lock contention. then, fork/exit
throughput decrease a lot.

	While running workloads that do lots of forking processes, exiting
	processes and page reclamation(AIM 7) on large systems very high system
	time(100%) and lots of lock contention was observed.

	CPU5:
	 [<ffffffff814afb48>] ? _spin_lock+0x27/0x48
	 [<ffffffff81101deb>] ? anon_vma_link+0x2a/0x5a
	 [<ffffffff8105d3d8>] ? dup_mm+0x242/0x40c
	 [<ffffffff8105e0a9>] ? copy_process+0xab1/0x12be
	 [<ffffffff8105ea07>] ? do_fork+0x151/0x330
	 [<ffffffff81058407>] ? default_wake_function+0x0/0x36
	 [<ffffffff814b0243>] ? _spin_lock_irqsave+0x2f/0x68
	 [<ffffffff810121d3>] ? stub_clone+0x13/0x20
	 [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b

	CPU4:
	 [<ffffffff814afb4a>] ? _spin_lock+0x29/0x48
	 [<ffffffff81103062>] ? anon_vma_unlink+0x2a/0x84
	 [<ffffffff810fbab7>] ? free_pgtables+0x3c/0xe1
	 [<ffffffff810fd8b1>] ? exit_mmap+0xc5/0x110
	 [<ffffffff8105ce4c>] ? mmput+0x55/0xd9
	 [<ffffffff81061afd>] ? exit_mm+0x109/0x129
	 [<ffffffff81063846>] ? do_exit+0x1d7/0x712
	 [<ffffffff814b0243>] ? _spin_lock_irqsave+0x2f/0x68
	 [<ffffffff81063e07>] ? do_group_exit+0x86/0xb2
	 [<ffffffff81063e55>] ? sys_exit_group+0x22/0x3e
	 [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b

	CPU0:
	 [<ffffffff814afb4a>] ? _spin_lock+0x29/0x48
	 [<ffffffff81101ad1>] ? page_check_address+0x9e/0x16f
	 [<ffffffff81101cb8>] ? page_referenced_one+0x53/0x10b
	 [<ffffffff81102f5a>] ? page_referenced+0xcd/0x167
	 [<ffffffff810eb32d>] ? shrink_active_list+0x1ed/0x2a3
	 [<ffffffff810ebde9>] ? shrink_zone+0xa06/0xa38
	 [<ffffffff8108440a>] ? getnstimeofday+0x64/0xce
	 [<ffffffff810ecaf9>] ? do_try_to_free_pages+0x1e5/0x362
	 [<ffffffff810ecd9f>] ? try_to_free_pages+0x7a/0x94
	 [<ffffffff810ea66f>] ? isolate_pages_global+0x0/0x242
	 [<ffffffff810e57b9>] ? __alloc_pages_nodemask+0x397/0x572
	 [<ffffffff810e3c1e>] ? __get_free_pages+0x19/0x6e
	 [<ffffffff8105d6c9>] ? copy_process+0xd1/0x12be
	 [<ffffffff81204eb2>] ? avc_has_perm+0x5c/0x84
	 [<ffffffff81130db8>] ? user_path_at+0x65/0xa3
	 [<ffffffff8105ea07>] ? do_fork+0x151/0x330
	 [<ffffffff810b7935>] ? check_for_new_grace_period+0x78/0xab
	 [<ffffffff810121d3>] ? stub_clone+0x13/0x20
	 [<ffffffff81011e02>] ? system_call_fastpath+0x16/0x1b

	--------------------------------------------------------------------------=
----
	   PerfTop:     864 irqs/sec  kernel:99.7% [100000 cycles],  (all, 8 CPUs)
	--------------------------------------------------------------------------=
----

	             samples    pcnt         RIP          kernel function
	  ______     _______   _____   ________________   _______________

	             3235.00 - 75.1% - ffffffff814afb21 : _spin_lock
	              670.00 - 15.6% - ffffffff81101a33 : page_check_address
	              165.00 -  3.8% - ffffffffa01cbc39 : rpc_sleep_on  [sunrpc]
	               40.00 -  0.9% - ffffffff81102113 : try_to_unmap_one
	               29.00 -  0.7% - ffffffff81101c65 : page_referenced_one
	               27.00 -  0.6% - ffffffff81101964 : vma_address
	                8.00 -  0.2% - ffffffff8125a5a0 : clear_page_c
	                6.00 -  0.1% - ffffffff8125a5f0 : copy_page_c
	                6.00 -  0.1% - ffffffff811023ca : try_to_unmap_anon
	                5.00 -  0.1% - ffffffff810fb014 : copy_page_range
	                5.00 -  0.1% - ffffffff810e4d18 : get_page_from_freelist

Then, We use trylock for avoiding ptelock contention if VM pressure is
low.

Reported-by: Larry Woodman <lwoodman@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/rmap.h |    4 ++++
 mm/rmap.c            |   16 ++++++++++++----
 mm/vmscan.c          |    1 +
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 564d981..499972e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -110,6 +110,10 @@ static inline void page_dup_rmap(struct page *page)
=20
 struct page_reference_context {
 	int is_page_locked;
+
+	/* if 1, we might give up to wipe when find lock contention. */
+	int soft_try;
+
 	unsigned long referenced;
 	unsigned long exec_referenced;
 	int maybe_mlocked;	/* found VM_LOCKED, but it's unstable result */
diff --git a/mm/rmap.c b/mm/rmap.c
index b84f350..5ae7c81 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -373,6 +373,9 @@ int page_mapped_in_vma(struct page *page, struct vm_are=
a_struct *vma)
 /*
  * Subfunctions of wipe_page_reference: wipe_page_reference_one called
  * repeatedly from either wipe_page_reference_anon or wipe_page_reference_=
file.
+ *
+ * SWAP_SUCCESS  - success
+ * SWAP_AGAIN    - give up to take lock, try later again
  */
 int wipe_page_reference_one(struct page *page,
 			    struct page_reference_context *refctx,
@@ -381,6 +384,7 @@ int wipe_page_reference_one(struct page *page,
 	struct mm_struct *mm =3D vma->vm_mm;
 	pte_t *pte;
 	spinlock_t *ptl;
+	int ret =3D SWAP_SUCCESS;
=20
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
@@ -392,10 +396,14 @@ int wipe_page_reference_one(struct page *page,
 		goto out;
 	}
=20
-	pte =3D page_check_address(page, mm, address, &ptl, 0);
-	if (!pte)
+	pte =3D __page_check_address(page, mm, address, &ptl, 0,
+				   refctx->soft_try);
+	if (IS_ERR(pte)) {
+		if (PTR_ERR(pte) =3D=3D -EAGAIN) {
+			ret =3D SWAP_AGAIN;
+		}
 		goto out;
-
+	}
 	if (ptep_clear_flush_young_notify(vma, address, pte)) {
 		/*
 		 * Don't treat a reference through a sequentially read
@@ -421,7 +429,7 @@ int wipe_page_reference_one(struct page *page,
 	pte_unmap_unlock(pte, ptl);
=20
 out:
-	return SWAP_SUCCESS;
+	return ret;
 }
=20
 static int wipe_page_reference_anon(struct page *page,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9684e40..16e8bd0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1334,6 +1334,7 @@ static void shrink_active_list(unsigned long nr_pages=
, struct zone *zone,
 		int ret;
 		struct page_reference_context refctx =3D {
 			.is_page_locked =3D 0,
+			.soft_try =3D (priority < DEF_PRIORITY - 2) ? 0 : 1,
 		};
=20
 		cond_resched();
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
