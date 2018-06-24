Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0035E6B0005
	for <linux-mm@kvack.org>; Sun, 24 Jun 2018 15:51:17 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id s25-v6so159798lji.0
        for <linux-mm@kvack.org>; Sun, 24 Jun 2018 12:51:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10-v6sor2577154ljh.60.2018.06.24.12.51.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Jun 2018 12:51:16 -0700 (PDT)
Date: Sun, 24 Jun 2018 22:51:13 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/3] mm: workingset: remove local_irq_disable() from
 count_shadow_nodes()
Message-ID: <20180624195113.rmrr3mkpnfa4pqlg@esperanza>
References: <20180622151221.28167-1-bigeasy@linutronix.de>
 <20180622151221.28167-2-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622151221.28167-2-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de, Andrew Morton <akpm@linux-foundation.org>, Kirill Tkhai <ktkhai@virtuozzo.com>

On Fri, Jun 22, 2018 at 05:12:19PM +0200, Sebastian Andrzej Siewior wrote:
> In commit 0c7c1bed7e13 ("mm: make counting of list_lru_one::nr_items
> lockless") the
> 	spin_lock(&nlru->lock);
> 
> statement was replaced with
> 	rcu_read_lock();
> 
> in __list_lru_count_one(). The comment in count_shadow_nodes() says that
> the local_irq_disable() is required because the lock must be acquired
> with disabled interrupts and (spin_lock()) does not do so.
> Since the lock is replaced with rcu_read_lock() the local_irq_disable()
> is no longer needed. The code path is
>   list_lru_shrink_count()
>     -> list_lru_count_one()
>       -> __list_lru_count_one()
>         -> rcu_read_lock()
>         -> list_lru_from_memcg_idx()
>         -> rcu_read_unlock()
> 
> Remove the local_irq_disable() statement.
> 
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
