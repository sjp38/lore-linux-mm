Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A72578D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 02:14:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 600983EE081
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:14:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 42DDC45DE6E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:14:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 209C545DE69
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:14:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0993B1DB8046
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:14:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D291DB8041
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:14:06 +0900 (JST)
Date: Thu, 31 Mar 2011 15:07:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
Message-Id: <20110331150718.859d3178.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTimiwObEvRLv8pmmcy8v31FN2y_VOg@mail.gmail.com>
References: <1301532498-20309-1-git-send-email-yinghan@google.com>
	<20110331112532.82ed25ad.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimiwObEvRLv8pmmcy8v31FN2y_VOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 30 Mar 2011 22:41:51 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Mar 30, 2011 at 7:25 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 30 Mar 2011 17:48:18 -0700
> > Ying Han <yinghan@google.com> wrote:

> > > b) skipping global lru reclaim if soft_limit reclaim does enough work.
> > this is
> > > both for global background reclaim and global ttfp reclaim.
> >
> > agree. but zone-balancing cannot be avoidalble for now. So, I think we need
> > a
> > inter-zone-page-migration to balancing memory between zones...if necessary.
> >
> 
> thank you for your comments, and can you clarify a bit on this? Actually I
> was thinking about the zone balancing within memcg, but haven't thought it
> through yet. I would like to learn more on the cases that we can not avoid
> global zone-balancing totally.
> 

For easyness, please assume i386 host with small HIGHMEM. And you create an
isolated 2 memcg on it. For example, i386 with 1.5G memory, NORMAL is 800M
and HIGMEM is 700M. And there is no softlimit settings.

1st, running an application on memcg A, and it allocates 800MB memory.
In this case, almost all memory of "A" is in HIGHMEM.

2nd, running another application on memcg B, and it allocates 600MB memory.
All B's memory will be from NORMAL zones.

3rd, an application on memcg A exits.

Finally, we see
   HIGHMEM .... 700MB free.
   NORMAL  .... some amount near to 200MB free, 600MB hidden(isolated)


4th, someone runs an application which consumes NORMAL memory. the kernel
tries to free memory in NORMAL zone....but it can only find 200MB, at most.

If there is no isolated memcg, 600MB isn't hidden and

   NORMAL pageout -> access again -> HIGHMEM pagein.

Then, application in B will work happily in _new_ balance of page-zone usage after
some kswapd runs.

This is my understanding around zone balancing. You need to add an interface
to move pages to other zones if you implement an _isolation_. 
This can be implemented by some interface as ballooning between memcg <-> global...
but, IIUC, if the function says "isolation", the page should never be swapped-out. 

IOW, swapout itself is okay to me, but that will break the user's assumption of
"isolation". He'll say "Why my application is swapped out !"
So, I think inter-zone, inter-node balancing should be implemented by page
migration to avoid swapout. The same kind of problem will be found with cpuset/NUMA.

At least, this should be implemented before allowing 'isolation'.

If swapout happens even if
  - using memcg for isolation
  - there are tons of free memory
  - no memcg reaches its limit.

I think it's a bug if I'm a customer. It's not usable quality in production.

> >
> >
> > > c) improve the soft_limit reclaim to be efficient.
> >
> > must be done.
> >
> 
> The current design of soft_limit is more on the correctness rather than
> efficiency. If we are talking about to improve the efficiency of target
> reclaim, there are quite a lot to change. The first thing might be improving
> the per-zone RB tree. They are currently based on per-memcg
> (usage_limit-soft_limit) regardless of how much pages landed on the zone.
> 

Yes, that's a scheduling problem of softlimit. I don't think current one is
the best. This area needs study.
I guess the number of 'inactive' file caches should be considered, at least.

But a problem is that soft-limit is an interface to users. Hard-to-understand
one is not very good one.



> 
> >
> > > d) isolate pages in memcg from global list since it breaks memory
> > isolation.
> >
> 
> 
> 
> > >
> >
> > I never agree this until about a),b),c) is fixed and we can go nowhere.
> >
> > BTW, in other POV, for reducing size of page_cgroup, we must remove ->lru
> > on page_cgroup. If divide-and-conquer memory reclaim works enough,
> > we can do that. But this is a big global VM change, so we need enough
> > justification.
> >
> 
> I can agree on that. The change looks big, especially without efficient
> target reclaim. However
> I do believe we need this to have isolation guarantee.
> 

But, 'isolation' is not 'guarantee'. I prefere 'guarantee' rather than
'isolation'. IIUC, what HA guys want is not 'isolation' but 'guarantee'.




> >
> > Anyway, this seems too aggresive to me, for now. Please do a), b), c), at
> > first.
> >
> 
> 
> >
> > IIUC, this patch itself can cause a livelock when softlimit is
> > misconfigured.
> > What is the protection against wrong softlimit ?
> >
> 
> Hmm, can you help to clarify on that?
> 

IIUC, memcg's memory will never be reclaimed unless it exceeds softlimit.

Then, Assume memcg A and B on a 1.5G server.

If 
   A .... 1G softlimit
   B .... 1G softlimit

If A uses 800MB, B uses 700MB, where kswapd will get memory from ?


In other idea, Assume a memcg A and B on a 1.5G server.

   A .... 100M softlimit  -> almost all usage is ANON. 
   B .... 1G softlimit    -> almost all usage is file cache, which is inactive.

The server will see very bad swapout, won't ?
So, I repeatedly say 'improve softlimit 1st.'

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
