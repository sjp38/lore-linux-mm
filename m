Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 763869000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 09:59:18 -0400 (EDT)
Date: Fri, 30 Sep 2011 15:58:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #6
Message-ID: <20110930135858.GN7768@redhat.com>
References: <20110826062436.GA5847@google.com>
 <20110826161048.GE23870@redhat.com>
 <20110826185430.GA2854@redhat.com>
 <20110827094152.GA16402@google.com>
 <20110827173421.GA2967@redhat.com>
 <CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
 <20110901152417.GF10779@redhat.com>
 <20110901170353.6f92b50f.akpm@linux-foundation.org>
 <20110908165118.GC24539@redhat.com>
 <1316793432.9084.47.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1316793432.9084.47.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi everyone,

On Fri, Sep 23, 2011 at 05:57:12PM +0200, Peter Zijlstra wrote:
> On Thu, 2011-09-08 at 18:51 +0200, Andrea Arcangeli wrote:
> 
> > +++ b/arch/powerpc/mm/gup.c
> > +++ b/arch/x86/mm/gup.c
> 
> lacking a diffstat a quick look seems to suggest you missed a few:
> 
> $ ls arch/*/mm/gup.c
> arch/powerpc/mm/gup.c  
> arch/s390/mm/gup.c  
> arch/sh/mm/gup.c  
> arch/sparc/mm/gup.c  
> arch/x86/mm/gup.c

sh should be already ok, sparc too as they don't seem to support
hugetlbfs or THP. s390 32bit probably too. sh actually has some
HUGETLB optional thing but I don't see it handling it in gup...

But I think I missed s39064bit! But after a closer look surprisingly
they weren't ok before this change too! Even ppc.

In fact they will work better with this change applied because
succeeding a page_cache_get_speculative on a TailPage (like it could
have happened before) would have resulted in a VM_BUG_ON before
returning from page_cache_get_speculative. I guess not many are
testing O_DIRECT on hugetlbfs on ppc64,s39064bit. The PageTail check
in powerpc/mm/gup.c suddenly looks like a noop. Weird.

Also while doing this I found longstanding bugs in powerpc. nr
includes also pages found before calling gup_hugepte. So if that race
triggers (mremap,munmap changing the huge pagetable under gup_fast,
which can definitely happen) it'd lead to put_page being called too
many times on the hugetlbfs page.

Also in the below code probably they intended to use "head", not
"page".... "page" is out of bounds... so the rollback in the race case
was going to free a random page even in older kernels.

       if (unlikely(pte_val(pte) != pte_val(*ptep))) {
               /* Could be optimized better */
               while (*nr) {
                       put_page(page);

But I'm not sure why ppc always checks if the pte changed and tries to
rollback. There's no need of that, if gup_fast could run it means
we're not within a mmu_notifier_invalidate_range_start/end critical
section, and mmu_notifier_invalidate_page won't run until after the
tlb flush returned (so after gup_fast returned on the other cpu), and
so the pages are guaranteed to always have page_count >= 0
(munmap/mremap will stop and wait in
mmu_notifier_invalidate_range_start or in mmu_notifier_invalidate_page
where the IPI delivery will wait before releasing the page count, to
flush any secondary mapping before the primary mapping is allowed to
free the page).

In short there are two fishy things in ppc code (in addition to the
race-rollback corrupting memory which is just a minor implementation
bug trivial to correct, besides after THP we've to put_page the right
subpage not just the head so it must be refactored anyway):

1) page_cache_get/add_speculative is not needed anywhere in gup_fast
path of ppc as long as irqs are disabled (it simulates the cpu doing a tlb
miss). Special care has to be taken so you read the ptep to a local
variable (stored in cpu register or kernel stack), and then you
evaluate the local pte_t (stopping reading from the pointer). Then you
do pte_page on the _local_ pte_t variable, and you know you can
get_page without doing any get_page_unless_zero (plus there's a
VM_BUG_ON in get_page to verify we're not running get_page on a page
with a zero count).

Hmmm explanation of point 1) above self-remind that maybe even x86
should always use ACCESS_ONCE, even for the pmds (it already does for
the pte, either that or it has a smp_rmb() after finish reading it),
(probably not required for upper layers as they can't be tear down
until the IPI runs), now there's no way gcc is stupid enough to
re-read from pointer but in theory it could without barrier(). This
isn't just for THP but for hugetlbfs too, it's only theoretical though.

2) the above pte_val(local_pte_t) != pte(*ptep) checks in theory as
useless for ppc, as long as you verify the pte is ok (so you arrived
reading before mremap/munmap changed the pte), the page can't go away
under you because the tlb flush will wait.

I didn't start yet checking s390 in detail but it looks close to ppc
code. Let's sort out ppc first.

Now I'd like to know if the soft tlb miss handler of powerpc changes
something and really requires the code commented point 1) and 2) (even
if that code and race checks are not required on x86 for the reason I
just mentioned...).

I can make a patch to try to keep these page_cache_get/add_speculative
and the pte_val(local_pte_t) != pte(*ptep) checks intact (they're
superfluous but they can't hurt obviously). So I could make a patch
that works with current code, but if I could safely delete those I'd
prefer as they're quite confusing on why they're needed. But before I
do that I need ack from ppc people to be sure it's ok.. I don't know
the assembly of the tlb miss hashtable handler to be sure... I don't
exclude ppc has different ipi/irq semantics for the gup_fast case and
really requires those checks.

CC'ed Benjamin :)

Comments welcome!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
