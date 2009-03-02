Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 471D76B00BB
	for <linux-mm@kvack.org>; Sun,  1 Mar 2009 23:44:27 -0500 (EST)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id n224gfP1027578
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 15:42:41 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n224ibCd413842
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 15:44:38 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n224iJxn019974
	for <linux-mm@kvack.org>; Mon, 2 Mar 2009 15:44:19 +1100
Date: Mon, 2 Mar 2009 10:14:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v3)
Message-ID: <20090302044406.GD11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090301062959.31557.31079.sendpatchset@localhost.localdomain> <20090301063041.31557.86588.sendpatchset@localhost.localdomain> <20090302120052.6FEC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090302120052.6FEC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-02 12:08:01]:

> Hi Balbir,
> 
> > @@ -2015,9 +2016,12 @@ static int kswapd(void *p)
> >  		finish_wait(&pgdat->kswapd_wait, &wait);
> >  
> >  		if (!try_to_freeze()) {
> > +			struct zonelist *zl = pgdat->node_zonelists;
> >  			/* We can speed up thawing tasks if we don't call
> >  			 * balance_pgdat after returning from the refrigerator
> >  			 */
> > +			if (!order)
> > +				mem_cgroup_soft_limit_reclaim(zl, GFP_KERNEL);
> >  			balance_pgdat(pgdat, order);
> >  		}
> >  	}
> 
> kswapd's roll is increasing free pages until zone->pages_high in "own node".
> mem_cgroup_soft_limit_reclaim() free one (or more) exceed page in any node.
> 
> Oh, well.
> I think it is not consistency.
> 
> if mem_cgroup_soft_limit_reclaim() is aware to target node and its pages_high,
> I'm glad.
>

Yes, correct the role of kswapd is to keep increasing free pages until
zone->pages_high and the first set of pages to consider is the memory
controller over their soft limits. We pass the zonelist to ensure that
while doing soft reclaim, we focus on the zonelist associated with the
node. Kamezawa had concernes over calling the soft limit reclaim from
__alloc_pages_internal(), did you prefer that call path? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
