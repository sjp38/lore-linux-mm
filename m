Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D75166B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 19:21:24 -0400 (EDT)
Date: Fri, 21 Sep 2012 08:24:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix NR_ISOLATED_[ANON|FILE] mismatch
Message-ID: <20120920232408.GI13234@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Vasiliy Kulikov <segooon@gmail.com>

On Thu, Sep 20, 2012 at 11:41:11AM -0400, Johannes Weiner wrote:
> On Thu, Sep 20, 2012 at 08:51:56AM +0900, Minchan Kim wrote:
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Thu, 20 Sep 2012 08:39:52 +0900
> > Subject: [PATCH] mm: revert 0def08e3, mm/mempolicy.c: check return code of
> >  check_range
> > 
> > This patch reverts 0def08e3 because check_range can't fail in
> > migrate_to_node with considering current usecases.
> > 
> > Quote from Johannes
> > "
> > I think it makes sense to revert.  Not because of the semantics, but I
> > just don't see how check_range() could even fail for this callsite:
> > 
> > 1. we pass mm->mmap->vm_start in there, so we should not fail due to
> >    find_vma()
> > 
> > 2. we pass MPOL_MF_DISCONTIG_OK, so the discontig checks do not apply
> >    and so can not fail
> > 
> > 3. we pass MPOL_MF_MOVE | MPOL_MF_MOVE_ALL, the page table loops will
> >    continue until addr == end, so we never fail with -EIO
> > "
> > 
> > And I add new VM_BUG_ON for checking migrate_to_node's future usecase
> > which might pass to MPOL_MF_STRICT.
> > 
> > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Christoph Lameter <cl@linux.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Vasiliy Kulikov <segooon@gmail.com>
> > Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/mempolicy.c |    9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 3d64b36..9ec87bd 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -946,15 +946,16 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> >  	nodemask_t nmask;
> >  	LIST_HEAD(pagelist);
> >  	int err = 0;
> > -	struct vm_area_struct *vma;
> >  
> >  	nodes_clear(nmask);
> >  	node_set(source, nmask);
> >  
> > -	vma = check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
> > +	/*
> > +	 * Collect migrate pages and it shoudn't be failed.
> > +	 */
> > +	VM_BUG_ON(flags & MPOL_MF_STRICT);
> 
> Adding a check and a comment is a good idea, but I'm not a big fan of
> checking for MPOL_MF_STRICT in particular because it's one of the
> invalid inputs, and so you need to extend this check when somebody
> extends the spectrum of invalid inputs.  I would much prefer checking
> directly for !(flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) instead, which
> would also make the possible inputs apparent without having to chase
> up the call chain to find out what is usually passed in.
> 
> And how about
> 
> /*
>  * This does not "check" the range but isolates all pages that
>  * need migration.  Between passing in the full user address
>  * space range and MPOL_MF_DISCONTIG_OK, this call can not fail.
>  */
> 
> ?

Good idea. Thanks Hannes,
