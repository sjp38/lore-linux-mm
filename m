Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 196416B0082
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 04:43:20 -0400 (EDT)
Date: Thu, 9 Jun 2011 10:43:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110609084300.GD11603@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
 <20110602073335.GA20630@cmpxchg.org>
 <BANLkTikztP6RoyBgMqUHgrzJFLZrHMCs=Q@mail.gmail.com>
 <20110602100007.GB20725@cmpxchg.org>
 <BANLkTi=xvunhqpXFJ=wJFkCuu+7Czh4nZw@mail.gmail.com>
 <4DF01EC2.8010105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DF01EC2.8010105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 08, 2011 at 09:15:46PM -0400, Rik van Riel wrote:
> On 06/02/2011 08:59 AM, Hiroyuki Kamezawa wrote:
> 
> >It seems your current series is a mixture of 2 works as
> >"re-desgin of softlimit" and "removal of global LRU".
> >I don't understand why you need 2 works at once.
> 
> That seems pretty obvious.
> 
> With the global LRU gone, the only way to reclaim
> pages in a global fashion (because the zone is low
> on memory), is to reclaim from all the memcgs in
> the zone.

That is correct.

> Doing that requires that the softlimit stuff is
> changed, and not only the biggest offender is
> attacked.

I think it's much more natural to do it that way, but it's not a
requirement as such.  We could just keep the extra soft limit reclaim
invocation in kswapd that looks for the biggest offender and the
hierarchy below it, then does a direct call to do_shrink_zone() to
bypass the generic hierarchy walk.

It's not very nice to have that kind of code duplication, but it's
possible to leave it like that for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
