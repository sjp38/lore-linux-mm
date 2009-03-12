Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 739026B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 23:52:52 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C3qnhQ005914
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 12:52:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4F1645DE4E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:52:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 63C5145DE50
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:52:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 818AFE0800D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:52:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ECECE08006
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 12:52:46 +0900 (JST)
Date: Thu, 12 Mar 2009 12:51:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
Message-Id: <20090312125124.06af6ad9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312034918.GB23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312095516.53a2d029.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312034918.GB23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:19:18 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:55:16]:
> 
> > Andrew, this [1/5] is a bug fix, others are not.
> > 
> > ==
> > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > 
> > Even when page reclaim is under mem_cgroup, # of scan page is determined by
> > status of global LRU. Fix that.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: mmotm-2.6.29-Mar10/mm/vmscan.c
> > ===================================================================
> > --- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
> > +++ mmotm-2.6.29-Mar10/mm/vmscan.c
> > @@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, st
> >  		int file = is_file_lru(l);
> >  		int scan;
> > 
> > -		scan = zone_page_state(zone, NR_LRU_BASE + l);
> > +		scan = zone_nr_pages(zone, sc, l);
> 
> I have the exact same patch in my patch queue. BTW, mem_cgroup_zone_nr_pages is
> buggy. We don't hold any sort of lock while extracting
> MEM_CGROUP_ZSTAT (ideally we need zone->lru_lock). Without that how do
> we guarantee that MEM_CGRUP_ZSTAT is not changing at the same time as
> we are reading it?
> 
Is it big problem ? We don't need very precise value and ZSTAT just have
increment/decrement. So, I tend to ignore this small race.
(and it's unsigned long, not long long.)

Thanks,
-Kame


> >  		if (priority) {
> >  			scan >>= priority;
> >  			scan = (scan * percent[file]) / 100;
> > 
> > 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
