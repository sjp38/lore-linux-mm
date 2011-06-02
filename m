Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2976B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 18:19:32 -0400 (EDT)
Date: Fri, 3 Jun 2011 00:19:06 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] vmscan: memcg-aware unevictable page rescue scanner
Message-ID: <20110602221906.GA4554@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-8-git-send-email-hannes@cmpxchg.org>
 <BANLkTi=cHVZP+fZwHNM3cXVyw53kJ2HQmw@mail.gmail.com>
 <BANLkTimvuwLYwzRT-6k_oVwKBzBEo500s-rXETerTskYHfontQ@mail.gmail.com>
 <BANLkTik1X72Re_QKM4iCaPbxCx2kcnfH_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTik1X72Re_QKM4iCaPbxCx2kcnfH_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jun 03, 2011 at 07:01:34AM +0900, Hiroyuki Kamezawa wrote:
> 2011/6/3 Ying Han <yinghan@google.com>:
> > On Thu, Jun 2, 2011 at 6:27 AM, Hiroyuki Kamezawa
> > <kamezawa.hiroyuki@gmail.com> wrote:
> >> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> >>> Once the per-memcg lru lists are exclusive, the unevictable page
> >>> rescue scanner can no longer work on the global zone lru lists.
> >>>
> >>> This converts it to go through all memcgs and scan their respective
> >>> unevictable lists instead.
> >>>
> >>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >>
> >> Hm, isn't it better to have only one GLOBAL LRU for unevictable pages ?
> >> memcg only needs counter for unevictable pages and LRU is not necessary
> >> to be per memcg because we don't reclaim it...
> >
> > Hmm. Are we suggesting to keep one un-evictable LRU list for all
> > memcgs? So we will have
> > exclusive lru only for file and anon. If so, we are not done to make
> > all the lru list being exclusive
> > which is critical later to improve the zone->lru_lock contention
> > across the memcgs
> >
> considering lrulock, yes, maybe you're right.

That's one of the complications.

> > Sorry If i misinterpret the suggestion here
> >
> 
> My concern is I don't know for what purpose this function is used ..

I am not sure how it's supposed to be used, either.  But it's
documented to be a 'really big hammer' and it's kicked off from
userspace.  So I suppose having the thing go through all memcgs bears
a low risk of being a problem.  My suggestion is we go that way until
someone complains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
