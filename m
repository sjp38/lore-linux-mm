Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 700646B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 05:21:14 -0400 (EDT)
Date: Wed, 31 Aug 2011 10:33:32 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-ID: <20110831083332.GA27125@redhat.com>
References: <20110830070424.GA13061@redhat.com>
 <20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830084245.GC13061@redhat.com>
 <20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830101726.GD13061@redhat.com>
 <20110830193839.cf0fc597.kamezawa.hiroyu@jp.fujitsu.com>
 <20110830113221.GF13061@redhat.com>
 <20110831082924.f9b20959.kamezawa.hiroyu@jp.fujitsu.com>
 <20110831062354.GA355@redhat.com>
 <20110831153025.895997bf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110831153025.895997bf.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2011 at 03:30:25PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 31 Aug 2011 08:23:54 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > On Wed, Aug 31, 2011 at 08:29:24AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 30 Aug 2011 13:32:21 +0200
> > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > 
> > > > On Tue, Aug 30, 2011 at 07:38:39PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > On Tue, 30 Aug 2011 12:17:26 +0200
> > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > > 
> > > > > > On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > > On Tue, 30 Aug 2011 10:42:45 +0200
> > > > > > > Johannes Weiner <jweiner@redhat.com> wrote:
> >
> > > I'm confused. 
> > > 
> > > If vmscan is scanning in C's LRU,
> > > 	(memcg == root) : C_scan_internal ++
> > > 	(memcg != root) : C_scan_external ++
> > 
> > Yes.
> > 
> > > Why A_scan_external exists ? It's 0 ?
> > > 
> > > I think we can never get numbers.
> > 
> > Kswapd/direct reclaim should probably be accounted as A_external,
> > since A has no limit, so reclaim pressure can not be internal.
> > 
> 
> hmm, ok. All memory pressure from memcg/system other than the memcg itsef
> is all external.
>
> > On the other hand, one could see the amount of physical memory in the
> > machine as A's limit and account global reclaim as A_internal.
> > 
> > I think the former may be more natural.
> > 
> > That aside, all memcgs should have the same statistics, obviously.
> > Scripts can easily deal with counters being zero.  If items differ
> > between cgroups, that would suck a lot.
> 
> So, when I improve direct-reclaim path, I need to see score in scan_internal.

Direct reclaim because of the limit or because of global pressure?  I
am going to assume because of the limit because global reclaim is not
yet accounted to memcgs even though their pages are scanned.  Please
correct me if I'm wrong.

        A
       /
      B
     /
    C

If A hits the limit and does direct reclaim in A, B, and C, then the
scans in A get accounted as internal while the scans in B and C get
accounted as external.

> How do you think about background-reclaim-per-memcg ?
> Should be counted into scan_internal ?

Background reclaim is still triggered by the limit, just that the
condition is 'close to limit' instead of 'reached limit'.

So when per-memcg background reclaim goes off because A is close to
its limit, then it will scan A (internal) and B + C (external).

It's always the same code:

	record_reclaim_stat(culprit, victim, item, delta)

In direct limit reclaim, the culprit is the one hitting its limit.  In
background reclaim, the culprit is the one getting close to its limit.

And then again the accounting is

	culprit == victim -> victim_internal++ (own fault)
	culprit != victim -> victim_external++ (parent's fault)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
