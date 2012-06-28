Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id E8A676B007B
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:21:52 -0400 (EDT)
Message-ID: <1340900425.28750.73.camel@twins>
Subject: Re: [PATCH 08/20] mm: Optimize fullmm TLB flushing
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 28 Jun 2012 18:20:25 +0200
In-Reply-To: <20120628145327.GA17242@arm.com>
References: <20120627211540.459910855@chello.nl>
	 <20120627212831.137126018@chello.nl>
	 <CA+55aFwZoVK76ue7tFveV0XZpPUmoCVXJx8550OxPm+XKCSSZA@mail.gmail.com>
	 <1340838154.10063.86.camel@twins> <1340838807.10063.90.camel@twins>
	 <CA+55aFy6m967fMxyBsRoXVecdpGtSphXi_XdhwS0DB81Qaocdw@mail.gmail.com>
	 <CA+55aFzLNsVRkp_US8rAmygEkQpp1s1YdakV86Ck-4RZM7TTdA@mail.gmail.com>
	 <20120628091627.GB8573@arm.com> <1340879984.20977.80.camel@pasglop>
	 <1340881196.28750.16.camel@twins> <20120628145327.GA17242@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, "Nikunj A. Dadhania" <nikunj@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 2012-06-28 at 15:53 +0100, Catalin Marinas wrote:

> > Yes they do.. its just the up-front TLB invalidate for fullmm that's a
> > problem.
>=20
> The upfront invalidate is fine (i.e. harmless), it's the tlb_flush_mmu()
> change to check for !tlb->fullmm that's not helpful on ARM.

I think we're saying the same but differently. The point is that the
flush up front isn't sufficient for most of us.

Also, we'd very much want to avoid superfluous flushes since they are
somewhat expensive.

How horrid is something like the below. It detaches the mm so that
hardware speculation simply doesn't matter.

Now the switch_mm should imply the same cache+TBL flush we'd otherwise
do, and I'd think that that would be the majority of the cost. Am I
wrong there?

Also, the below seems to leak mm_structs so I did mess up the
ref-counting, its too bloody hot here.



---
 mm/memory.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 47 insertions(+), 4 deletions(-)
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -65,6 +65,7 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
+#include <asm/mmu_context.h>
=20
 #include "internal.h"
=20
@@ -197,6 +198,33 @@ static int tlb_next_batch(struct mmu_gat
 	return 1;
 }
=20
+/*
+ * Anonymize the task by detaching the mm and attaching it
+ * to the init_mm.
+ */
+static void detach_mm(struct mm_struct *mm, struct task_struct *tsk)
+{
+	/*
+	 * We should only be called when there's no users left and we're
+	 * destroying the mm.
+	 */
+	VM_BUG_ON(atomic_read(&mm->mm_users));
+	VM_BUG_ON(tsk->mm !=3D mm);
+	VM_BUG_ON(mm =3D=3D &init_mm);
+
+	task_lock(tsk);
+	tsk->mm =3D NULL;
+	tsk->active_mm =3D &init_mm;
+	switch_mm(mm, &init_mm, tsk);
+	/*
+	 * We have to take an extra ref on init_mm for TASK_DEAD in
+	 * finish_task_switch(), we don't drop our mm->mm_count reference
+	 * since mmput() will do this.
+	 */
+	atomic_inc(&init_mm.mm_count);
+	task_unlock(tsk);
+}
+
 /* tlb_gather_mmu
  *	Called to initialize an (on-stack) mmu_gather structure for page-table
  *	tear-down from @mm. The @fullmm argument is used when @mm is without
@@ -215,16 +243,31 @@ void tlb_gather_mmu(struct mmu_gather *t
 	tlb->active     =3D &tlb->local;
=20
 	tlb_table_init(tlb);
+
+	if (fullmm && current->mm =3D=3D mm) {
+		/*
+		 * Instead of doing:
+		 *
+		 *  flush_cache_mm(mm);
+		 *  flush_tlb_mm(mm);
+		 *
+		 * We switch to init_mm, this context switch should imply both
+		 * the cache and TLB flush as well as guarantee that hardware
+		 * speculation cannot load TLBs on this mm anymore.
+		 */
+		detach_mm(mm, current);
+	}
 }
=20
 void tlb_flush_mmu(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
=20
-	if (!tlb->need_flush)
-		return;
-	tlb->need_flush =3D 0;
-	flush_tlb_mm(tlb->mm);
+	if (!tlb->fullmm && tlb->need_flush) {
+		tlb->need_flush =3D 0;
+		flush_tlb_mm(tlb->mm);
+	}
+
 	tlb_table_flush(tlb);
=20
 	if (tlb_fast_mode(tlb))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
