Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B43E76B0011
	for <linux-mm@kvack.org>; Sun,  8 May 2011 22:37:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 996A93EE0C7
	for <linux-mm@kvack.org>; Mon,  9 May 2011 11:37:07 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 762B645DF48
	for <linux-mm@kvack.org>; Mon,  9 May 2011 11:37:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AF2F45DF4B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 11:37:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49292E08006
	for <linux-mm@kvack.org>; Mon,  9 May 2011 11:37:07 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0999B1DB803E
	for <linux-mm@kvack.org>; Mon,  9 May 2011 11:37:07 +0900 (JST)
Date: Mon, 9 May 2011 11:30:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv2] memcg: reclaim memory from node in round-robin
Message-Id: <20110509113031.fa4263df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110509112215.3ACD.A69D9226@jp.fujitsu.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509112215.3ACD.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Mon,  9 May 2011 11:20:31 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > I changed the logic a little and add a filter for skipping nodes.
> > With large NUMA, tasks may under cpuset or mempolicy and the usage of memory
> > can be unbalanced. So, I think a filter is required.
> > 
> > ==
> > Now, memory cgroup's direct reclaim frees memory from the current node.
> > But this has some troubles. In usual, when a set of threads works in
> > cooperative way, they are tend to on the same node. So, if they hit
> > limits under memcg, it will reclaim memory from themselves, it may be
> > active working set.
> > 
> > For example, assume 2 node system which has Node 0 and Node 1
> > and a memcg which has 1G limit. After some work, file cacne remains and
> > and usages are
> >    Node 0:  1M
> >    Node 1:  998M.
> > 
> > and run an application on Node 0, it will eats its foot before freeing
> > unnecessary file caches.
> > 
> > This patch adds round-robin for NUMA and adds equal pressure to each
> > node. When using cpuset's spread memory feature, this will work very well.
> 
> Looks nice. And it would be more nice if global reclaim has the same feature.
> Do you have a plan to do it?
> 

Hmm, IIUC, at allocating memory for file-cache, we may be able to avoid starting
from current node. But, isn't it be a feature of cpuset ? 
If cpuset.memory_spread_page==1 and a page for file is allocated from a node in
round-robin, and memory reclaim runs in such manner (using node-only zonelist
fallabck).

Do you mean the kernel should have a knob for allowing non-local allocation for
file caches even without cpuset ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
