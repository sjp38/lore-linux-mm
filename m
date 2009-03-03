Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E8216B0047
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 21:43:54 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n232hppr000386
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 3 Mar 2009 11:43:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E631E45DE55
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:43:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2B1745DE51
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:43:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A1C44E18005
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:43:50 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E9C21DB803A
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:43:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v3)
In-Reply-To: <20090302044406.GD11421@balbir.in.ibm.com>
References: <20090302120052.6FEC.A69D9226@jp.fujitsu.com> <20090302044406.GD11421@balbir.in.ibm.com>
Message-Id: <20090303095833.D9FC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  3 Mar 2009 11:43:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-02 12:08:01]:
> 
> > Hi Balbir,
> > 
> > > @@ -2015,9 +2016,12 @@ static int kswapd(void *p)
> > >  		finish_wait(&pgdat->kswapd_wait, &wait);
> > >  
> > >  		if (!try_to_freeze()) {
> > > +			struct zonelist *zl = pgdat->node_zonelists;
> > >  			/* We can speed up thawing tasks if we don't call
> > >  			 * balance_pgdat after returning from the refrigerator
> > >  			 */
> > > +			if (!order)
> > > +				mem_cgroup_soft_limit_reclaim(zl, GFP_KERNEL);
> > >  			balance_pgdat(pgdat, order);
> > >  		}
> > >  	}
> > 
> > kswapd's roll is increasing free pages until zone->pages_high in "own node".
> > mem_cgroup_soft_limit_reclaim() free one (or more) exceed page in any node.
> > 
> > Oh, well.
> > I think it is not consistency.
> > 
> > if mem_cgroup_soft_limit_reclaim() is aware to target node and its pages_high,
> > I'm glad.
> 
> Yes, correct the role of kswapd is to keep increasing free pages until
> zone->pages_high and the first set of pages to consider is the memory
> controller over their soft limits. We pass the zonelist to ensure that
> while doing soft reclaim, we focus on the zonelist associated with the
> node. Kamezawa had concernes over calling the soft limit reclaim from
> __alloc_pages_internal(), did you prefer that call path? 

I read your patch again.
So, mem_cgroup_soft_limit_reclaim() caller place seems in balance_pgdat() is better.

Please imazine most bad scenario.
CPU0 (kswapd) take to continue shrinking.
CPU1 take another activity and charge memcg conteniously.
At that time, balance_pgdat() don't exit very long time. then 
mem_cgroup_soft_limit_reclaim() is never called.

In ideal, if another cpu take another charge, kswapd should shrink 
soft limit again.


btw, I don't like "if (!order)" condition. memcg soft limit sould be
always shrinked although 
it's the order of because wakeup_kswapd() argument is merely hint.

another process want another order.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
