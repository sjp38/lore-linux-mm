Date: Thu, 5 Jun 2008 18:44:21 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 2 of 3] mm_take_all_locks
Message-ID: <20080605164421.GG15502@duo.random>
References: <082f312bc6821733b1c3.1212680169@duo.random> <alpine.LFD.1.10.0806050913060.3473@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0806050913060.3473@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 05, 2008 at 09:15:41AM -0700, Linus Torvalds wrote:
> 
> Just a small comment fix.
> 
> On Thu, 5 Jun 2008, Andrea Arcangeli wrote:
> > +		/*
> > +		 * AS_MM_ALL_LOCKS can't change from under us because
> > +		 * we hold the global_mm_spinlock.
> 
> There's no global_mm_spinlock, you mean the 'mm_all_locks_mutex'.
> 
> (There was at least one other case where you had that comment issue).

From: Andrea Arcangeli <andrea@qumranet.com>

Indeed, I meant mm_all_locks_mutex, this will fix it, or if you prefer
a resubmit of the 2/3 let me know. Thanks!

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
---

diff -r 082f312bc682 mm/mmap.c
--- a/mm/mmap.c	Thu Jun 05 17:30:17 2008 +0200
+++ b/mm/mmap.c	Thu Jun 05 18:40:23 2008 +0200
@@ -2263,7 +2263,7 @@ static void vm_lock_anon_vma(struct anon
 	if (!test_bit(0, (unsigned long *) &anon_vma->head.next)) {
 		/*
 		 * The LSB of head.next can't change from under us
-		 * because we hold the global_mm_spinlock.
+		 * because we hold the mm_all_locks_mutex.
 		 */
 		spin_lock(&anon_vma->lock);
 		/*
@@ -2286,11 +2286,11 @@ static void vm_lock_mapping(struct addre
 	if (!test_bit(AS_MM_ALL_LOCKS, &mapping->flags)) {
 		/*
 		 * AS_MM_ALL_LOCKS can't change from under us because
-		 * we hold the global_mm_spinlock.
+		 * we hold the mm_all_locks_mutex.
 		 *
 		 * Operations on ->flags have to be atomic because
 		 * even if AS_MM_ALL_LOCKS is stable thanks to the
-		 * global_mm_spinlock, there may be other cpus
+		 * mm_all_locks_mutex, there may be other cpus
 		 * changing other bitflags in parallel to us.
 		 */
 		if (test_and_set_bit(AS_MM_ALL_LOCKS, &mapping->flags))
@@ -2362,7 +2362,7 @@ static void vm_unlock_anon_vma(struct an
 	if (test_bit(0, (unsigned long *) &anon_vma->head.next)) {
 		/*
 		 * The LSB of head.next can't change to 0 from under
-		 * us because we hold the global_mm_spinlock.
+		 * us because we hold the mm_all_locks_mutex.
 		 *
 		 * We must however clear the bitflag before unlocking
 		 * the vma so the users using the anon_vma->head will
@@ -2384,7 +2384,7 @@ static void vm_unlock_mapping(struct add
 	if (test_bit(AS_MM_ALL_LOCKS, &mapping->flags)) {
 		/*
 		 * AS_MM_ALL_LOCKS can't change to 0 from under us
-		 * because we hold the global_mm_spinlock.
+		 * because we hold the mm_all_locks_mutex.
 		 */
 		spin_unlock(&mapping->i_mmap_lock);
 		if (!test_and_clear_bit(AS_MM_ALL_LOCKS,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
