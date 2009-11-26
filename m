Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AA06A6B0099
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 20:17:36 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ1HXWR018142
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Nov 2009 10:17:33 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BDDC45DE56
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:17:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 691A945DE4F
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:17:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C1DD1DB8038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:17:33 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E676F1DB8037
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:17:32 +0900 (JST)
Date: Thu, 26 Nov 2009 10:14:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: slab control
Message-Id: <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 2009 15:08:00 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Hi,
> 
> I wanted to see what the current ideas are concerning kernel memory 
> accounting as it relates to the memory controller.  Eventually we'll want 
> the ability to restrict cgroups to a hard slab limit.  That'll require 
> accounting to map slab allocations back to user tasks so that we can 
> enforce a policy based on the cgroup's aggregated slab usage similiar to 
> how the memory controller currently does for user memory.
> 
> Is this currently being thought about within the memcg community? 

Not yet. But I always recommend people to implement another memcg (slabcg) for
kernel memory. Because

  - It must have much lower cost than memcg, good perfomance and scalability.
    system-wide shared counter is nonsense.

  - slab is not base on LRU. So, another used-memory maintainance scheme should
    be used.

  - You can reuse page_cgroup even if slabcg is independent from memcg.


But, considering user-side, all people will not welcome dividing memcg and slabcg.
So, tieing it to current memcg is ok for me.
like...
==
	struct mem_cgroup {
		....
		....
		struct slab_cgroup slabcg; (or struct slab_cgroup *slabcg)
	}
==

But we have to use another counter and another scheme, another implemenation
than memcg, which has good scalability and more fuzzy/lazy controls.
(For example, trigger slab-shrink when usage exceeds hiwatermark, not limit.)

Scalable accounting is the first wall in front of us. Second one will be
how-to-shrink. About information recording, we can reuse page_cgroup and
we'll not have much difficulty.

I hope, at implementing slabcg, we'll not meet very complicated
racy cases as what we met in memcg. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
