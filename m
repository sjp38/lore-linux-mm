Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D1CC60021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 17:29:22 -0500 (EST)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id nB1MTIcb031050
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 14:29:19 -0800
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by spaceape8.eur.corp.google.com with ESMTP id nB1MTFJm011813
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 14:29:15 -0800
Received: by pxi11 with SMTP id 11so4184845pxi.9
        for <linux-mm@kvack.org>; Tue, 01 Dec 2009 14:29:14 -0800 (PST)
Date: Tue, 1 Dec 2009 14:29:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: memcg: slab control
In-Reply-To: <4B14F06D.1000901@parallels.com>
Message-ID: <alpine.DEB.2.00.0912011421260.27500@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>  <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>  <20091126085031.GG2970@balbir.in.ibm.com>  <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E461C.50606@parallels.com>
  <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>  <4B0E50B1.20602@parallels.com> <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com> <4B0E7530.8050304@parallels.com> <alpine.DEB.2.00.0911301457110.7131@chino.kir.corp.google.com>
 <4B14F06D.1000901@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Suleiman Souhlal <suleiman@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 2009, Pavel Emelyanov wrote:

> > pdflush has been removed, they should all be allocated in process context.
> 
> OK, but the try_to_free_pages() concern still stands.
> 

Yes, we lack mappings between the per-bdi flusher kthreads back to the 
user cgroup that initiated the writeback.  Since all of these kthreads are 
descendents of kthreadd, they'll be accounted for within that thread's 
cgroup unless we pass along the current context.

> >> We implement support for accounting based on a bit on a kmem_cache
> >> structure and mark all kmalloc caches as not-accountable. Then we grep
> >> the kernel to find all kmalloc-s and think - if a kmalloc is to be
> >> accounted we turn this into kmem_cache_alloc() with dedicated
> >> kmem_cache and mark it as accountable.
> >>
> > 
> > That doesn't work with slab cache merging done in slub.
> 
> Surely we'll have to change it a bit.
> 

We can't add a cache flag passed to kmem_cache_create() to identify caches 
that should be accounted versus those that shouldn't, there are allocs 
done in both process context and irq context from the same caches and we 
don't want to inhibit accounting with an additional flag passed to 
kmem_cache_alloc() if that cache has accounting enabled.

A vast majority of slab caches get merged into each other based on object 
size and alignment with slub; we could prevent that merging by checking 
the accounting bit for a cache, but that would come at a performance cost 
(nullifying many hot object allocs), increased fragmentation, and 
increased memory consumption.

In other words, we don't want to make it an attribute of the cache itself, 
we need to make it an attribute of the context in which the allocation is 
done; there're many more cases where we'll want to have accounting enabled 
by default, so we'll need to add a bit passed on alloc to inhibit 
accounting for those objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
