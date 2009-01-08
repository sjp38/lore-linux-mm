Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E9A416B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 23:58:34 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n084wUDE012920
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 13:58:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C854145DE56
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:58:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DE5645DE51
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:58:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8240D1DB805D
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:58:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 352821DB803C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 13:58:30 +0900 (JST)
Date: Thu, 8 Jan 2009 13:57:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups
Message-Id: <20090108135728.cdb20fe2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090108044108.GG7294@balbir.in.ibm.com>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	<20090107184128.18062.96016.sendpatchset@localhost.localdomain>
	<20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108042558.GC7294@balbir.in.ibm.com>
	<20090108132855.77d3d3d4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108044108.GG7294@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jan 2009 10:11:08 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 13:28:55]:
> 
> > On Thu, 8 Jan 2009 09:55:58 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 10:11:48]:
> > > > Hmm,  Could you clarify following ?
> > > >   
> > > >   - Usage of memory at insertsion and usage of memory at reclaim is different.
> > > >     So, this *sorted* order by RB-tree isn't the best order in general.
> > > 
> > > True, but we frequently update the tree at an interval of HZ/4.
> > > Updating at every page fault sounded like an overkill and building the
> > > entire tree at reclaim is an overkill too.
> > > 
> > "sort" is not necessary.
> > If this feature is implemented as background daemon,
> > just select the worst one at each iteration is enough.
> 
> OK, definitely an alternative worth considering, but the trade-off is
> lazy building (your suggestion), which involves actively seeing the
> usage of all cgroups (and if they are large, O(c), c is number of
> cgroups can be quite a bit) versus building the tree as and when the
> fault occurs and controlled by some interval.
> 
I never think there will be "thousands" of memcg. O(c) is not so bad
if it's on background.

But usual cost of adding res_counter_soft_limit_excess(&mem->res); is big...
This maintainance cost of tree is always necessary even while there are no
memory shortage.

BTW, 
- mutex is bad. Can you use mutex while __GFP_WAIT is unset ?

- what happens when a big uncharge() occurs and no new charge() happens ?
  please add

   +		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
		if ( mem is still over soft limit )
			do reclaim....

   at least.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
