Date: Wed, 16 Nov 2005 01:37:47 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/5] Light Fragmentation Avoidance V20: 004_percpu
In-Reply-To: <20051115152414.568dc3a8.pj@sgi.com>
Message-ID: <Pine.LNX.4.58.0511160137030.8470@skynet>
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie>
 <20051115165007.21980.37336.sendpatchset@skynet.csn.ul.ie>
 <20051115152414.568dc3a8.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, mingo@elte.hu, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tue, 15 Nov 2005, Paul Jackson wrote:

> Mel wrote:
> > -		mark -= mark / 2;			[A]
> > +		mark /= 2;				[B]
> >  	if (alloc_flags & ALLOC_HARDER)
> > -		mark -= mark / 4;			[C]
> > +		mark /= 4;				[D]
>
> Why these changes?  For each of [A] - [D] above, if I start with a
> value of mark == 33 and recycle that same mark through the above
> transformation 16 times, I get the following sequence of values:


This change by me is totally totally wrong. I shouldn't have modified how
the calculation is made at all. Fix made.

>  A:  33  17   9   5   3   2   1   1   1   1   1   1   1   1   1   1
>  B:  33  16   8   4   2   1   0   0   0   0   0   0   0   0   0   0
>  C:  33  25  19  15  12   9   7   6   5   4   3   3   3   3   3   3
>  D:  33   8   2   0   0   0   0   0   0   0   0   0   0   0   0   0
>
> Comparing [A] to [B], observe that [A] converges to 1, but [B] to 0,
> due to handling the underflow differently.
>
> Comparing [C] to [D], observe that [D] converges to 0, due to the
> different underflow, and converges much faster, since it is taking off
> 3/4's instead of 1/4 each iteration.
>
> I doubt you want this change.
>

And you'd be right.

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
