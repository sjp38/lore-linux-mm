Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 564356B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:01:14 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2C40nlH003823
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:00:49 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C41HBB401456
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:01:17 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2C40xms022506
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:00:59 +1100
Date: Thu, 12 Mar 2009 09:30:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
Message-ID: <20090312040054.GE23583@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312095516.53a2d029.kamezawa.hiroyu@jp.fujitsu.com> <20090312034918.GB23583@balbir.in.ibm.com> <20090312125124.06af6ad9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312125124.06af6ad9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 12:51:24]:

> On Thu, 12 Mar 2009 09:19:18 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:55:16]:
> > 
> > > Andrew, this [1/5] is a bug fix, others are not.
> > > 
> > > ==
> > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > 
> > > Even when page reclaim is under mem_cgroup, # of scan page is determined by
> > > status of global LRU. Fix that.
> > > 
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  mm/vmscan.c |    2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > Index: mmotm-2.6.29-Mar10/mm/vmscan.c
> > > ===================================================================
> > > --- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
> > > +++ mmotm-2.6.29-Mar10/mm/vmscan.c
> > > @@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, st
> > >  		int file = is_file_lru(l);
> > >  		int scan;
> > > 
> > > -		scan = zone_page_state(zone, NR_LRU_BASE + l);
> > > +		scan = zone_nr_pages(zone, sc, l);
> > 
> > I have the exact same patch in my patch queue. BTW, mem_cgroup_zone_nr_pages is
> > buggy. We don't hold any sort of lock while extracting
> > MEM_CGROUP_ZSTAT (ideally we need zone->lru_lock). Without that how do
> > we guarantee that MEM_CGRUP_ZSTAT is not changing at the same time as
> > we are reading it?
> > 
> Is it big problem ? We don't need very precise value and ZSTAT just have
> increment/decrement. So, I tend to ignore this small race.
> (and it's unsigned long, not long long.)
>

The assumption is that unsigned long read is atomic even on 32 bit
systems? What if we get pre-empted in the middle of reading the data
and don't return back for long? The data can be highly in-accurate.
No? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
