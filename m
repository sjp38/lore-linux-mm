Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B50C48D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:23:12 -0500 (EST)
Date: Mon, 15 Nov 2010 09:22:56 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] mm,vmscan: Reclaim order-0 and compact instead of
	lumpy reclaim when under light pressure
Message-ID: <20101115092256.GE27362@csn.ul.ie>
References: <1289502424-12661-4-git-send-email-mel@csn.ul.ie> <20101112093742.GA3537@csn.ul.ie> <20101114150039.E028.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101114150039.E028.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 03:02:03PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Nov 11, 2010 at 07:07:04PM +0000, Mel Gorman wrote:
> > > +	if (COMPACTION_BUILD)
> > > +		sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> > > +	else
> > > +		sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
> > >  
> > 
> > Gack, I posted the slightly wrong version. This version prevents lumpy
> > reclaim ever being used. The figures I posted were for a patch where
> > this condition looked like
> > 
> >         if (COMPACTION_BUILD && priority > DEF_PRIORITY - 2)
> >                 sc->lumpy_reclaim_mode = LUMPY_MODE_COMPACTION;
> >         else
> >                 sc->lumpy_reclaim_mode = LUMPY_MODE_CONTIGRECLAIM;
> 
> Can you please tell us your opinition which is better 1) automatically turn lumby on
> by priority (this approach) 2) introduce GFP_LUMPY (andrea proposed). I'm not
> sure which is better, then I'd like to hear both pros/cons concern.
> 

That's a very good question!

The main "pro" of using lumpy reclaim is that it has been tested. It's known
to be very heavy and disrupt the system but it's also known to work. Lumpy
reclaim is also less suspectible to allocation races than compaction is
i.e. if memory is low, compaction requires that X number of pages be free
where as lumpy frees the pages it requires.

GFP_LUMPY is something else and is only partially related. Transparent Huge
Pages (THP) does not want to hit lumpy reclaim no matter what the circumstances
are - It is always better for THP to not use lumpy reclaim. It's debatable
whether it should even reclaim order-0 pages for compaction so even with
this series, THP might still introduce GFP_LUMPY.

Does this answer your question?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
