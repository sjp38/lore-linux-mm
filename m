Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9234A900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 02:27:26 -0400 (EDT)
Date: Thu, 18 Aug 2011 08:27:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 2/6]  memcg: stop vmscan when enough done.
Message-ID: <20110818062722.GB23056@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809190933.d965888b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110810141425.GC15007@tiehlicka.suse.cz>
 <20110811085252.b29081f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20110811145055.GN8023@tiehlicka.suse.cz>
 <20110817095405.ee3dcd74.kamezawa.hiroyu@jp.fujitsu.com>
 <20110817113550.GA7482@tiehlicka.suse.cz>
 <20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110818085233.69dbf23b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu 18-08-11 08:52:33, KAMEZAWA Hiroyuki wrote:
> On Wed, 17 Aug 2011 13:35:50 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 17-08-11 09:54:05, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 11 Aug 2011 16:50:55 +0200
> > > > - mem_cgroup_force_empty asks for reclaiming all pages. I guess it should be
> > > >   OK but will have to think about it some more.
> > > 
> > > force_empty/rmdir() is allowed to be stopped by Ctrl-C. I think passing res->usage
> > > is overkilling.
> > 
> > So, how many pages should be reclaimed then?
> > 
> 
> How about (1 << (MAX_ORDER-1))/loop ?

Hmm, I am not sure I see any benefit. We want to reclaim all those
pages why shouldn't we do it in one batch? If we use a value based on
MAX_ORDER then we make a bigger chance that force_empty fails for big
cgroups (e.g. with a lot of page cache).
Anyway, if we want to mimic the previous behavior then we should use
something like nr_nodes * SWAP_CLUSTER_MAX (the above value would be
sufficient for up to 32 nodes).

> 
> Thanks,
> -Kame

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
