Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EA0046B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 00:27:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D3BEE3EE0BB
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 14:27:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BC27A45DE50
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 14:27:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FE3E45DE4D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 14:27:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 937321DB802F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 14:27:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 435171DB8037
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 14:27:56 +0900 (JST)
Date: Wed, 18 Jan 2012 14:26:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-Id: <20120118142638.11667d2c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120113121645.GA1653@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
	<1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
	<20120112105427.4b80437b.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113121645.GA1653@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Jan 2012 13:16:56 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Jan 12, 2012 at 10:54:27AM +0900, KAMEZAWA Hiroyuki wrote:

> > Thank you for your work and the result seems atractive and code is much
> > simpler. My small concerns are..
> > 
> > 1. This approach may increase latency of direct-reclaim because of priority=0.
> 
> I think strictly speaking yes, but note that with kswapd being less
> likely to get stuck in hammering on one group, the need for allocators
> to enter direct reclaim itself is reduced.
> 
> However, if this really becomes a problem in real world loads, the fix
> is pretty easy: just ignore the soft limit for direct reclaim.  We can
> still consider it from hard limit reclaim and kswapd.
> 
> > 2. In a case numa-spread/interleave application run in its own container, 
> >    pages on a node may paged-out again and again becasue of priority=0
> >    if some other application runs in the node.
> >    It seems difficult to use soft-limit with numa-aware applications.
> >    Do you have suggestions ?
> 
> This is a question about soft limits in general rather than about this
> particular patch, right?
> 

Partially, yes. My concern is related to "1".

Assume an application is binded to some cpu/node and try to allocate memory.
If its memcg's usage is over softlimit, this application will play bad because
newly allocated memory will be reclaim target soon, again....


> And if I understand correctly, the problem you are referring to is
> this: an application and parts of a soft-limited container share a
> node, the soft limit setting means that the container's pages on that
> node are reclaimed harder.  At that point, the container's share on
> that node becomes tiny, but since the soft limit is oblivious to
> nodes, the expansion of the other application pushes the soft-limited
> container off that node completely as long as the container stays
> above its soft limit with the usage on other nodes.
> 
> What would you think about having node-local soft limits that take the
> node size into account?
> 
> 	local_soft_limit = soft_limit * node_size / memcg_size
> 
> The soft limit can be exceeded globally, but the container is no
> longer pushed off a node on which it's only occupying a small share of
> memory.
> 
Yes, I think this kind of care is required.
What is the 'node_size' here ? size of pgdat ?
size of per-node usage in the memcg ?


> Putting it into proportion of the memcg size, not overall memory size
> has the following advantages:
> 
>   1. if the container is sitting on only one of several available
>   nodes without exceeding the limit globally, the memcg will not be
>   reclaimed harder just because it has a relatively large share of the
>   node.
> 
>   2. if the soft limit excess is ridiculously high, the local soft
>   limits will be pushed down, so the tolerance for smaller shares on
>   nodes goes down in proportion to the global soft limit excess.
> 
> Example:
> 
> 	4G soft limit * 2G node / 4G container = 2G node-local limit
> 
> The container is globally within its soft limit, so the local limit is
> at least the size of the node.  It's never reclaimed harder compared
> to other applications on the node.
> 
> 	4G soft limit * 2G node / 5G container = ~1.6G node-local limit
> 



> Here, it will experience more pressure initially, but it will level
> off when the shrinking usage and the thereby increasing node-local
> soft limit meet.  From that point on, the container and the competing
> application will be treated equally during reclaim.
> 
> Finally, if the container is 16G in size, i.e. 300% in excess, the
> per-node tolerance is at 512M node-local soft limit, which IMO strikes
> a good balance between zero tolerance and still applying some stress
> to the hugely oversized container when other applications (with
> virtually unlimited soft limits) want to run on the same node.
> 
> What do you think?

I like the idea. Another idea is changing 'priority' based on per-node stats
if not too complicated...

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
