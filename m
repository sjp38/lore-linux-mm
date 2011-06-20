Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 187A96B0012
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 00:09:44 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EC7173EE0BB
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:09:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDD6F45DE58
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:09:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AEC5445DE54
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:09:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A02951DB8052
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:09:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F0C61DB8046
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:09:33 +0900 (JST)
Date: Mon, 20 Jun 2011 13:02:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7] memcg: add memory.scan_stat
Message-Id: <20110620130227.6202e8f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110620084123.c63d3e12.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125314.4f78b1e0.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimYEr9k3Sk5JoaRrrQH4mGoTmL1Wf5gadYVGDuNpxofHw@mail.gmail.com>
	<20110620084123.c63d3e12.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Andrew Bresticker <abrestic@google.com>

On Mon, 20 Jun 2011 08:41:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 17 Jun 2011 15:04:18 -0700
> Ying Han <yinghan@google.com> wrote:
> 
> > On Wed, Jun 15, 2011 at 8:53 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > From e08990dd9ada13cf236bec1ef44b207436434b8e Mon Sep 17 00:00:00 2001
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Date: Wed, 15 Jun 2011 14:11:01 +0900
> > > Subject: [PATCH 3/7] memcg: add memory.scan_stat
> > >
> > > commit log of commit 0ae5e89 " memcg: count the soft_limit reclaim in..."
> > > says it adds scanning stats to memory.stat file. But it doesn't because
> > > we considered we needed to make a concensus for such new APIs.
> > >
> > > This patch is a trial to add memory.scan_stat. This shows
> > > A - the number of scanned pages
> > > A - the number of recleimed pages
> > > A - the number of elaplsed time (including sleep/pause time)
> > > A for both of direct/soft reclaim and shrinking caused by changing limit
> > > A or force_empty.
> > >
> > > The biggest difference with oringinal Ying's one is that this file
> > > can be reset by some write, as
> > >
> > > A # echo 0 ...../memory.scan_stat
> > >
> > > [kamezawa@bluextal ~]$ cat /cgroup/memory/A/memory.scan_stat
> > > scanned_pages_by_limit 358470
> > > freed_pages_by_limit 180795
> > > elapsed_ns_by_limit 21629927
> > > scanned_pages_by_system 0
> > > freed_pages_by_system 0
> > > elapsed_ns_by_system 0
> > > scanned_pages_by_shrink 76646
> > > freed_pages_by_shrink 38355
> > > elappsed_ns_by_shrink 31990670
> > > total_scanned_pages_by_limit 358470
> > > total_freed_pages_by_limit 180795
> > > total_elapsed_ns_by_hierarchical 216299275
> > > total_scanned_pages_by_system 0
> > > total_freed_pages_by_system 0
> > > total_elapsed_ns_by_system 0
> > > total_scanned_pages_by_shrink 76646
> > > total_freed_pages_by_shrink 38355
> > > total_elapsed_ns_by_shrink 31990670
> > >
> > > total_xxxx is for hierarchy management.
> > >
> > > This will be useful for further memcg developments and need to be
> > > developped before we do some complicated rework on LRU/softlimit
> > > management.
> > 
> > Agreed. Actually we are also looking into adding a per-memcg API for
> > adding visibility of
> > page reclaim path. It would be helpful for us to settle w/ the API first.
> > 
> > I am not a fan of names, but how about
> > "/dev/cgroup/memory/memory.reclaim_stat" ?
> > 
> 
> Hm, ok, I have no favorite. 
> 
> 

If I rename, I'll just rename file name as "reclaim_stat" but doesn't
rename internal structures because there is already "struct reclaim_stat".

Hm, to be honest, I don't like the name "reclaim_stat".
(Because in most case, the pages are not freed for reclaim, but for
 hitting limit.)

memory.vmscan_info ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
