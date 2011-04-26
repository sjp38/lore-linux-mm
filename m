Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1498D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 21:49:43 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AFC1A3EE0C3
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:49:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92B9E45DE9A
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:49:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BF9145DE93
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:49:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 559FCE18004
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:49:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F51BE08007
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:49:40 +0900 (JST)
Date: Tue, 26 Apr 2011 10:43:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] memcg fix scan ratio with small memcg.
Message-Id: <20110426104304.4d32ce03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinLbssMOgmak+pUmhZpfuqveEDTLA@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425183426.6a791ec9.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinLbssMOgmak+pUmhZpfuqveEDTLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, 25 Apr 2011 10:35:39 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Apr 25, 2011 at 2:34 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> >
> > At memcg memory reclaim, get_scan_count() may returns [0, 0, 0, 0]
> > and no scan was not issued at the reclaim priority.
> >
> > The reason is because memory cgroup may not be enough big to have
> > the number of pages, which is greater than 1 << priority.
> >
> > Because priority affects many routines in vmscan.c, it's better
> > to scan memory even if usage >> priority < 0.
> > From another point of view, if memcg's zone doesn't have enough memory
> > which
> > meets priority, it should be skipped. So, this patch creates a temporal
> > priority
> > in get_scan_count() and scan some amount of pages even when
> > usage is small. By this, memcg's reclaim goes smoother without
> > having too high priority, which will cause unnecessary congestion_wait(),
> > etc.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    6 ++++++
> >  mm/memcontrol.c            |    5 +++++
> >  mm/vmscan.c                |   11 +++++++++++
> >  3 files changed, 22 insertions(+)
> >
> > Index: memcg/include/linux/memcontrol.h
> > ===================================================================
> > --- memcg.orig/include/linux/memcontrol.h
> > +++ memcg/include/linux/memcontrol.h
> > @@ -152,6 +152,7 @@ unsigned long mem_cgroup_soft_limit_recl
> >                                                gfp_t gfp_mask,
> >                                                unsigned long
> > *total_scanned);
> >  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> > +u64 mem_cgroup_get_usage(struct mem_cgroup *mem);
> >
> >  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item
> > idx);
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > @@ -357,6 +358,11 @@ u64 mem_cgroup_get_limit(struct mem_cgro
> >        return 0;
> >  }
> >
> > +static inline u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
> > +{
> > +       return 0;
> > +}
> > +
> >
> 
> should be  mem_cgroup_get_usage()
> 

Ah, yes. thanks.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
