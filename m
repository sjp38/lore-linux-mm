Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 767BF600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 17:45:54 -0500 (EST)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id nAUMjqC9011280
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:45:53 -0800
Received: from pxi39 (pxi39.prod.google.com [10.243.27.39])
	by zps75.corp.google.com with ESMTP id nAUMjmCj000960
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:45:50 -0800
Received: by pxi39 with SMTP id 39so3268220pxi.2
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:45:48 -0800 (PST)
Date: Mon, 30 Nov 2009 14:45:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: memcg: slab control
In-Reply-To: <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911301434480.7131@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com> <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009, KAMEZAWA Hiroyuki wrote:

> But, considering user-side, all people will not welcome dividing memcg and slabcg.
> So, tieing it to current memcg is ok for me.

Agreed.

> like...
> ==
> 	struct mem_cgroup {
> 		....
> 		....
> 		struct slab_cgroup slabcg; (or struct slab_cgroup *slabcg)
> 	}
> ==
> 
> But we have to use another counter and another scheme, another implemenation
> than memcg, which has good scalability and more fuzzy/lazy controls.
> (For example, trigger slab-shrink when usage exceeds hiwatermark, not limit.)
> 

We're only really interested in using memcg and slabcg together for 
accounting all memory allotted to a particular cgroup.  I'm trying to 
imagine a scenario where someone would want to account and enforce hard 
slab limits without using memcg as well.  If there are none (and one of 
the reasons we're trying to illicit discussion is to determine everyone's 
requirements for such a feature), we can probably tie them together 
without worrying about incurring unnecessary overhead by using the memcg 
framework that isn't related to slab accounting.

I think the ideal userspace API would be simply to add slab accounting to 
the memcg's limit_in_bytes if a memcg option were enabled for a cgroup.  I 
don't think it would be helpful to add a ratio of that limit for slab, 
though, since it's very difficult to predict the usage for a particular 
workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
