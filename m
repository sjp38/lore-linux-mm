Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9F796B0025
	for <linux-mm@kvack.org>; Mon, 16 May 2011 04:46:03 -0400 (EDT)
Date: Mon, 16 May 2011 09:45:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110516084558.GE5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305295404-12129-5-git-send-email-mgorman@suse.de>
 <4DCFAA80.7040109@jp.fujitsu.com>
 <1305519711.4806.7.camel@mulgrave.site>
 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Mon, May 16, 2011 at 02:04:00PM +0900, Minchan Kim wrote:
> On Mon, May 16, 2011 at 1:21 PM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
> > On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
> >> (2011/05/13 23:03), Mel Gorman wrote:
> >> > Under constant allocation pressure, kswapd can be in the situation where
> >> > sleeping_prematurely() will always return true even if kswapd has been
> >> > running a long time. Check if kswapd needs to be scheduled.
> >> >
> >> > Signed-off-by: Mel Gorman<mgorman@suse.de>
> >> > ---
> >> >   mm/vmscan.c |    4 ++++
> >> >   1 files changed, 4 insertions(+), 0 deletions(-)
> >> >
> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > index af24d1e..4d24828 100644
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
> >> >     unsigned long balanced = 0;
> >> >     bool all_zones_ok = true;
> >> >
> >> > +   /* If kswapd has been running too long, just sleep */
> >> > +   if (need_resched())
> >> > +           return false;
> >> > +
> >>
> >> Hmm... I don't like this patch so much. because this code does
> >>
> >> - don't sleep if kswapd got context switch at shrink_inactive_list
> >
> > This isn't entirely true:  need_resched() will be false, so we'll follow
> > the normal path for determining whether to sleep or not, in effect
> > leaving the current behaviour unchanged.
> >
> >> - sleep if kswapd didn't
> >
> > This also isn't entirely true: whether need_resched() is true at this
> > point depends on a whole lot more that whether we did a context switch
> > in shrink_inactive. It mostly depends on how long we've been running
> > without giving up the CPU.  Generally that will mean we've been round
> > the shrinker loop hundreds to thousands of times without sleeping.
> >
> >> It seems to be semi random behavior.
> >
> > Well, we have to do something.  Chris Mason first suspected the hang was
> > a kswapd rescheduling problem a while ago.  We tried putting
> > cond_rescheds() in several places in the vmscan code, but to no avail.
> 
> Is it a result of  test with patch of Hannes(ie, !pgdat_balanced)?
> 
> If it isn't, it would be nop regardless of putting cond_reshed at vmscan.c.
> Because, although we complete zone balancing, kswapd doesn't sleep as
> pgdat_balance returns wrong result. And at last VM calls
> balance_pgdat. In this case, balance_pgdat returns without any work as
> kswap couldn't find zones which have not enough free pages and goto
> out. kswapd could repeat this work infinitely. So you don't have a
> chance to call cond_resched.
> 
> But if your test was with Hanne's patch, I am very curious how come
> kswapd consumes CPU a lot.
> 
> > The need_resched() in sleeping_prematurely() seems to be about the best
> > option.  The other option might be just to put a cond_resched() in
> > kswapd_try_to_sleep(), but that will really have about the same effect.
> 
> I don't oppose it but before that, I think we have to know why kswapd
> consumes CPU a lot although we applied Hannes' patch.
> 

Because it's still possible for processes to allocate pages at the same
rate kswapd is freeing them leading to a situation where kswapd does not
consider the zone balanced for prolonged periods of time.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
