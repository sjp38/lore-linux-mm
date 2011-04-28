Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5ABF86B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:34:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 492EB3EE0BD
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:34:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3136645DE55
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:34:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FCB845DE4E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:34:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B85551DB803E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:34:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 847381DB802C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:34:32 +0900 (JST)
Date: Thu, 28 Apr 2011 13:27:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Fw: [PATCH] memcg: add reclaim statistics accounting
Message-Id: <20110428132757.130b4206.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikgJWYJ8_rAkuNtD0vTehCG7vPpow@mail.gmail.com>
References: <20110428121643.b3cbf420.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimywCF06gfKWFcbAsWtFUbs73rZrQ@mail.gmail.com>
	<20110428125739.15e252a7.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikgJWYJ8_rAkuNtD0vTehCG7vPpow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, 27 Apr 2011 21:24:30 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 27, 2011 at 8:57 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 27 Apr 2011 20:43:58 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
>
> >> Does it make sense to split up the soft_steal/scan for bg reclaim and
> >> direct reclaim?
> >
> > Please clarify what you're talking about before asking. Maybe you want to say
> > "I'm now working for supporting softlimit in direct reclaim path. So, does
> > A it make sense to account direct/kswapd works in statistics ?"
> >
> > I think bg/direct reclaim is not required to be splitted.
> 
> Ok, thanks for the clarification. The patch i am working now to be
> more specific is to add the
> soft_limit hierarchical reclaim on the global direct reclaim.
> 
> I am adding similar stats to monitor the soft_steal, but i split-off
> the soft_steal from global direct reclaim and
> global background reclaim. I am wondering isn't that give us more
> visibility of the reclaim path?
>

Hmm, if kswapd and direc-reclaim uses the same logic, I don't care which
steals memory. But i'm not sure you implementation before seeing patch.
So, please let me postphone answering this. But, considering again,
/proc/vmstat has
==
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 0
pgscan_direct_normal 0
pgscan_direct_movable 0
==

maybe it's ok to have split stats.


BTW, ff I add more statistics, I'll add per-node statistics.
Hmm, memory.node_stat is required ?


> >
> >
> >> direct_soft_steal 0
> >> direct_soft_scan 0
> >
> > Maybe these are new ones added by your work. But should be merged to
> > soft_steal/soft_scan.
> the same question above, why we don't want to have better visibility
> of where we triggered
> the soft_limit reclaim and how much has been done on behalf of each.
> 
Maybe I answerd this.



> >
> >> kswapd_steal 0
> >> pg_pgsteal 0
> >> kswapd_pgscan 0
> >> pg_scan 0
> >>
> >
> > Maybe this indicates reclaimed-by-other-tasks-than-this-memcg. Right ?
> > Maybe good for checking isolation of memcg, hmm, can these be accounted
> > in scalable way ?
> 
> you can ignore those four stats. They are part of the per-memcg-kswapd
> patchset, and i guess you might
> have similar patch for that purpose.
> 
Ah, I named them as wmark_scan/wmark_steal for avoiding confusion.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
