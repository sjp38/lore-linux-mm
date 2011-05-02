Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C802B90011A
	for <linux-mm@kvack.org>; Mon,  2 May 2011 03:22:56 -0400 (EDT)
Date: Mon, 2 May 2011 09:22:10 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] Add the soft_limit reclaim in global direct reclaim.
Message-ID: <20110502072210.GA24305@cmpxchg.org>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
 <1304030226-19332-2-git-send-email-yinghan@google.com>
 <20110429130503.GA306@tiehlicka.suse.cz>
 <BANLkTinkB+qF6u6TtsSoahdPOmNtAht39A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinkB+qF6u6TtsSoahdPOmNtAht39A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 10:44:16AM -0700, Ying Han wrote:
> On Fri, Apr 29, 2011 at 6:05 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 28-04-11 15:37:05, Ying Han wrote:
> >> We recently added the change in global background reclaim which
> >> counts the return value of soft_limit reclaim. Now this patch adds
> >> the similar logic on global direct reclaim.

The changelog is a bit misleading: you don't just add something that
counts something.  You add code that can result in actual page
reclamation.

> >> @@ -1980,8 +1983,17 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
> >>                               continue;       /* Let kswapd poll it */
> >>               }
> >>
> >> +             nr_soft_scanned = 0;
> >> +             nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> >> +                                                     sc->order, sc->gfp_mask,
> >> +                                                     &nr_soft_scanned);
> >> +             sc->nr_reclaimed += nr_soft_reclaimed;
> >> +             total_scanned += nr_soft_scanned;
> >> +
> >>               shrink_zone(priority, zone, sc);
> >
> > This can cause more aggressive reclaiming, right? Shouldn't we check
> > whether shrink_zone is still needed?
> 
> We decided to leave the shrink_zone for now before making further
> changes for soft_limit reclaim. The same
> patch I did last time for global background reclaim. It is safer to do
> this step-by-step :)

I am sorry, but I kinda lost track of what's going on because there
are so many patches and concurrent discussions...  who is we and do
you have a pointer to the email where this conclusion was reached?

And safe how?  Do you want to trade a potential regression against a
certain one (overreclaim)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
