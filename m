Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E9C596B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 00:22:35 -0400 (EDT)
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <4DCFAA80.7040109@jp.fujitsu.com>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	 <1305295404-12129-5-git-send-email-mgorman@suse.de>
	 <4DCFAA80.7040109@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 08:21:51 +0400
Message-ID: <1305519711.4806.7.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mgorman@suse.de, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
> (2011/05/13 23:03), Mel Gorman wrote:
> > Under constant allocation pressure, kswapd can be in the situation where
> > sleeping_prematurely() will always return true even if kswapd has been
> > running a long time. Check if kswapd needs to be scheduled.
> > 
> > Signed-off-by: Mel Gorman<mgorman@suse.de>
> > ---
> >   mm/vmscan.c |    4 ++++
> >   1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index af24d1e..4d24828 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
> >   	unsigned long balanced = 0;
> >   	bool all_zones_ok = true;
> > 
> > +	/* If kswapd has been running too long, just sleep */
> > +	if (need_resched())
> > +		return false;
> > +
> 
> Hmm... I don't like this patch so much. because this code does
> 
> - don't sleep if kswapd got context switch at shrink_inactive_list

This isn't entirely true:  need_resched() will be false, so we'll follow
the normal path for determining whether to sleep or not, in effect
leaving the current behaviour unchanged.

> - sleep if kswapd didn't

This also isn't entirely true: whether need_resched() is true at this
point depends on a whole lot more that whether we did a context switch
in shrink_inactive. It mostly depends on how long we've been running
without giving up the CPU.  Generally that will mean we've been round
the shrinker loop hundreds to thousands of times without sleeping.

> It seems to be semi random behavior.

Well, we have to do something.  Chris Mason first suspected the hang was
a kswapd rescheduling problem a while ago.  We tried putting
cond_rescheds() in several places in the vmscan code, but to no avail.
The need_resched() in sleeping_prematurely() seems to be about the best
option.  The other option might be just to put a cond_resched() in
kswapd_try_to_sleep(), but that will really have about the same effect.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
