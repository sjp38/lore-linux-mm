Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D33F600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 02:40:20 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id nB17b3kk008508
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:37:03 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB17agPk1110134
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:36:42 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB17eGYI001213
	for <linux-mm@kvack.org>; Tue, 1 Dec 2009 18:40:16 +1100
Date: Tue, 1 Dec 2009 13:10:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091201074010.GR2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20091126085031.GG2970@balbir.in.ibm.com>
 <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E461C.50606@parallels.com>
 <20091126183335.7a18cb09.kamezawa.hiroyu@jp.fujitsu.com>
 <4B0E50B1.20602@parallels.com>
 <d26f1ae00911260224k6b87aaf7o9e3a983a73e6036e@mail.gmail.com>
 <4B0E7530.8050304@parallels.com>
 <d26f1ae00911260452w7da1f10fk5889e9506aeb1400@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <d26f1ae00911260452w7da1f10fk5889e9506aeb1400@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Suleiman Souhlal <suleiman@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Suleiman Souhlal <suleiman@google.com> [2009-11-26 04:52:00]:

> On 11/26/09, Pavel Emelyanov <xemul@parallels.com> wrote:
> > > Aren't there patches to make the kernel track which cgroup caused
> >  > which disk I/O? If so, it should be possible to charge the bios to the
> >  > right cgroup.
> >  >
> >  > Maybe one way to decide which kernel allocations should be accounted
> >  > would be to look at the calling context: If the allocation is done in
> >  > user context (syscall), then it could be counted towards that user,
> >  > while if the allocation is done in interrupt or kthread context, it
> >  > shouldn't be accounted.
> >  >
> >  > Of course, this wouldn't be perfect, but it might be a good enough
> >  > approximation.
> >
> >
> > I disagree. Bio-s are allocated in user context for all typical reads
> >  (unless we requested aio) and are allocated either in pdflush context
> >  or (!) in arbitrary task context for writes (e.g. via try_to_free_pages)
> >  and thus such bio/buffer_head accounting will be completely random.
> 
> Yes, that's why I pointed out that you can account to the right cgroup
> if you track who caused the I/O (which, I imagine, should already be
> done by the block i/o bandwidth controller, or similar).
>

We can do so, we do that for task I/O accounting today and it works
quite well for the applications I've applied them to.
 
> For most other allocations, on the other hand, accounting to the
> current context should be fine.
> 

Absolutely! Except when the context is a kernel thread like
pdflush/ksm, etc. 

> >  One of the way to achieve the goal I can propose the following (it's
> >  not perfect, but just smth to start discussion from).
> >
> >  We implement support for accounting based on a bit on a kmem_cache
> >  structure and mark all kmalloc caches as not-accountable. Then we grep
> >  the kernel to find all kmalloc-s and think - if a kmalloc is to be
> >  accounted we turn this into kmem_cache_alloc() with dedicated
> >  kmem_cache and mark it as accountable.
> 
> That sounds like a lot of work. :-)
>

Hmm.. yes, it does, but I wonder if there are better alternatives. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
