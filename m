Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D4FD86B0092
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 19:07:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2407O8h000434
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 4 Mar 2009 09:07:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 90B6F45DD7A
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:07:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5062E45DD74
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:07:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16B9C1DB8041
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:07:24 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A202CE0800A
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 09:07:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v3)
In-Reply-To: <20090303111713.GQ11421@balbir.in.ibm.com>
References: <20090303095833.D9FC.A69D9226@jp.fujitsu.com> <20090303111713.GQ11421@balbir.in.ibm.com>
Message-Id: <20090304084928.FD57.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  4 Mar 2009 09:07:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir

> > > > kswapd's roll is increasing free pages until zone->pages_high in "own node".
> > > > mem_cgroup_soft_limit_reclaim() free one (or more) exceed page in any node.
> > > > 
> > > > Oh, well.
> > > > I think it is not consistency.
> > > > 
> > > > if mem_cgroup_soft_limit_reclaim() is aware to target node and its pages_high,
> > > > I'm glad.
> > > 
> > > Yes, correct the role of kswapd is to keep increasing free pages until
> > > zone->pages_high and the first set of pages to consider is the memory
> > > controller over their soft limits. We pass the zonelist to ensure that
> > > while doing soft reclaim, we focus on the zonelist associated with the
> > > node. Kamezawa had concernes over calling the soft limit reclaim from
> > > __alloc_pages_internal(), did you prefer that call path? 
> > 
> > I read your patch again.
> > So, mem_cgroup_soft_limit_reclaim() caller place seems in balance_pgdat() is better.
> > 
> > Please imazine most bad scenario.
> > CPU0 (kswapd) take to continue shrinking.
> > CPU1 take another activity and charge memcg conteniously.
> > At that time, balance_pgdat() don't exit very long time. then 
> > mem_cgroup_soft_limit_reclaim() is never called.
> > 
> 
> Yes, true... that is why I added the hooks in __alloc_pages_internal()
> in the first two revisions, but Kamezawa objected to them. In the
> scenario that you mention that balance_pgdat() is busy, if we are
> under global system memory pressure, even after freeing memory from
> soft limited cgroups, we don't have sufficient free memory. We need to
> go reclaim from the whole system. An administrator can easily avoid
> the above scenario by using hard limits on the cgroup running on CPU1.

I agree with soft limit implementation is difficult.

but I still don't like soft limit in __alloc_pages_internal().
if it does, kswapd reclaim the pages from global LRU *before*
shrinking soft limit.

again, linux reclaim policy is

	free < pages_low:  run kswapd
	free < pages_min:  foreground reclaim via __alloc_pages_internal()

then, if soft limit reclaim put into __alloc_pages_internal(),

	free < pages_low:  run kswapd
	free < pages_min:  soft limit reclaim and 
                           foreground reclaim via __alloc_pages_internal()

it seems unintetional behavior.

In addition, I still strongly oppose againt global lock although 
soft limit shrinking don't put into __alloc_pages_internal().
I think it doesn't depend on caller place.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
