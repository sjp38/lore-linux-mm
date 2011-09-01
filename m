Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A491E6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 02:15:51 -0400 (EDT)
Date: Thu, 1 Sep 2011 08:15:40 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual
 size
Message-ID: <20110901061540.GA22561@redhat.com>
References: <20110831090850.GA27345@redhat.com>
 <CAEwNFnBSg71QoLZbOqZbXK3fGEGneituU3PmiYTAw1VM3KcwcQ@mail.gmail.com>
 <20110901090931.c0721216.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110901090931.c0721216.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 01, 2011 at 09:09:31AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 31 Aug 2011 19:13:34 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Wed, Aug 31, 2011 at 6:08 PM, Johannes Weiner <jweiner@redhat.com> wrote:
> > > Reclaim decides to skip scanning an active list when the corresponding
> > > inactive list is above a certain size in comparison to leave the
> > > assumed working set alone while there are still enough reclaim
> > > candidates around.
> > >
> > > The memcg implementation of comparing those lists instead reports
> > > whether the whole memcg is low on the requested type of inactive
> > > pages, considering all nodes and zones.
> > >
> > > This can lead to an oversized active list not being scanned because of
> > > the state of the other lists in the memcg, as well as an active list
> > > being scanned while its corresponding inactive list has enough pages.
> > >
> > > Not only is this wrong, it's also a scalability hazard, because the
> > > global memory state over all nodes and zones has to be gathered for
> > > each memcg and zone scanned.
> > >
> > > Make these calculations purely based on the size of the two LRU lists
> > > that are actually affected by the outcome of the decision.
> > >
> > > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > Cc: Balbir Singh <bsingharora@gmail.com>
> > 
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > I can't understand why memcg is designed for considering all nodes and zones.
> > Is it a mistake or on purpose?
> 
> It's purpose. memcg just takes care of the amount of pages.

This mechanism isn't about memcg at all, it's an aging decision at a
much lower level.  Can you tell me how the old implementation is
supposed to work?

> But, hmm, this change may be good for softlimit and your work.

Yes, I noticed those paths showing up in a profile with my patches.
Lots of memcgs on a multi-node machine will trigger it too.  But it's
secondary, my primary reasoning was: this does not make sense at all.

> I'll ack when you add performance numbers in changelog.

It's not exactly a performance optimization but I'll happily run some
workloads.  Do you have suggestions what to test for?  I.e. where
would you expect regressions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
