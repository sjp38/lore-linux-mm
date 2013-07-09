Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 2D18C6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 11:34:30 -0400 (EDT)
Date: Tue, 9 Jul 2013 17:28:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust()
	interaction
Message-ID: <20130709152836.GA10033@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com> <20130708180424.GA6490@redhat.com> <20130708180501.GB6490@redhat.com> <CAHGf_=qPuzH_R1Jfztnhj4JEAX9xfD37461LRKrhHgL4nq-eHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=qPuzH_R1Jfztnhj4JEAX9xfD37461LRKrhHgL4nq-eHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Colin Cross <ccross@android.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/08, KOSAKI Motohiro wrote:
>
> On Mon, Jul 8, 2013 at 2:05 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> > vma_adjust() does vma_set_policy(vma, vma_policy(next)) and this
> > is doubly wrong:
> >
> > 1. This leaks vma->vm_policy if it is not NULL and not equal to
> >    next->vm_policy.
> >
> >    This can happen if vma_merge() expands "area", not prev (case 8).
> >
> > 2. This sets the wrong policy if vma_merge() joins prev and area,
> >    area is the vma the caller needs to update and it still has the
> >    old policy.
> >
> > Revert 1444f92c "mm: merging memory blocks resets mempolicy" which
> > introduced these problems.
>
> Yes, I believe 1444f92c is wrong and should be reverted.

Yes, but the problem it tried to solve is real, just we can't rely
on vma_adjust().

> > Change mbind_range() to recheck mpol_equal() after vma_merge() to
> > fix the problem 1444f92c tried to address.
> >
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > Cc: <stable@vger.kernel.org>
> > ---
> >  mm/mempolicy.c |    6 +++++-
> >  mm/mmap.c      |    2 +-
> >  2 files changed, 6 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 7431001..4baf12e 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -732,7 +732,10 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
> >                 if (prev) {
> >                         vma = prev;
> >                         next = vma->vm_next;
> > -                       continue;
> > +                       if (mpol_equal(vma_policy(vma), new_pol))
> > +                               continue;
> > +                       /* vma_merge() joined vma && vma->next, case 8 */
>
> case 3 makes the same scenario?

Not really, afaics. "case 3" is when vma_merge() "merges" a hole with
vma, mbind_range() works with the already mmapped regions.

More precisely, unless I misread this code, "case 3" means area == next,
so vma_adjust(area) actually sets next->vm_start = addr.

I can be easily wrong, but to me vma_adjust() and its usage looks a bit
overcomplicated. Perhaps it makes sense to distinguish mmapped/hole cases.
mbind_range/madvise/etc need vma_join(vma, ...), not prev/anon_vma/file.
Perhaps. not sure.

> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks!

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
