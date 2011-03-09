Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id AD24A8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 10:49:20 -0500 (EST)
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1299685150.2308.3097.camel@twins>
References: <20110302175928.022902359@chello.nl>
	 <20110302180259.109909335@chello.nl>
	 <AANLkTimbRS++SCcKGrUcL5xKsCO+1ygkg+83x7F+2S4i@mail.gmail.com>
	 <1299683964.2308.3075.camel@twins>
	 <1299684963.19820.344.camel@e102109-lin.cambridge.arm.com>
	 <1299685150.2308.3097.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 09 Mar 2011 16:48:09 +0100
Message-ID: <1299685689.2308.3113.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 2011-03-09 at 16:39 +0100, Peter Zijlstra wrote:
>=20
> Ok, will try and sort that out.=20

We could do something like the below and use the end passed down, which
because it goes top down should be clipped at the appropriate size, just
means touching all the p??_free_tlb() implementations ;-)

Will do on the next iteration ;-)

---

diff --git a/mm/memory.c b/mm/memory.c
index 5823698..833bd90 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -222,11 +222,11 @@ void pmd_clear_bad(pmd_t *pmd)
  * has been handled earlier when unmapping all the memory regions.
  */
 static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
-			   unsigned long addr)
+			   unsigned long addr, unsigned long end)
 {
 	pgtable_t token =3D pmd_pgtable(*pmd);
 	pmd_clear(pmd);
-	pte_free_tlb(tlb, token, addr);
+	pte_free_tlb(tlb, token, addr, end);
 	tlb->mm->nr_ptes--;
 }
=20
@@ -244,7 +244,7 @@ static inline void free_pmd_range(struct mmu_gather *tl=
b, pud_t *pud,
 		next =3D pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		free_pte_range(tlb, pmd, addr);
+		free_pte_range(tlb, pmd, addr, next);
 	} while (pmd++, addr =3D next, addr !=3D end);
=20
 	start &=3D PUD_MASK;
@@ -260,7 +260,7 @@ static inline void free_pmd_range(struct mmu_gather *tl=
b, pud_t *pud,
=20
 	pmd =3D pmd_offset(pud, start);
 	pud_clear(pud);
-	pmd_free_tlb(tlb, pmd, start);
+	pmd_free_tlb(tlb, pmd, start, end);
 }
=20
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -293,7 +293,7 @@ static inline void free_pud_range(struct mmu_gather *tl=
b, pgd_t *pgd,
=20
 	pud =3D pud_offset(pgd, start);
 	pgd_clear(pgd);
-	pud_free_tlb(tlb, pud, start);
+	pud_free_tlb(tlb, pud, start, end);
 }
=20
 /*



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
