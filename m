Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA08091
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 14:29:30 -0700 (PDT)
Message-ID: <3DA49FB9.5551F0D2@digeo.com>
Date: Wed, 09 Oct 2002 14:29:29 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Hangs in 2.5.41-mm1
References: <20021009210049.GH12432@holomorphy.com> <1034198228.30973.70.camel@plars>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> 
> I got an oops out of it this time, after running it that test several
> times, I retried case 2 and got this:
> 
> ...
> EIP is at cache_alloc_refill+0xbb/0x170

I seem to be giving this patch to everyone lately.  Hopefully
it will fix that.



--- 2.5.41/mm/slab.c~slab-split-10-list_for_each_fix	Tue Oct  8 15:40:52 2002
+++ 2.5.41-akpm/mm/slab.c	Tue Oct  8 15:40:52 2002
@@ -461,7 +461,7 @@ static kmem_cache_t cache_cache = {
 static struct semaphore	cache_chain_sem;
 static rwlock_t cache_chain_lock = RW_LOCK_UNLOCKED;
 
-#define cache_chain (cache_cache.next)
+struct list_head cache_chain;
 
 /*
  * chicken and egg problem: delay the per-cpu array allocation
@@ -617,6 +617,7 @@ void __init kmem_cache_init(void)
 
 	init_MUTEX(&cache_chain_sem);
 	INIT_LIST_HEAD(&cache_chain);
+	list_add(&cache_cache.next, &cache_chain);
 
 	cache_estimate(0, cache_cache.objsize, 0,
 			&left_over, &cache_cache.num);
@@ -2093,10 +2094,10 @@ static void *s_start(struct seq_file *m,
 	down(&cache_chain_sem);
 	if (!n)
 		return (void *)1;
-	p = &cache_cache.next;
+	p = cache_chain.next;
 	while (--n) {
 		p = p->next;
-		if (p == &cache_cache.next)
+		if (p == &cache_chain)
 			return NULL;
 	}
 	return list_entry(p, kmem_cache_t, next);
@@ -2107,9 +2108,9 @@ static void *s_next(struct seq_file *m, 
 	kmem_cache_t *cachep = p;
 	++*pos;
 	if (p == (void *)1)
-		return &cache_cache;
-	cachep = list_entry(cachep->next.next, kmem_cache_t, next);
-	return cachep == &cache_cache ? NULL : cachep;
+		return list_entry(cache_chain.next, kmem_cache_t, next);
+	return cachep->next.next == &cache_chain ? NULL
+		: list_entry(cachep->next.next, kmem_cache_t, next);
 }
 
 static void s_stop(struct seq_file *m, void *p)

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
