Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E88F8D003A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:43:19 -0500 (EST)
Subject: Re: [PATCH 00/17] mm: mmu_gather rework
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110217162327.434629380@chello.nl>
References: <20110217162327.434629380@chello.nl>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 17 Feb 2011 18:42:23 +0100
Message-ID: <1297964543.2413.2038.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, 2011-02-17 at 17:23 +0100, Peter Zijlstra wrote:
> s390 wants a bit more, but more on that in another email.

So what s390 wants is something like the below, where a fullmm gather
flushes a-priory and then simply gathers and frees the pages.

I can't see why something like this shouldn't work on x86 and power (the
only two archs I really looked in depth at), but it certainly is
something that needs a close look.

---
Index: linux-2.6/include/asm-generic/tlb.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/asm-generic/tlb.h
+++ linux-2.6/include/asm-generic/tlb.h
@@ -145,7 +145,10 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 	tlb->need_flush =3D 0;
 	if (num_online_cpus() =3D=3D 1)
 		tlb->fast_mode =3D 1;
+
 	tlb->fullmm =3D full_mm_flush;
+	if (tlb->fullmm)
+		tlb_flush(tlb);
=20
 	tlb->local.next =3D NULL;
 	tlb->local.nr   =3D 0;
@@ -162,13 +165,15 @@ tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
=20
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush =3D 0;
-	tlb_flush(tlb);
+	if (tlb->need_flush && !tlb->fullmm) {
+		tlb_flush(tlb);
+		tlb->need_flush =3D 0;
+	}
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
+
 	if (tlb_fast_mode(tlb))
 		return;
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
