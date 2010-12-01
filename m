Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B82C16B0087
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 10:29:25 -0500 (EST)
Date: Wed, 1 Dec 2010 09:29:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101201114226.ABAB.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012010910450.2989@router.home>
References: <20101130092534.82D5.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011301309240.3134@router.home> <20101201114226.ABAB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Dec 2010, KOSAKI Motohiro wrote:

> > Specifying a parameter to temporarily override to see if this has the
> > effect is ok. But this has worked for years now. There must be something
> > else going with with reclaim that causes these issues now.
>
> I don't think this has worked. Simon have found the corner case recently,
> but it is not new.

What has worked? If the reduction of the maximum allocation order did not
have the expected effect of fixing things here then the issue is not
related to the higher allocations from slub.

Higher order allocations are not only a slub issue but a general issue for
various subsystem that require higher order pages. This ranges from jumbo
frames, to particular needs for certain device drivers, to huge pages.

> So I hope you realize that high order allocation is no free lunch. __GFP_NORETRY
> makes no sense really. Even though we have compaction, high order reclaim is still
> costly operation.

Sure. There is a tradeoff between reclaim effort and the benefit of higher
allocations. The costliness of reclaim may have increased with the recent
changes to the reclaim logic. In fact reclaim gets more and more complex
over time and there may be subtle bugs in there given the recent flurry of
changes.

> I don't think SLUB's high order allocation trying is bad idea. but now It
> does more costly trying. that's bad. Also I'm worry about SLUB assume too
> higher end machine. Now Both SLES and RHEL decided to don't use SLUB,
> instead use SLAB. Now linux community is fragmented. If you are still
> interesting SL*B unification, can you please consider to join corner
> case smashing activity?

The problems with higher order reclaim get more difficult with small
memory sizes yes. We could reduce the maximum order automatically if memory
is too tight. There is nothing hindering us from tuning the max order
behavior of slub in a similar way that we now tune the thresholds of the
vm statistics.

But for that to be done we first need to have some feedback if the changes
to max order have indeed the desired effect in this corner case.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
