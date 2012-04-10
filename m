Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B82AB6B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:04:31 -0400 (EDT)
Date: Mon, 9 Apr 2012 17:04:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Revert
 "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
Message-Id: <20120409170429.ef094a1d.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1204091529100.1964@eggly.anvils>
References: <1334000524-23972-1-git-send-email-yinghan@google.com>
	<20120409125055.c6f6fdf0.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1204091529100.1964@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Ying Han <yinghan@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org

On Mon, 9 Apr 2012 16:24:16 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 33c332b..1a51868 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2107,12 +2107,7 @@ restart:
> > >  		 * with multiple processes reclaiming pages, the total
> > >  		 * freeing target can get unreasonably large.
> > >  		 */
> > > -		if (nr_reclaimed >= nr_to_reclaim)
> > > -			nr_to_reclaim = 0;
> > > -		else
> > > -			nr_to_reclaim -= nr_reclaimed;
> > > -
> > > -		if (!nr_to_reclaim && priority < DEF_PRIORITY)
> > > +		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
> > >  			break;
> > >  	}
> > >  	blk_finish_plug(&plug);
> > 
> > This code is all within a loop: the "goto restart" thing.  We reset
> > nr_reclaimed to zero each time around that loop.  nr_to_reclaim is (or
> > rather, was) constant throughout the entire function.
> > 
> > Comparing nr_reclaimed (whcih is reset each time around the loop) to
> > nr_to_reclaim made no sense.
> 
> The "restart: nr_reclaimed = 0; ... if should_continue_reclaim goto restart;"
> business is a "late" addition for the exceptional case of compaction.
> It makes sense to me as "But in the high-order compaction case, we may need
> to try N times as hard as the caller asked for: go round and do it again".
> 
> If you set aside the restart business, and look at the usual "while (nr..."
> loop, c38446 makes little sense.  Each time around that loop, nr_reclaimed
> goes up by the amount you'd expect, and nr_to_reclaim goes down by
> nr_reclaimed i.e. by a larger and larger amount each time around the
> loop (if we assume at least one page is reclaimed each time around).

Oh, yes, true - it's the loop-within-the-loop.

> > I think the code as it stands is ugly.  It would be better to make
> > nr_to_reclaim a const and to add another local total_reclaimed, and
> > compare that with nr_to_reclaim.  Or just stop resetting nr_reclaimed
> > each time around the loop.
> 
> I bet you're right that it could be improved, in clarity and in function;
> but I'd rather leave that to someone who knows what they're doing: there's
> no end to the doubts here (I get hung up on sc->nr_reclaimed, which long
> long ago was set to nr_reclaimed here, but nowadays is incremented, and
> I wonder whether it gets reset appropriately).  Get into total_reclaimed
> and you start down the line of functional change here, without adequate
> testing.
> 

So for compaction, we go around and try to reclaim another
nr_to_reclaim hunk of pages.  The (re)use of nr_to_reclaim seems rather
arbitrary here.  Particularly as nr_reclaimed and nr_to_reclaim don't
actually do anything for low-priority scanning.  I guess it doesn't
matter much, as long as we don't go and scan far too many pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
