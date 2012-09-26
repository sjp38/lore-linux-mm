Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D43936B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 06:17:33 -0400 (EDT)
Date: Wed, 26 Sep 2012 11:17:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/9] mm: compaction: Acquire the zone->lru_lock as late
 as possible
Message-ID: <20120926101727.GI11266@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-6-git-send-email-mgorman@suse.de>
 <20120925070517.GK13234@bbox>
 <20120925075105.GC11266@suse.de>
 <20120925081327.GA7759@bbox>
 <20120925143931.f404ca22.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120925143931.f404ca22.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Sep 25, 2012 at 02:39:31PM -0700, Andrew Morton wrote:
> On Tue, 25 Sep 2012 17:13:27 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > I see. To me, your saying is better than current comment.
> > I hope comment could be more explicit.
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index df01b4e..f1d2cc7 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -542,8 +542,9 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >                  * splitting and collapsing (collapsing has already happened
> >                  * if PageLRU is set) but the lock is not necessarily taken
> >                  * here and it is wasteful to take it just to check transhuge.
> > -                * Check transhuge without lock and skip if it's either a
> > -                * transhuge or hugetlbfs page.
> > +                * Check transhuge without lock and *skip* if it's either a
> > +                * transhuge or hugetlbfs page because it's not safe to call
> > +                * compound_order.
> >                  */
> >                 if (PageTransHuge(page)) {
> >                         if (!locked)
> 
> Going a bit further:
> 
> --- a/mm/compaction.c~mm-compaction-acquire-the-zone-lru_lock-as-late-as-possible-fix
> +++ a/mm/compaction.c
> @@ -415,7 +415,8 @@ isolate_migratepages_range(struct zone *
>  		 * if PageLRU is set) but the lock is not necessarily taken
>  		 * here and it is wasteful to take it just to check transhuge.
>  		 * Check transhuge without lock and skip if it's either a
> -		 * transhuge or hugetlbfs page.
> +		 * transhuge or hugetlbfs page because calling compound_order()
> +		 * requires lru_lock to exclude isolation and splitting.
>  		 */
>  		if (PageTransHuge(page)) {
>  			if (!locked)
> _
> 
> but...  the requirement to hold lru_lock for compound_order() is news
> to me.  It doesn't seem to be written down or explained anywhere, and
> one wonders why the cheerily undocumented compound_lock() doesn't have
> this effect.  What's going on here??
> 

The lru_lock is not *required* for compound_order(). Normally, users of
compound_order() know that the page is not going to collapse underneath
them. The slub allocator is not going to have a compound page it controls
disappear unexpectedly and does not need additional locking for example.

In the case where we are potentially dealing with a THP page, we have to
take into account if it can collapse underneath us. In this case, there is a
race between when when PageTransHuge is checked and compound_order is called.
The race is probably harmless but it was easy to take into account in
this case.

I think the comment saying that lru_lock is required is misleading. How
about this?

                 * Check TransHuge without lock and skip the whole
                 * pageblock if it's either a transhuge or hugetlbfs page
		 * as calling compound_order without preventing THP
		 * splitting the page underneath us may return
		 * surprising results.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
