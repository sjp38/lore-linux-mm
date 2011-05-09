Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABC9D6B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 20:29:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 14D003EE0C5
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:29:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8FEB45DE4F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:29:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE2ED45DE4D
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:29:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C04AF1DB803B
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:29:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B3281DB802F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:29:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] cpumask: alloc_cpumask_var() use NUMA_NO_NODE
In-Reply-To: <20110505124556.3c8a7e5b.akpm@linux-foundation.org>
References: <20110428231856.3D54.A69D9226@jp.fujitsu.com> <20110505124556.3c8a7e5b.akpm@linux-foundation.org>
Message-Id: <20110509093043.3ABB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 09:29:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi

> On Thu, 28 Apr 2011 23:17:15 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > NUMA_NO_NODE and numa_node_id() are different meanings. NUMA_NO_NODE 
> > is obviously recomended fallback.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  lib/cpumask.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/lib/cpumask.c b/lib/cpumask.c
> > index 4f6425d..af3e581 100644
> > --- a/lib/cpumask.c
> > +++ b/lib/cpumask.c
> > @@ -131,7 +131,7 @@ EXPORT_SYMBOL(zalloc_cpumask_var_node);
> >   */
> >  bool alloc_cpumask_var(cpumask_var_t *mask, gfp_t flags)
> >  {
> > -	return alloc_cpumask_var_node(mask, flags, numa_node_id());
> > +	return alloc_cpumask_var_node(mask, flags, NUMA_NO_NODE);
> >  }
> >  EXPORT_SYMBOL(alloc_cpumask_var);
> >  
> 
> So effectively this will replace numa_node_id() with numa_mem_id(),
> yes?  What runtime effects might this have?  

If I understand correctly,

 alloc_pages_node():  same effect both NUMA_NO_NODE and numa_node_id()
 kmalloc_node(): not same effect NUMA_NO_NODE and numa_node_id()

because 

slub.c
---------------------------------------------------
	slab_alloc() {
	 (snip)
	        if (unlikely(!object || !node_match(c, node)))
			// slow path
	        else {
			// fast path

and

	static inline int node_match(struct kmem_cache_cpu *c, int node)
	{
	#ifdef CONFIG_NUMA
	        if (node != NUMA_NO_NODE && c->node != node)
	                return 0;
	#endif
	        return 1;
	}
---------------------------------------------------
In a nutshell, numa_node_id() reduce slab cache reusing chance.


Oh, I missed slab.c code. It's using numa_mem_id(). thank you correct me!

numa_mem_id() don't have much meanings. It's ia64 HP big machine quirk.
it only affect to improve slab performance a little if users try to allocate
a memory from a cpu within memoryless node . and, 99% users never use such machine.

In a nutshell, NUMA_NO_NODE and numa_node_id() don't have a lot of difference
if users are using SLAB.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
