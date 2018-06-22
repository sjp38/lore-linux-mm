Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4456A6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:39:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25-v6so3760905pfi.20
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 14:39:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n1-v6si6656484pge.263.2018.06.22.14.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 14:39:03 -0700 (PDT)
Date: Fri, 22 Jun 2018 14:39:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] mm: use irq locking suffix instead
 local_irq_disable()
Message-Id: <20180622143900.802fbfa2236d8f5bba965e2e@linux-foundation.org>
In-Reply-To: <20180622151221.28167-1-bigeasy@linutronix.de>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Kirill Tkhai <ktkhai@virtuozzo.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, 22 Jun 2018 17:12:18 +0200 Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> small series which avoids using local_irq_disable()/local_irq_enable()
> but instead does spin_lock_irq()/spin_unlock_irq() so it is within the
> context of the lock which it belongs to.
> Patch #1 is a cleanup where local_irq_.*() remained after the lock was
> removed.

Looks OK.

And we may as well do this...

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/list_lru.c: fold __list_lru_count_one() into its caller

__list_lru_count_one() has a single callsite.

Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/list_lru.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff -puN mm/list_lru.c~mm-list_lruc-fold-__list_lru_count_one-into-its-caller mm/list_lru.c
--- a/mm/list_lru.c~mm-list_lruc-fold-__list_lru_count_one-into-its-caller
+++ a/mm/list_lru.c
@@ -162,26 +162,20 @@ void list_lru_isolate_move(struct list_l
 }
 EXPORT_SYMBOL_GPL(list_lru_isolate_move);
 
-static unsigned long __list_lru_count_one(struct list_lru *lru,
-					  int nid, int memcg_idx)
+unsigned long list_lru_count_one(struct list_lru *lru,
+				 int nid, struct mem_cgroup *memcg)
 {
 	struct list_lru_node *nlru = &lru->node[nid];
 	struct list_lru_one *l;
 	unsigned long count;
 
 	rcu_read_lock();
-	l = list_lru_from_memcg_idx(nlru, memcg_idx);
+	l = list_lru_from_memcg_idx(nlru, memcg_cache_id(memcg));
 	count = l->nr_items;
 	rcu_read_unlock();
 
 	return count;
 }
-
-unsigned long list_lru_count_one(struct list_lru *lru,
-				 int nid, struct mem_cgroup *memcg)
-{
-	return __list_lru_count_one(lru, nid, memcg_cache_id(memcg));
-}
 EXPORT_SYMBOL_GPL(list_lru_count_one);
 
 unsigned long list_lru_count_node(struct list_lru *lru, int nid)
_
