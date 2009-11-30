Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 559FD600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 17:55:33 -0500 (EST)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id nAUMtTWI021009
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 22:55:30 GMT
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by zps75.corp.google.com with ESMTP id nAUMtQte011143
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:55:26 -0800
Received: by pzk1 with SMTP id 1so3133664pzk.33
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 14:55:26 -0800 (PST)
Date: Mon, 30 Nov 2009 14:55:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: memcg: slab control
In-Reply-To: <4B0E461C.50606@parallels.com>
Message-ID: <alpine.DEB.2.00.0911301447400.7131@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com> <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com> <20091126085031.GG2970@balbir.in.ibm.com> <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E461C.50606@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009, Pavel Emelyanov wrote:

> I'm ready to resurrect the patches and port them for slab.
> But before doing it we should answer one question.
> 

Do you have a pointer to your latest implementation that you proposed for 
slab?

> Consider we have two kmalloc-s in a kernel code - one is
> user-space triggerable and the other one is not. From my
> POV we should account for the former one, but should not
> for the latter.
> 
> If so - how should we patch the kernel to achieve that goal?
> 

I think all slab allocations should be accounted for based on current's 
memcg other than those done in hardirq context, annotating slab 
allocations doesn't seem scalable.  Whether the accounting is done on a 
task level or cgroup level isn't really a problem for us since we don't 
move tasks amongst cgroups.  I imagine there've been previous restrictions 
on that put into place with the memcg so this doesn't seem like a 
slabcg-specific requirement anyway.

The problem on the freeing side is mapping the object back to the cgroup 
that allocated it.  We'd also need to map the object to the context in 
which it was allocated to determine whether we should decrement the 
counter or not.  How do you propose doing that without a considerable 
overhead in memory consumption, fastpath branch, and cache cold slabcg 
lookups?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
