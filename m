Message-ID: <4183009D.9080708@yahoo.com.au>
Date: Sat, 30 Oct 2004 12:46:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <41822D75.3090802@yahoo.com.au> <20041029205255.GH12934@holomorphy.com>
In-Reply-To: <20041029205255.GH12934@holomorphy.com>
Content-Type: multipart/mixed;
 boundary="------------020109040203050801070301"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020109040203050801070301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

William Lee Irwin III wrote:
> On Fri, Oct 29, 2004 at 09:45:57PM +1000, Nick Piggin wrote:
> 
>>One more patch - this provides a generic framework for pte
>>locks, and a basic i386 reference implementation (which just
>>ifdefs out the cmpxchg version). Boots, runs, and has taken
>>some stressing.
>>I should have sorted this out before sending the patches for
>>RFC. The generic code actually did need a few lines of changes,
>>but not much as you can see. Needs some tidying up though, but
>>I only just wrote it in a few minutes.
>>And now before anyone gets a chance to shoot down the whole thing,
>>I just have to say
>>	"look ma, no page_table_lock!"
> 
> 
> The large major problem to address is making sure this works with
> arches. Without actually examining the arches this needs to be made to
> work with, it's not any kind of advance.
> 

Well it is because we've now got 3 synchronisation schemes that
arches can use. And I just demonstrated that all 3 (locked,
cmpxchg, pte-locked) work on i386.

So it is a long way off from saying N architectures _do_ work,
but the possibility is there.

> The only way to demonstrate that the generic API is any kind of
> progress toward that end is to sweep the arches and make them work.
> 
> So, the claim of "look ma, no page_table_lock" is meaningless, as no
> arches but x86(-64) have been examined, audited, etc. The most disturbing
> of these is the changing of the locking surrounding tlb_finish_mmu() et
> al. It's not valid to decouple the locking surrounding tlb_finish_mmu()
> from pagetable updates without teaching the architecture-specific code
> how to cope with this.
> 

i386 looks OK. I admit that this is an area I haven't looked deeply
into yet, but the synchronisation there is a bit soft anyway, because
you can have other threads scheduling onto other CPUs at any time,
and it has to be able to cope with that. All except sparc64 by the
looks, which takes the page table lock when context switching
(which is fairly interesting).

> It's also relatively sleazy to drop this in as an enhancement for just
> a few architectures (x86[-64], ia64, ppc64), and leave the others cold,
> but I won't press that issue so long as the remainder are functional,
> regardless of my own personal preferences.
> 

OK, it will work for all the arches that Christoph's works for, so
that's i386, x86-64, ia64, s390. We're _hoping_ that it will work
for ppc64 (and if I had a ppc64 I would have at least made some
attempts by now).

Seriously, what is other arch would want this? I'm not saying no
others could be done, but there is very little point IMO.

> What is unacceptable is the lack of research into the needs of arches
> that has been put into this. The general core changes proposed can
> never be adequate without a corresponding sweep of architecture-
> specific code. While I fully endorse the concept of lockless pagetable
> updates, there can be no correct implementation leaving architecture-
> specific code unswept. I would encourage whoever cares to pursue this
> to its logical conclusion to do the necessary reading, and audits, and
> review of architecture manuals instead of designing core API's in vacuums.
> 

Definitely - which is one of the reasons I posted it here, because I
don't pretend to know all the arch details. But if you think I designed
it in a vacuum you're wrong.

> I'm sorry if it sounds harsh, but I can't leave it unsaid. I've had to
> spend far too much time cleaning up after core changes carried out in
> similar obliviousness to the needs of architectures already, and it's
> furthermore unclear that I can even accomplish a recovery of a
> significant number of architectures from nonfunctionality in the face
> of an incorrect patch of this kind without backing it out entirely.
> Some of the burden of proof has to rest on he who makes the change;
> it's not even necessarily feasible to break arches with a patch of this
> kind and accomplish any kind of recovery of a significant number of them.
> 

Bill, I'm not suggesting this gets merged as is. Maybe the lack of
an [RFC] in the subject threw you off. _If_ it were to ever get
merged, it would be only after it was shown to work on all
architectures. And no, I'm really not asking you to do anything at
all; not even on sparc because that should work with basically zero
changes.

Something like this should get sparc64 working again.

--------------020109040203050801070301
Content-Type: text/x-patch;
 name="vm-sparc64-updates.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-sparc64-updates.patch"




---

 linux-2.6-npiggin/include/asm-sparc64/tlb.h |    6 +++++-
 linux-2.6-npiggin/kernel/fork.c             |    9 +++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff -puN include/asm-sparc64/mmu_context.h~vm-sparc64-updates include/asm-sparc64/mmu_context.h
diff -puN include/asm-sparc64/tlb.h~vm-sparc64-updates include/asm-sparc64/tlb.h
--- linux-2.6/include/asm-sparc64/tlb.h~vm-sparc64-updates	2004-10-30 12:29:49.000000000 +1000
+++ linux-2.6-npiggin/include/asm-sparc64/tlb.h	2004-10-30 12:30:46.000000000 +1000
@@ -44,7 +44,10 @@ extern void flush_tlb_pending(void);
 
 static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
 {
-	struct mmu_gather *mp = &per_cpu(mmu_gathers, smp_processor_id());
+	struct mmu_gather *mp;
+	
+	spin_lock(&mm->page_table_lock);
+	mp = &per_cpu(mmu_gathers, smp_processor_id());
 
 	BUG_ON(mp->tlb_nr);
 
@@ -99,6 +102,7 @@ static inline void tlb_finish_mmu(struct
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
+	spin_unlock(&mm->page_table_lock);
 }
 
 static inline unsigned int tlb_is_full_mm(struct mmu_gather *mp)
diff -puN kernel/fork.c~vm-sparc64-updates kernel/fork.c
--- linux-2.6/kernel/fork.c~vm-sparc64-updates	2004-10-30 12:31:11.000000000 +1000
+++ linux-2.6-npiggin/kernel/fork.c	2004-10-30 12:34:12.000000000 +1000
@@ -447,11 +447,12 @@ static int copy_mm(unsigned long clone_f
 		 */
 		/*
 		 * XXX: I think this is only needed for sparc64's tlb and
-		 * context switching code - but sparc64 is in big trouble
-		 * now anyway because tlb_gather_mmu can be done without
-		 * holding the page table lock now anyway.
+		 * context switching code - this should actually be an arch
+		 * specific hook, but I'll just hack it for now. I'd rather
+		 * it not to use the page table lock at all, but DaveM would
+		 * probably think otherwise.
 		 */
-#if 0
+#ifdef CONFIG_SPARC64
 		spin_unlock_wait(&oldmm->page_table_lock);
 #endif
 		goto good_mm;

_

--------------020109040203050801070301--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
