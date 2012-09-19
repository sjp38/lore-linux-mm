Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A936E6B002B
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 16:38:30 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3651243pbb.14
        for <linux-mm@kvack.org>; Wed, 19 Sep 2012 13:38:30 -0700 (PDT)
Date: Thu, 20 Sep 2012 05:38:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix NR_ISOLATED_[ANON|FILE] mismatch
Message-ID: <20120919203821.GB2425@barrios>
References: <1348040735-3897-1-git-send-email-minchan@kernel.org>
 <CAHGf_=rY-1R+68BWqW4653r_=AYkgE1CfM7wvSyvdSXRwjraUA@mail.gmail.com>
 <20120919182810.GB1569@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120919182810.GB1569@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>

Hi Hannes,

On Wed, Sep 19, 2012 at 02:28:10PM -0400, Johannes Weiner wrote:
> On Wed, Sep 19, 2012 at 01:04:56PM -0400, KOSAKI Motohiro wrote:
> > On Wed, Sep 19, 2012 at 3:45 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > When I looked at zone stat mismatch problem, I found
> > > migrate_to_node doesn't decrease NR_ISOLATED_[ANON|FILE]
> > > if check_range fails.
> 
> This is a bit misleading.  It's not that the stats would be
> inaccurate, it's that the pages would be leaked from the LRU, no?
> 
> > > It can make system hang out.
> 
> Did you spot this by code review only or did you actually run into
> this?  Because...

Just by code review during the bug of memory-hotplug.

> 
> > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: Christoph Lameter <cl@linux.com>
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/mempolicy.c |   16 ++++++++--------
> > >  1 file changed, 8 insertions(+), 8 deletions(-)
> > >
> > > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > > index 3d64b36..6bf0860 100644
> > > --- a/mm/mempolicy.c
> > > +++ b/mm/mempolicy.c
> > > @@ -953,16 +953,16 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> > >
> > >         vma = check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
> > >                         flags | MPOL_MF_DISCONTIG_OK, &pagelist);
> > > -       if (IS_ERR(vma))
> > > -               return PTR_ERR(vma);
> > > -
> > > -       if (!list_empty(&pagelist)) {
> > > +       if (IS_ERR(vma)) {
> > > +               err = PTR_ERR(vma);
> > > +               goto out;
> > > +       }
> > > +       if (!list_empty(&pagelist))
> > >                 err = migrate_pages(&pagelist, new_node_page, dest,
> > >                                                         false, MIGRATE_SYNC);
> > > -               if (err)
> > > -                       putback_lru_pages(&pagelist);
> > > -       }
> > > -
> > > +out:
> > > +       if (err)
> > > +               putback_lru_pages(&pagelist);
> > 
> > Good catch!
> > This is a regression since following commit. So, I doubt we need
> > all or nothing semantics. Can we revert it instead? (and probably
> > we need more kind comment for preventing an accident)
> 
> I think it makes sense to revert.  Not because of the semantics, but I
> just don't see how check_range() could even fail for this callsite:
> 
> 1. we pass mm->mmap->vm_start in there, so we should not fail due to
>    find_vma()
> 
> 2. we pass MPOL_MF_DISCONTIG_OK, so the discontig checks do not apply
>    and so can not fail
> 
> 3. we pass MPOL_MF_MOVE | MPOL_MF_MOVE_ALL, the page table loops will
>    continue until addr == end, so we never fail with -EIO
> 
> > commit 0def08e3acc2c9c934e4671487029aed52202d42
> > Author: Vasiliy Kulikov <segooon@gmail.com>
> > Date:   Tue Oct 26 14:21:32 2010 -0700
> > 
> >     mm/mempolicy.c: check return code of check_range
> 
> We don't use this code to "check" the range, we use it to collect
> migrate pages.  There is no failure case.

Right. I will send revert patch when I go to office.
Thanks for the pointing out.

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
