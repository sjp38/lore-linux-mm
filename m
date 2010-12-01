Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 776136B0088
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:32:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10Wild017504
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:32:44 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E55F45DE53
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:32:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFF3845DE51
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:32:42 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BC67A1DB805E
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:32:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38888E18003
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:32:42 +0900 (JST)
Date: Wed, 1 Dec 2010 09:27:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Add per cgroup reclaim watermarks.
Message-Id: <20101201092701.182a9980.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTik2Sy0MzGAsZyDHsoZYKUpdJ7kS7nFM1QX_ioZR@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-3-git-send-email-yinghan@google.com>
	<20101130162133.970dc0cd.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik2Sy0MzGAsZyDHsoZYKUpdJ7kS7nFM1QX_ioZR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 12:44:13 -0800
Ying Han <yinghan@google.com> wrote:

> On Mon, Nov 29, 2010 at 11:21 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 29 Nov 2010 22:49:43 -0800
> > Ying Han <yinghan@google.com> wrote:
> >
> >> The per cgroup kswapd is invoked at mem_cgroup_charge when the cgroup's memory
> >> usage above a threshold--low_wmark. Then the kswapd thread starts to reclaim
> >> pages in a priority loop similar to global algorithm. The kswapd is done if the
> >> memory usage below a threshold--high_wmark.
> >>
> >> The per cgroup background reclaim is based on the per cgroup LRU and also adds
> >> per cgroup watermarks. There are two watermarks including "low_wmark" and
> >> "high_wmark", and they are calculated based on the limit_in_bytes(hard_limit)
> >> for each cgroup. Each time the hard_limit is change, the corresponding wmarks
> >> are re-calculated. Since memory controller charges only user pages, there is
> >> no need for a "min_wmark". The current calculation of wmarks is a function of
> >> "memory.min_free_kbytes" which could be adjusted by writing different values
> >> into the new api. This is added mainly for debugging purpose.
> >>
> >> Signed-off-by: Ying Han <yinghan@google.com>
> >
> > A few points.
> >
> > 1. I can understand the motivation for including low/high watermark to
> > A  res_coutner. But, sadly, compareing all charge will make the counter slow.
> > A  IMHO, as memory controller threshold-check or soft limit, checking usage
> > A  periodically based on event counter is enough. It will be low cost.
> 
> If we have other limits using the event counter, this sounds a
> feasible try for the
> wmarks. I can look into that.
> 
> >
> > 2. min_free_kbytes must be automatically calculated.
> > A  For example, max(3% of limit, 20MB) or some.
> 
> Now the wmark is automatically calculated based on the limit. Adding
> the min_free_kbytes gives
> us more flexibility to adjust the portion of the threshold. This could
> just be a performance tuning
> parameter later. I need it now at least at the beginning before
> figuring out a reasonable calculation
> formula.
> 
mm/page_alloc.c::init_per_zone_wmark_min() can be reused.

My question is.

> >> +void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> >> +{
> >> + A  A  u64 limit;
> >> + A  A  unsigned long min_free_kbytes;
> >> +
> >> + A  A  min_free_kbytes = get_min_free_kbytes(mem);
> >> + A  A  limit = mem_cgroup_get_limit(mem);
> >> + A  A  if (min_free_kbytes == 0) {

I think this min_free_kbyte is always 0 until a user set it.
Please set this when the limit is changed, automatically.

I wonder
	struct mem_cgroup {

		unsigned long min_free_kbytes;
		unsigned long min_free_kbytes_user_set; /* use this always if set */
	}
may be necessary if we never adjust min_free_kbytes once a user set it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
