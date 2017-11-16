Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EB4E0280259
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 23:50:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j16so22721122pgn.14
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 20:50:30 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 102si210358pld.614.2017.11.15.20.50.28
        for <linux-mm@kvack.org>;
        Wed, 15 Nov 2017 20:50:29 -0800 (PST)
Date: Thu, 16 Nov 2017 13:50:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171116045027.GA13101@bbox>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115005602.GB23810@bbox>
 <CALvZod44uBUJdaRSqAB4Kym9u9KX0pgitYmWVbM-Ww30HdFpzQ@mail.gmail.com>
 <20171116004614.GB12222@bbox>
 <CALvZod4r7AWGiRpcxSsOf2ZdUyNUvzFnqTkcxa5F8wb2ssV7gQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4r7AWGiRpcxSsOf2ZdUyNUvzFnqTkcxa5F8wb2ssV7gQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 15, 2017 at 05:41:41PM -0800, Shakeel Butt wrote:
> On Wed, Nov 15, 2017 at 4:46 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Tue, Nov 14, 2017 at 10:28:10PM -0800, Shakeel Butt wrote:
> >> On Tue, Nov 14, 2017 at 4:56 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> >> >> When shrinker_rwsem was introduced, it was assumed that
> >> >> register_shrinker()/unregister_shrinker() are really unlikely paths
> >> >> which are called during initialization and tear down. But nowadays,
> >> >> register_shrinker()/unregister_shrinker() might be called regularly.
> >> >> This patch prepares for allowing parallel registration/unregistration
> >> >> of shrinkers.
> >> >>
> >> >> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> >> >> using one RCU section. But using atomic_inc()/atomic_dec() for each
> >> >> do_shrink_slab() call will not impact so much.
> >> >>
> >> >> This patch uses polling loop with short sleep for unregister_shrinker()
> >> >> rather than wait_on_atomic_t(), for we can save reader's cost (plain
> >> >> atomic_dec() compared to atomic_dec_and_test()), we can expect that
> >> >> do_shrink_slab() of unregistering shrinker likely returns shortly, and
> >> >> we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> >> >> shrinker unexpectedly took so long.
> >> >>
> >> >> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >> >
> >> > Before reviewing this patch, can't we solve the problem with more
> >> > simple way? Like this.
> >> >
> >> > Shakeel, What do you think?
> >> >
> >>
> >> Seems simple enough. I will run my test (running fork bomb in one
> >> memcg and separately time a mount operation) and update if numbers
> >> differ significantly.
> >
> > Thanks.
> >
> >>
> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > index 13d711dd8776..cbb624cb9baa 100644
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -498,6 +498,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >> >                         sc.nid = 0;
> >> >
> >> >                 freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> >> > +               /*
> >> > +                * bail out if someone want to register a new shrinker to prevent
> >> > +                * long time stall by parallel ongoing shrinking.
> >> > +                */
> >> > +               if (rwsem_is_contended(&shrinker_rwsem)) {
> >> > +                       freed = 1;
> >>
> >> freed = freed ?: 1;
> >
> > Yub.
> 
> Thanks Minchan, you can add
> 
> Reviewed-and-tested-by: Shakeel Butt <shakeelb@google.com>

Thanks for the testing, Shakeel.

I will send formal patch to Andrew after closing merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
