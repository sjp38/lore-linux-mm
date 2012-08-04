Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 73D1C6B0044
	for <linux-mm@kvack.org>; Sat,  4 Aug 2012 10:38:36 -0400 (EDT)
Date: Sat, 4 Aug 2012 16:37:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120804143719.GB10459@redhat.com>
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 24, 2012 at 02:51:05PM -0700, Hugh Dickins wrote:
> Since then, I think THP has made the rules more complicated; but I
> believe Andrea paid a great deal of attention to that kind of issue.

There were many issues, one unexpected was
1a5a9906d4e8d1976b701f889d8f35d54b928f25.

Keep in mind when holding only mmap_sem read mode (walk page range
speculative mode) or gup_fast, the result is always undefined and
racey if on the other CPU you have a munmap or mremap or any other pmd
manging concurrently messing with the mapping you're walking, all we
have to do is not to crash, it doesn't matter what happens.

The fact you need a barrier() or ACCESS_ONCE to avoid a lockup in a
while (rcu_dereference()), is no good reason to worry about all
possible purely theoretical gcc issues.

One important thing that wasn't mentioned so far in this thread is
also that we entirely relay on gcc for all pagetable and device driver
writes (to do 1 movq instead of 8 movb), see native_set_pmd and writel.

We must separate all different cases to avoid huge confusion:

1) tmp=*ptr, while(tmp) -> possible, needs barrier or better
   ACCESS_ONCE if possible

2) orig_pmd = *pmdp before do_wp_huge_page in memory.c -> possible, needs
   barrier() and it should be possible to convert to ACCESS_ONCE

3) native_set_pmd and friends -> possible but not worth fixing, tried
   to fix a decade ago for a peace of mind and I was suggested to
   desist and it didn't bite us yet

4) writel -> possible but same as 3

5) compiler behaving like alpha -> impossible (I may be wrong but I
   believe so after thinking more on it)

6) I was told a decade ago by Honza to never touch any ram that can
   change under the compiler unless it's declared volatile (could
   crash over switch/case statement implemented with a table if the
   switch/case value is re-read by the compiler).  -> depends, we
   don't always obey to this rule, clearly gup_fast currently disobeys
   and even the generic pmd_read_atomic still disobeys (MADV_DONTNEED
   can zero the pmd). If there's no "switch/case" I'm not aware of
   other troubles.

7) barrier in pmd_none_or_trans_huge_or_clear_bad -> possible, same
   issue as 2, full explanation in git show 1a5a9906d4e8d1976b701f

Note: here I'm ignoring CPU reordering, this is only about the compiler.

5 is impossible because:

a) the compiler can't read a guessed address or it can crash the
   kernel

b) the compiler has no memory to store a "guessed" valid address when
   the function return and the stack is unwind

For the compiler to behave like alpha, the compiler should read the
pteval before the pmdp, that it can't do, because it has no address to
guess from and it would Oops if it really tries to guess it!

So far it was said "compiler can guess the address" but there was no
valid explanation of how it could do it, and I don't see it, so please
explain if I'm wrong about the a, b above.

Furthermore the ACCESS_ONCE that Peter's patch added to gup_fast
pud/pgd can't prevent the compiler to read a guessed pmdp address as a
volatile variable, before reading the pmdp pointer and compare it with
the guessed address! So if it's 5 you worry about, when adding
ACCESS_ONCE in pudp/pgdp/pmdp is useless and won't fix it. You should
have added a barrier() instead.

> I suspect your arch/x86/mm/gup.c ACCESS_ONCE()s are necessary:
> gup_fast() breaks as many rules as it can, and in particular may
> be racing with the freeing of page tables; but I'm not so sure
> about the pagewalk mods - we could say "cannot do any harm",
> but I don't like adding lines on that basis.

I agree to add ACCESS_ONCE but because it's case 2, 7 above and it
could race with free_pgtables of pgd/pud/pmd or MADV_DONTNEED with
pmd.

The other part of the patch in pagewalk.c is superflous and should be
dropped: pud/pgd can't change in walk_page_table, it's required to
hold the mmap_sem at least in read mode (it's not disabling irqs).

The pmd side instead can change but only with THP enabled, and only
because MADV_DONTNEED (never because of free_pgtables) but it's
already fully handled through pmd_none_or_trans_huge_or_clear_bad. The
->pmd_entry callers are required to call pmd_trans_unstable() before
proceeding as the pmd may have been zeroed out by the time we get
there. The solution is zero barrier()/ACCESS_ONCE impact for THP=n. If
there are smp_read_barrier_depends already in alpha pte methods we're
fine.

Sorry for the long email but without a list that separates all
possible cases above, I don't think we can understand what we're
fixing in that patch and why the gup.c part is good.

Peter, I suggest to resend the fix with a more detailed explanataion
of the 2, 7 kind of race for gup.c only and drop the pagewalk.c.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
