Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12D316B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 08:39:56 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k190so39789425qkc.19
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 05:39:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u24si411358qtc.2.2017.03.27.05.39.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 05:39:55 -0700 (PDT)
Date: Mon, 27 Mar 2017 14:39:47 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170327143947.4c237e54@redhat.com>
In-Reply-To: <20170327105514.1ed5b1ba@redhat.com>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
	<d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
	<83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
	<20170322234004.kffsce4owewgpqnm@techsingularity.net>
	<20170323144347.1e6f29de@redhat.com>
	<20170323145133.twzt4f5ci26vdyut@techsingularity.net>
	<779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
	<1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
	<2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
	<20170327105514.1ed5b1ba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, brouer@redhat.com

On Mon, 27 Mar 2017 10:55:14 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> A possible solution, would be use the local_bh_{disable,enable} instead
> of the {preempt_disable,enable} calls.  But it is slower, using numbers
> from [1] (19 vs 11 cycles), thus the expected cycles saving is 38-19=3D19.
>=20
> The problematic part of using local_bh_enable is that this adds a
> softirq/bottom-halves rescheduling point (as it checks for pending
> BHs).  Thus, this might affects real workloads.

I implemented this solution in patch below... and tested it on mlx5 at
50G with manually disabled driver-page-recycling.  It works for me.

To Mel, that do you prefer... a partial-revert or something like this?


[PATCH] mm, page_alloc: re-enable softirq use of per-cpu page allocator

From: Jesper Dangaard Brouer <brouer@redhat.com>

IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists
caching of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only
use per-cpu allocator for irq-safe requests").

This unfortunately also included excluded SoftIRQ.  This hurt the
performance for the use-case of refilling DMA RX rings in softirq
context.

This patch re-allow softirq context, which should be safe by disabling
BH/softirq, while accessing the list.  And makes sure to avoid
PCP-lists access from both hard-IRQ and NMI context.

One concern with this change is adding a BH (enable) scheduling point
at both PCP alloc and free.

Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-sa=
fe requests")
---
 include/trace/events/kmem.h |    2 ++
 mm/page_alloc.c             |   41 ++++++++++++++++++++++++++++++++++-----=
--
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 6b2e154fd23a..ad412ad1b092 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -244,6 +244,8 @@ DECLARE_EVENT_CLASS(mm_page,
 		__entry->order,
 		__entry->migratetype,
 		__entry->order =3D=3D 0)
+// WARNING: percpu_refill check not 100% correct after commit
+// 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe =
requests")
 );
=20
 DEFINE_EVENT(mm_page, mm_page_alloc_zone_locked,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6cbde310abed..db9ffc8ac538 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2470,6 +2470,25 @@ void mark_free_pages(struct zone *zone)
 }
 #endif /* CONFIG_PM */
=20
+static __always_inline int in_irq_or_nmi(void)
+{
+	return in_irq() || in_nmi();
+// XXX: hoping compiler will optimize this (todo verify) into:
+// #define in_irq_or_nmi()	(preempt_count() & (HARDIRQ_MASK | NMI_MASK))
+
+	/* compiler was smart enough to only read __preempt_count once
+	 * but added two branches
+asm code:
+ =E2=94=82       mov    __preempt_count,%eax
+ =E2=94=82       test   $0xf0000,%eax    // HARDIRQ_MASK: 0x000f0000
+ =E2=94=82    =E2=94=8C=E2=94=80=E2=94=80jne    2a
+ =E2=94=82    =E2=94=82  test   $0x100000,%eax   // NMI_MASK:     0x001000=
00
+ =E2=94=82    =E2=94=82=E2=86=93 je     3f
+ =E2=94=82 2a:=E2=94=94=E2=94=80=E2=86=92mov    %rbx,%rdi
+
+	 */
+}
+
 /*
  * Free a 0-order page
  * cold =3D=3D true ? free a cold page : free a hot page
@@ -2481,7 +2500,11 @@ void free_hot_cold_page(struct page *page, bool cold)
 	unsigned long pfn =3D page_to_pfn(page);
 	int migratetype;
=20
-	if (in_interrupt()) {
+	/*
+	 * Exclude (hard) IRQ and NMI context from using the pcplists.
+	 * But allow softirq context, via disabling BH.
+	 */
+	if (in_irq_or_nmi()) {
 		__free_pages_ok(page, 0);
 		return;
 	}
@@ -2491,7 +2514,7 @@ void free_hot_cold_page(struct page *page, bool cold)
=20
 	migratetype =3D get_pfnblock_migratetype(page, pfn);
 	set_pcppage_migratetype(page, migratetype);
-	preempt_disable();
+	local_bh_disable();
=20
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
@@ -2522,7 +2545,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
=20
 out:
-	preempt_enable();
+	local_bh_enable();
 }
=20
 /*
@@ -2647,7 +2670,7 @@ static struct page *__rmqueue_pcplist(struct zone *zo=
ne, int migratetype,
 {
 	struct page *page;
=20
-	VM_BUG_ON(in_interrupt());
+	VM_BUG_ON(in_irq());
=20
 	do {
 		if (list_empty(list)) {
@@ -2680,7 +2703,7 @@ static struct page *rmqueue_pcplist(struct zone *pref=
erred_zone,
 	bool cold =3D ((gfp_flags & __GFP_COLD) !=3D 0);
 	struct page *page;
=20
-	preempt_disable();
+	local_bh_disable();
 	pcp =3D &this_cpu_ptr(zone->pageset)->pcp;
 	list =3D &pcp->lists[migratetype];
 	page =3D __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
@@ -2688,7 +2711,7 @@ static struct page *rmqueue_pcplist(struct zone *pref=
erred_zone,
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 		zone_statistics(preferred_zone, zone);
 	}
-	preempt_enable();
+	local_bh_enable();
 	return page;
 }
=20
@@ -2704,7 +2727,11 @@ struct page *rmqueue(struct zone *preferred_zone,
 	unsigned long flags;
 	struct page *page;
=20
-	if (likely(order =3D=3D 0) && !in_interrupt()) {
+	/*
+	 * Exclude (hard) IRQ and NMI context from using the pcplists.
+	 * But allow softirq context, via disabling BH.
+	 */
+	if (likely(order =3D=3D 0) && !in_irq_or_nmi() ) {
 		page =3D rmqueue_pcplist(preferred_zone, zone, order,
 				gfp_flags, migratetype);
 		goto out;


--=20
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
