Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A34D66B0011
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:59:05 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4BKx2bw011615
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:59:02 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by hpaq5.eem.corp.google.com with ESMTP id p4BKwHSj005378
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:59:01 -0700
Received: by pwi8 with SMTP id 8so495553pwi.8
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:59:00 -0700 (PDT)
Date: Wed, 11 May 2011 13:58:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: slub: Add statistics for this_cmpxchg_double failures
In-Reply-To: <alpine.DEB.2.00.1103221333130.16870@router.home>
Message-ID: <alpine.DEB.2.00.1105111349350.9346@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103221333130.16870@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Tue, 22 Mar 2011, Christoph Lameter wrote:

> Index: linux-2.6/include/linux/slub_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slub_def.h	2011-03-11 10:34:26.000000000 -0600
> +++ linux-2.6/include/linux/slub_def.h	2011-03-11 10:34:49.000000000 -0600
> @@ -32,6 +32,7 @@ enum stat_item {
>  	DEACTIVATE_TO_TAIL,	/* Cpu slab was moved to the tail of partials */
>  	DEACTIVATE_REMOTE_FREES,/* Slab contained remotely freed objects */
>  	ORDER_FALLBACK,		/* Number of times fallback was necessary */
> +	CMPXCHG_DOUBLE_CPU_FAIL,/* Failure of this_cpu_cmpxchg_double */
>  	NR_SLUB_STAT_ITEMS };
> 
>  struct kmem_cache_cpu {
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2011-03-11 10:34:27.000000000 -0600
> +++ linux-2.6/mm/slub.c	2011-03-11 10:34:49.000000000 -0600
> @@ -217,7 +217,7 @@ static inline void sysfs_slab_remove(str
> 
>  #endif
> 
> -static inline void stat(struct kmem_cache *s, enum stat_item si)
> +static inline void stat(const struct kmem_cache *s, enum stat_item si)
>  {
>  #ifdef CONFIG_SLUB_STATS
>  	__this_cpu_inc(s->cpu_slab->stat[si]);
> @@ -1551,6 +1551,7 @@ static inline void note_cmpxchg_failure(
>  		printk("for unknown reason: actual=%lx was=%lx target=%lx\n",
>  			actual_tid, tid, next_tid(tid));
>  #endif
> +	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);
>  }
> 
>  #endif

I see this has been merged as 4fdccdfbb465, but it seems pretty pointless 
unless you export the data to userspace with the necessary STAT_ATTR() and 
addition in slab_attrs.


slub: export CMPXCHG_DOUBLE_CPU_FAIL to userspace

4fdccdfbb465 ("slub: Add statistics for this_cmpxchg_double failures") 
added CMPXCHG_DOUBLE_CPU_FAIL to show how many times 
this_cpu_cmpxchg_double has failed, but it also needs to be exported to 
userspace for consumption.

This will always be 0 if CONFIG_CMPXCHG_LOCAL is disabled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4525,6 +4525,7 @@ STAT_ATTR(DEACTIVATE_TO_HEAD, deactivate_to_head);
 STAT_ATTR(DEACTIVATE_TO_TAIL, deactivate_to_tail);
 STAT_ATTR(DEACTIVATE_REMOTE_FREES, deactivate_remote_frees);
 STAT_ATTR(ORDER_FALLBACK, order_fallback);
+STAT_ATTR(CMPXCHG_DOUBLE_CPU_FAIL, cmpxchg_double_cpu_fail);
 #endif
 
 static struct attribute *slab_attrs[] = {
@@ -4582,6 +4583,7 @@ static struct attribute *slab_attrs[] = {
 	&deactivate_to_tail_attr.attr,
 	&deactivate_remote_frees_attr.attr,
 	&order_fallback_attr.attr,
+	&cmpxchg_double_cpu_fail_attr.attr,
 #endif
 #ifdef CONFIG_FAILSLAB
 	&failslab_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
