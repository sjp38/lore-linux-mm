Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 759FB6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 03:46:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C7k1xB010317
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 16:46:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 309FA45DD7B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:46:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0608245DD7E
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:46:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D267CE08009
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:46:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E0F9E08008
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:46:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
In-Reply-To: <20090312131739.296785da.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090312041414.GG23583@balbir.in.ibm.com> <20090312131739.296785da.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090312164204.43B7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 16:45:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 12 Mar 2009 09:44:14 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 13:05:56]:
> > 
> > > On Thu, 12 Mar 2009 09:30:54 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 12:51:24]:
> > > > 
> > > > > On Thu, 12 Mar 2009 09:19:18 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:55:16]:
> > > > > > 
> > > > > > > Andrew, this [1/5] is a bug fix, others are not.
> > > > > > > 
> > > > > > > ==
> > > > > > > From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > > 
> > > > > > > Even when page reclaim is under mem_cgroup, # of scan page is determined by
> > > > > > > status of global LRU. Fix that.
> > > > > > > 
> > > > > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > > > > ---
> > > > > > >  mm/vmscan.c |    2 +-
> > > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > > 
> > > > > > > Index: mmotm-2.6.29-Mar10/mm/vmscan.c
> > > > > > > ===================================================================
> > > > > > > --- mmotm-2.6.29-Mar10.orig/mm/vmscan.c
> > > > > > > +++ mmotm-2.6.29-Mar10/mm/vmscan.c
> > > > > > > @@ -1470,7 +1470,7 @@ static void shrink_zone(int priority, st
> > > > > > >  		int file = is_file_lru(l);
> > > > > > >  		int scan;
> > > > > > > 
> > > > > > > -		scan = zone_page_state(zone, NR_LRU_BASE + l);
> > > > > > > +		scan = zone_nr_pages(zone, sc, l);
> > > > > > 
> > > > > > I have the exact same patch in my patch queue. BTW, mem_cgroup_zone_nr_pages is
> > > > > > buggy. We don't hold any sort of lock while extracting
> > > > > > MEM_CGROUP_ZSTAT (ideally we need zone->lru_lock). Without that how do
> > > > > > we guarantee that MEM_CGRUP_ZSTAT is not changing at the same time as
> > > > > > we are reading it?
> > > > > > 
> > > > > Is it big problem ? We don't need very precise value and ZSTAT just have
> > > > > increment/decrement. So, I tend to ignore this small race.
> > > > > (and it's unsigned long, not long long.)
> > > > >
> > > > 
> > > > The assumption is that unsigned long read is atomic even on 32 bit
> > > > systems? What if we get pre-empted in the middle of reading the data
> > > > and don't return back for long? The data can be highly in-accurate.
> > > > No? 
> > > > 
> > > Hmm,  preempt_disable() is appropriate ?
> > > 
> > > But shrink_zone() itself works on the value which is read at this time and
> > > dont' take care of changes in situation by preeemption...so it's not problem
> > > of memcg.
> > >
> > 
> > You'll end up reclaiming based on old stale data. shrink_zone itself
> > maintains atomic data for zones.
> > 
> IIUC, # of pages to be scanned is just determined once, here.

In this case, lockless is right behavior.
lockless is valuable than precise ZSTAT. end user can't observe this race.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
