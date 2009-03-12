Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8626B6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 05:45:40 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2C9jXAm011045
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:15:33 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C9je2k4358356
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:15:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2C9jWjF022031
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 20:45:32 +1100
Date: Thu, 12 Mar 2009 15:15:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
Message-ID: <20090312094529.GA4335@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312041414.GG23583@balbir.in.ibm.com> <20090312131739.296785da.kamezawa.hiroyu@jp.fujitsu.com> <20090312164204.43B7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312164204.43B7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-12 16:45:59]:

> > On Thu, 12 Mar 2009 09:44:14 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 13:05:56]:
> > > 
> > > > On Thu, 12 Mar 2009 09:30:54 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 12:51:24]:
> > > > > 
> > > > > > On Thu, 12 Mar 2009 09:19:18 +0530
> > > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > > 
> > > > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:55:16]:
> > > > > > > 
> > > > > > > > Andrew, this [1/5] is a bug fix, others are not.
> > > > > > > > 
> > > > > > > > ==
> > > > > > > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > > > 
> > > > > > > > Even when page reclaim is under mem_cgroup, # of scan page is determined by
> > > > > > > > status of global LRU. Fix that.
> > > > > > > > 
> > > > > > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > > > > ---
> > > > > > > >  mm/vmscan.c |    2 +-
> > > > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > > > 
> > > > > > > > Index: mmotm-2.6.29-Mar10/mm/vmscan.c
> > > > > > > > ===================================================================
> > > > > > > > --- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
> > > > > > > > +++ mmotm-2.6.29-Mar10/mm/vmscan.c
> > > > > > > > @@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, st
> > > > > > > >  		int file = is_file_lru(l);
> > > > > > > >  		int scan;
> > > > > > > > 
> > > > > > > > -		scan = zone_page_state(zone, NR_LRU_BASE + l);
> > > > > > > > +		scan = zone_nr_pages(zone, sc, l);
> > > > > > > 
> > > > > > > I have the exact same patch in my patch queue. BTW, mem_cgroup_zone_nr_pages is
> > > > > > > buggy. We don't hold any sort of lock while extracting
> > > > > > > MEM_CGROUP_ZSTAT (ideally we need zone->lru_lock). Without that how do
> > > > > > > we guarantee that MEM_CGRUP_ZSTAT is not changing at the same time as
> > > > > > > we are reading it?
> > > > > > > 
> > > > > > Is it big problem ? We don't need very precise value and ZSTAT just have
> > > > > > increment/decrement. So, I tend to ignore this small race.
> > > > > > (and it's unsigned long, not long long.)
> > > > > >
> > > > > 
> > > > > The assumption is that unsigned long read is atomic even on 32 bit
> > > > > systems? What if we get pre-empted in the middle of reading the data
> > > > > and don't return back for long? The data can be highly in-accurate.
> > > > > No? 
> > > > > 
> > > > Hmm,  preempt_disable() is appropriate ?
> > > > 
> > > > But shrink_zone() itself works on the value which is read at this time and
> > > > dont' take care of changes in situation by preeemption...so it's not problem
> > > > of memcg.
> > > >
> > > 
> > > You'll end up reclaiming based on old stale data. shrink_zone itself
> > > maintains atomic data for zones.
> > > 
> > IIUC, # of pages to be scanned is just determined once, here.
> 
> In this case, lockless is right behavior.
> lockless is valuable than precise ZSTAT. end user can't observe this race.
>

Lockless works fine provided the data is correctly aligned. I need to
check this out more thoroghly.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
