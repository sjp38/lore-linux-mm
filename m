Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50C936B0096
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 07:32:02 -0500 (EST)
Message-ID: <4B0E7530.8050304@parallels.com>
Date: Thu, 26 Nov 2009 15:31:44 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>	 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>	 <20091126085031.GG2970@balbir.in.ibm.com>	 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>	 <4B0E461C.50606@parallels.com>	 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>	 <4B0E50B1.20602@parallels.com> <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com>
In-Reply-To: <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Suleiman Souhlal <suleiman@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, David Rientjes <rientjes@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Aren't there patches to make the kernel track which cgroup caused
> which disk I/O? If so, it should be possible to charge the bios to the
> right cgroup.
> 
> Maybe one way to decide which kernel allocations should be accounted
> would be to look at the calling context: If the allocation is done in
> user context (syscall), then it could be counted towards that user,
> while if the allocation is done in interrupt or kthread context, it
> shouldn't be accounted.
> 
> Of course, this wouldn't be perfect, but it might be a good enough
> approximation.

I disagree. Bio-s are allocated in user context for all typical reads
(unless we requested aio) and are allocated either in pdflush context
or (!) in arbitrary task context for writes (e.g. via try_to_free_pages)
and thus such bio/buffer_head accounting will be completely random.

One of the way to achieve the goal I can propose the following (it's
not perfect, but just smth to start discussion from).

We implement support for accounting based on a bit on a kmem_cache
structure and mark all kmalloc caches as not-accountable. Then we grep
the kernel to find all kmalloc-s and think - if a kmalloc is to be
accounted we turn this into kmem_cache_alloc() with dedicated
kmem_cache and mark it as accountable.

> -- Suleiman
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
