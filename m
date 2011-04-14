Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 98F33900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 20:34:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E3AFF3EE0BD
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:34:32 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C934645DE58
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:34:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E56E45DE53
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:34:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89E251DB8041
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:34:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BA371DB803B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 09:34:32 +0900 (JST)
Date: Thu, 14 Apr 2011 09:27:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3 2/7] Add per memcg reclaim watermarks
Message-Id: <20110414092756.a7d8b1bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=z5F40qWgHWmzpJ6jseeGyBJ+fAQ@mail.gmail.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-3-git-send-email-yinghan@google.com>
	<20110413172502.7f7edb2c.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=z5F40qWgHWmzpJ6jseeGyBJ+fAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 13 Apr 2011 11:40:26 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 13, 2011 at 1:25 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 13 Apr 2011 00:03:02 -0700
> > Ying Han <yinghan@google.com> wrote:

> > > +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> > > +{
> > > +     u64 limit;
> > > +     unsigned long wmark_ratio;
> > > +
> > > +     wmark_ratio = get_wmark_ratio(mem);
> > > +     limit = mem_cgroup_get_limit(mem);
> > > +     if (wmark_ratio == 0) {
> > > +             res_counter_set_low_wmark_limit(&mem->res, limit);
> > > +             res_counter_set_high_wmark_limit(&mem->res, limit);
> > > +     } else {
> > > +             unsigned long low_wmark, high_wmark;
> > > +             unsigned long long tmp = (wmark_ratio * limit) / 100;
> >
> > could you make this ratio as /1000 ? percent is too big.
> > And, considering misc. cases, I don't think having per-memcg "ratio" is
> > good.
> >
> > How about following ?
> >
> >  - provides an automatic wmark without knob. 0 wmark is okay, for me.
> >  - provides 2 intrerfaces as
> >        memory.low_wmark_distance_in_bytes,  # == hard_limit - low_wmark.
> >        memory.high_wmark_in_bytes,          # == hard_limit - high_wmark.
> >   (need to add sanity check into set_limit.)
> >
> > Hmm. Making the wmarks tunable individually make sense to me. One problem I
> do notice is that making the hard_limit as the bar might not working well on
> over-committing system. Which means the per-cgroup background reclaim might
> not be triggered before global memory pressure. Ideally, we would like to do
> more per-cgroup reclaim before triggering global memory pressure.
> 
hmm.

> How about adding the two APIs but make the calculation based on:
> 
> -- by default, the wmarks are equal to hard_limit. ( no background reclaim)

ok.

> -- provides 2 intrerfaces as
>        memory.low_wmark_distance_in_bytes,  # == min(hard_limit, soft_limit)
> - low_wmark.
>        memory.high_wmark_in_bytes,          # == min(hard_limit, soft_limit)
> - high_wmark.
> 

Hmm, with that interface, soflimit=0(or some low value) will disable background
reclaim. (IOW, all memory will be reclaimed.)

IMHO, we don't need take care of softlimit v.s. high/low wmark. It's userland job.
And we cannot know global relcaim's run via memcg' memory uasge....because of
nodes and zones. I think low/high wmark should work against hard_limit.


> >
> > In this patch, kswapd runs while
> >
> >        high_wmark < usage < low_wmark
> > ?
> >
> > Hmm, I like
> >        low_wmark < usage < high_wmark.
> >
> > ;) because it's kswapd.
> >
> > I adopt the same concept of global kswapd where low_wmark triggers the
> kswpd and hight_wmark stop it. And here, we have
> 
> (limit - high_wmark) < free < (limit - low_wmark)
> 

Hm, ok. please add comment somewhere.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
