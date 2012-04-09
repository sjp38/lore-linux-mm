Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 3C9806B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 19:24:56 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8810015iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 16:24:55 -0700 (PDT)
Date: Mon, 9 Apr 2012 16:24:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in
 shrink_mem_cgroup_zone()"
In-Reply-To: <20120409125055.c6f6fdf0.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1204091529100.1964@eggly.anvils>
References: <1334000524-23972-1-git-send-email-yinghan@google.com> <20120409125055.c6f6fdf0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org

On Mon, 9 Apr 2012, Andrew Morton wrote:
> On Mon,  9 Apr 2012 12:42:04 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > This reverts commit c38446cc65e1f2b3eb8630c53943b94c4f65f670.
> > 
> > Before the commit, the code makes senses to me but not after the commit. The
> > "nr_reclaimed" is the number of pages reclaimed by scanning through the memcg's
> > lru lists. The "nr_to_reclaim" is the target value for the whole function. For
> > example, we like to early break the reclaim if reclaimed 32 pages under direct
> > reclaim (not DEF_PRIORITY).
> > 
> > After the reverted commit, the target "nr_to_reclaim" is decremented each time
> > by "nr_reclaimed" but we still use it to compare the "nr_reclaimed". It just
> > doesn't make sense to me...
> > 
> > Signed-off-by: Ying Han <yinghan@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

though I do prefer the revert to the description of it.

> > ---
> >  mm/vmscan.c |    7 +------
> >  1 files changed, 1 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 33c332b..1a51868 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2107,12 +2107,7 @@ restart:
> >  		 * with multiple processes reclaiming pages, the total
> >  		 * freeing target can get unreasonably large.
> >  		 */
> > -		if (nr_reclaimed >= nr_to_reclaim)
> > -			nr_to_reclaim = 0;
> > -		else
> > -			nr_to_reclaim -= nr_reclaimed;
> > -
> > -		if (!nr_to_reclaim && priority < DEF_PRIORITY)
> > +		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
> >  			break;
> >  	}
> >  	blk_finish_plug(&plug);
> 
> This code is all within a loop: the "goto restart" thing.  We reset
> nr_reclaimed to zero each time around that loop.  nr_to_reclaim is (or
> rather, was) constant throughout the entire function.
> 
> Comparing nr_reclaimed (whcih is reset each time around the loop) to
> nr_to_reclaim made no sense.

The "restart: nr_reclaimed = 0; ... if should_continue_reclaim goto restart;"
business is a "late" addition for the exceptional case of compaction.
It makes sense to me as "But in the high-order compaction case, we may need
to try N times as hard as the caller asked for: go round and do it again".

If you set aside the restart business, and look at the usual "while (nr..."
loop, c38446 makes little sense.  Each time around that loop, nr_reclaimed
goes up by the amount you'd expect, and nr_to_reclaim goes down by
nr_reclaimed i.e. by a larger and larger amount each time around the
loop (if we assume at least one page is reclaimed each time around).

Now, it's possible that that interesting nonlinearity is precisely
the magic needed for optimal behaviour in shrink_mem_cgroup_zone();
but the commit comment doesn't claim that, it claims to be correcting
a mistake in nr_reclaimed versus nr_to_reclaim (perceived, I guess,
in the exceptional restart loop), whereas it's introducing a mistake
in nr_reclaimed versus nr_to_reclaim in the common while loop.

> 
> I think the code as it stands is ugly.  It would be better to make
> nr_to_reclaim a const and to add another local total_reclaimed, and
> compare that with nr_to_reclaim.  Or just stop resetting nr_reclaimed
> each time around the loop.

I bet you're right that it could be improved, in clarity and in function;
but I'd rather leave that to someone who knows what they're doing: there's
no end to the doubts here (I get hung up on sc->nr_reclaimed, which long
long ago was set to nr_reclaimed here, but nowadays is incremented, and
I wonder whether it gets reset appropriately).  Get into total_reclaimed
and you start down the line of functional change here, without adequate
testing.

For now let's just take the first step of reverting the mistaken commit.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
