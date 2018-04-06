Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC5946B0006
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 14:50:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m6-v6so1510520pln.8
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 11:50:04 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id m13si7408096pgq.398.2018.04.06.11.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 11:50:02 -0700 (PDT)
Subject: Re: [RFC PATCH] mm: use rbtree for page-wait
References: <20180403215912.pcnam27taalnl7nh@breakpoint.cc>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <92415382-0aa0-f42a-ed2a-71a0c359d02b@linux.intel.com>
Date: Fri, 6 Apr 2018 11:50:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180403215912.pcnam27taalnl7nh@breakpoint.cc>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kan Liang <kan.liang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On 04/03/2018 02:59 PM, Sebastian Andrzej Siewior wrote:
> I noticed commit 2554db916586 ("sched/wait: Break up long wake list
> walk") in which it is claimed that
> |We saw page wait list that are up to 3700+ entries long in tests of
> |large 4 and 8 socket systems.
> 
> Here is another approach: instead of a waitlist a rbtree is used. The
> tree is ordered by page and bit_nr that it waits for. A wake up request
> for specific page + bit_nr combination does not need to browse through
> the whole set of waiters but does only look for the specific waiter(s).
> For the actual wake up wake_q mechanism is used. That means we enqueue
> all to-be-woken tasks on a queue and perform the actual wakeup without
> holding the queue lock.

One concern I have is the overhead of maintaining this rbtree. There's
also locking overhead when adding/removing/lookup pages from this rbtree for
any page wait/wake operation.

Have you done some measurement on some workload to measure
its effect?

Tim

> 
> add_page_wait_queue() is currently not wired up which means it breaks
> the one user we have right now. Instead of fixing that I would be
> interrested in some specific benchmark to see if that is any help or
> just making things worse.
> 
> Cc: Kan Liang <kan.liang@intel.com>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> ---
>  mm/filemap.c | 286 +++++++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 208 insertions(+), 78 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 693f62212a59..6f44eaac1a53 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -36,6 +36,7 @@
>  #include <linux/cleancache.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/rmap.h>
> +#include <linux/sched/wake_q.h>
>  #include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
> @@ -957,11 +958,15 @@ EXPORT_SYMBOL(__page_cache_alloc);
>   * at a cost of "thundering herd" phenomena during rare hash
>   * collisions.
>   */
> +struct page_wait_rb {
> +	struct rb_root	tree;
> +	spinlock_t	lock;
> +};
> +
>  #define PAGE_WAIT_TABLE_BITS 8
>  #define PAGE_WAIT_TABLE_SIZE (1 << PAGE_WAIT_TABLE_BITS)
> -static wait_queue_head_t page_wait_table[PAGE_WAIT_TABLE_SIZE] __cacheline_aligned;
> -
> -static wait_queue_head_t *page_waitqueue(struct page *page)
> +static struct page_wait_rb page_wait_table[PAGE_WAIT_TABLE_SIZE] __cacheline_aligned;
> +static struct page_wait_rb *page_waitqueue(struct page *page)
>  {
>  	return &page_wait_table[hash_ptr(page, PAGE_WAIT_TABLE_BITS)];
>  }
> @@ -970,77 +975,134 @@ void __init pagecache_init(void)
>  {
>  	int i;
>  
> -	for (i = 0; i < PAGE_WAIT_TABLE_SIZE; i++)
> -		init_waitqueue_head(&page_wait_table[i]);
> +	for (i = 0; i < PAGE_WAIT_TABLE_SIZE; i++) {
> +		spin_lock_init(&page_wait_table[i].lock);
> +		page_wait_table[i].tree = RB_ROOT;
> +	}
>  
>  	page_writeback_init();
>  }
>  
>  /* This has the same layout as wait_bit_key - see fs/cachefiles/rdwr.c */
> -struct wait_page_key {
> -	struct page *page;
> -	int bit_nr;
> -	int page_match;
> -};
> -
>  struct wait_page_queue {
> +	struct rb_node node;
>  	struct page *page;
>  	int bit_nr;
> -	wait_queue_entry_t wait;
> +	bool one;
> +	bool dequeued;
> +	struct task_struct *task;
> +	struct list_head queue;
> +	struct list_head head;
>  };
>  
> -static int wake_page_function(wait_queue_entry_t *wait, unsigned mode, int sync, void *arg)
> +static int wake_page_match(struct page *page, int bit_nr,
> +			   struct wait_page_queue *page_q, bool *page_match)
>  {
> -	struct wait_page_key *key = arg;
> -	struct wait_page_queue *wait_page
> -		= container_of(wait, struct wait_page_queue, wait);
> -
> -	if (wait_page->page != key->page)
> -	       return 0;
> -	key->page_match = 1;
> -
> -	if (wait_page->bit_nr != key->bit_nr)
> -		return 0;
> -
> -	/* Stop walking if it's locked */
> -	if (test_bit(key->bit_nr, &key->page->flags))
> +	if ((unsigned long)page < (unsigned long)page_q->page)
>  		return -1;
>  
> -	return autoremove_wake_function(wait, mode, sync, key);
> +	if ((unsigned long)page > (unsigned long)page_q->page)
> +		return 1;
> +
> +	/* page hit */
> +	*page_match = true;
> +
> +	if (bit_nr < page_q->bit_nr)
> +		return -1;
> +
> +	if (bit_nr > page_q->bit_nr)
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static struct rb_node *find_wake_page(struct page_wait_rb *rb,
> +				      struct page *page, int bit_nr,
> +				      bool *page_match)
> +{
> +	struct rb_node *node;
> +
> +	node = rb->tree.rb_node;
> +	while (node) {
> +		struct wait_page_queue *page_q;
> +		int match;
> +
> +		page_q = rb_entry(node, struct wait_page_queue, node);
> +		match = wake_page_match(page, bit_nr, page_q, page_match);
> +
> +		if (match < 0)
> +			node = node->rb_left;
> +		else if (match > 0)
> +			node = node->rb_right;
> +		else
> +			break;
> +	}
> +	return node;
> +}
> +
> +static void wake_up_rb(struct page_wait_rb *rb, struct wake_q_head *wake_q,
> +		       struct wait_page_queue *page_q)
> +{
> +	struct wait_page_queue *next;
> +	struct rb_node *node = &page_q->node;
> +
> +	while (1) {
> +		struct task_struct *t;
> +		bool one;
> +
> +		if (list_empty(&page_q->head)) {
> +
> +			rb_erase(node, &rb->tree);
> +			RB_CLEAR_NODE(node);
> +
> +			t = READ_ONCE(page_q->task);
> +			/* full barrier in wake_q_add() */
> +			page_q->dequeued = true;
> +			wake_q_add(wake_q, t);
> +			break;
> +		}
> +
> +		next = list_first_entry(&page_q->head, struct wait_page_queue,
> +					queue);
> +
> +		list_del_init(&next->queue);
> +		list_splice_init(&page_q->head, &next->head);
> +
> +		rb_replace_node(node, &next->node, &rb->tree);
> +		RB_CLEAR_NODE(node);
> +		t = READ_ONCE(page_q->task);
> +		one = READ_ONCE(page_q->one);
> +
> +		/* full barrier in wake_q_add() */
> +		page_q->dequeued = true;
> +		wake_q_add(wake_q, t);
> +		if (one == true)
> +			break;
> +		page_q = next;
> +		node = &page_q->node;
> +	}
>  }
>  
>  static void wake_up_page_bit(struct page *page, int bit_nr)
>  {
> -	wait_queue_head_t *q = page_waitqueue(page);
> -	struct wait_page_key key;
> +	struct page_wait_rb *rb = page_waitqueue(page);
> +	struct wait_page_queue *page_q;
> +	struct rb_node *node;
>  	unsigned long flags;
> -	wait_queue_entry_t bookmark;
> +	bool page_match = false;
> +	DEFINE_WAKE_Q(wake_q);
>  
> -	key.page = page;
> -	key.bit_nr = bit_nr;
> -	key.page_match = 0;
> +	spin_lock_irqsave(&rb->lock, flags);
>  
> -	bookmark.flags = 0;
> -	bookmark.private = NULL;
> -	bookmark.func = NULL;
> -	INIT_LIST_HEAD(&bookmark.entry);
> +	node = find_wake_page(rb, page, bit_nr, &page_match);
> +	if (node) {
>  
> -	spin_lock_irqsave(&q->lock, flags);
> -	__wake_up_locked_key_bookmark(q, TASK_NORMAL, &key, &bookmark);
> -
> -	while (bookmark.flags & WQ_FLAG_BOOKMARK) {
> -		/*
> -		 * Take a breather from holding the lock,
> -		 * allow pages that finish wake up asynchronously
> -		 * to acquire the lock and remove themselves
> -		 * from wait queue
> -		 */
> -		spin_unlock_irqrestore(&q->lock, flags);
> -		cpu_relax();
> -		spin_lock_irqsave(&q->lock, flags);
> -		__wake_up_locked_key_bookmark(q, TASK_NORMAL, &key, &bookmark);
> +		page_q = rb_entry(node, struct wait_page_queue, node);
> +		/* Stop walking if it's locked */
> +		if (test_bit(bit_nr, &page->flags))
> +			goto no_wakeup;
> +		wake_up_rb(rb, &wake_q, page_q);
>  	}
> -
>  	/*
>  	 * It is possible for other pages to have collided on the waitqueue
>  	 * hash, so in that case check for a page match. That prevents a long-
> @@ -1050,7 +1112,7 @@ static void wake_up_page_bit(struct page *page, int bit_nr)
>  	 * and removed them from the waitqueue, but there are still other
>  	 * page waiters.
>  	 */
> -	if (!waitqueue_active(q) || !key.page_match) {
> +	if (!page_match || RB_EMPTY_ROOT(&rb->tree)) {
>  		ClearPageWaiters(page);
>  		/*
>  		 * It's possible to miss clearing Waiters here, when we woke
> @@ -1060,7 +1122,10 @@ static void wake_up_page_bit(struct page *page, int bit_nr)
>  		 * That's okay, it's a rare case. The next waker will clear it.
>  		 */
>  	}
> -	spin_unlock_irqrestore(&q->lock, flags);
> +no_wakeup:
> +
> +	spin_unlock_irqrestore(&rb->lock, flags);
> +	wake_up_q(&wake_q);
>  }
>  
>  static void wake_up_page(struct page *page, int bit)
> @@ -1070,30 +1135,63 @@ static void wake_up_page(struct page *page, int bit)
>  	wake_up_page_bit(page, bit);
>  }
>  
> -static inline int wait_on_page_bit_common(wait_queue_head_t *q,
> -		struct page *page, int bit_nr, int state, bool lock)
> +static int wait_on_page_bit_common(struct page_wait_rb *rb, struct page *page,
> +				   int bit_nr, int state, bool lock)
>  {
> -	struct wait_page_queue wait_page;
> -	wait_queue_entry_t *wait = &wait_page.wait;
> +	struct wait_page_queue page_q;
> +	struct rb_node *node = &page_q.node;
> +	struct rb_node **p;
> +	struct rb_node *parent;
>  	int ret = 0;
>  
> -	init_wait(wait);
> -	wait->flags = lock ? WQ_FLAG_EXCLUSIVE : 0;
> -	wait->func = wake_page_function;
> -	wait_page.page = page;
> -	wait_page.bit_nr = bit_nr;
> +	page_q.page = page;
> +	page_q.bit_nr = bit_nr;
> +	page_q.task = current;
> +	page_q.one = lock;
> +	INIT_LIST_HEAD(&page_q.queue);
> +	INIT_LIST_HEAD(&page_q.head);
> +	RB_CLEAR_NODE(&page_q.node);
>  
>  	for (;;) {
> -		spin_lock_irq(&q->lock);
> +		spin_lock_irq(&rb->lock);
>  
> -		if (likely(list_empty(&wait->entry))) {
> -			__add_wait_queue_entry_tail(q, wait);
> -			SetPageWaiters(page);
> +		if (likely(RB_EMPTY_NODE(node)) &&
> +			list_empty(&page_q.queue)) {
> +
> +			page_q.dequeued = false;
> +
> +			p = &rb->tree.rb_node;
> +			parent = NULL;
> +			while (*p) {
> +				struct wait_page_queue *tmp;
> +				int match;
> +				bool page_match;
> +
> +				parent = *p;
> +				tmp = rb_entry(parent, struct wait_page_queue, node);
> +
> +				match = wake_page_match(page, bit_nr, tmp, &page_match);
> +
> +				if (match < 0) {
> +					p = &parent->rb_left;
> +
> +				} else if (match > 0) {
> +					p = &parent->rb_right;
> +				} else {
> +					list_add_tail(&page_q.queue,
> +						      &tmp->head);
> +					break;
> +				}
> +			}
> +			if (list_empty(&page_q.queue)) {
> +				rb_link_node(node, parent, p);
> +				rb_insert_color(node, &rb->tree);
> +			}
>  		}
> -
> +		SetPageWaiters(page);
>  		set_current_state(state);
>  
> -		spin_unlock_irq(&q->lock);
> +		spin_unlock_irq(&rb->lock);
>  
>  		if (likely(test_bit(bit_nr, &page->flags))) {
>  			io_schedule();
> @@ -1112,8 +1210,34 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
>  			break;
>  		}
>  	}
> +	__set_current_state(TASK_RUNNING);
>  
> -	finish_wait(q, wait);
> +	/* paired with the full barrier in wake_q_add() */
> +	smp_rmb();
> +	if (!page_q.dequeued) {
> +		spin_lock_irq(&rb->lock);
> +
> +		if (!list_empty(&page_q.queue))
> +			list_del_init(&page_q.queue);
> +
> +		if (!list_empty(&page_q.head)) {
> +			struct wait_page_queue *tmp;
> +
> +			BUG_ON(RB_EMPTY_NODE(node));
> +
> +			tmp = list_first_entry(&page_q.head,
> +					       struct wait_page_queue,
> +					       queue);
> +			list_del_init(&tmp->queue);
> +			list_splice(&page_q.head, &tmp->head);
> +
> +			rb_replace_node(node, &tmp->node, &rb->tree);
> +
> +		} else if (!RB_EMPTY_NODE(node)) {
> +			rb_erase(node, &rb->tree);
> +		}
> +		spin_unlock_irq(&rb->lock);
> +	}
>  
>  	/*
>  	 * A signal could leave PageWaiters set. Clearing it here if
> @@ -1128,18 +1252,21 @@ static inline int wait_on_page_bit_common(wait_queue_head_t *q,
>  
>  void wait_on_page_bit(struct page *page, int bit_nr)
>  {
> -	wait_queue_head_t *q = page_waitqueue(page);
> -	wait_on_page_bit_common(q, page, bit_nr, TASK_UNINTERRUPTIBLE, false);
> +	struct page_wait_rb *rb = page_waitqueue(page);
> +
> +	wait_on_page_bit_common(rb, page, bit_nr, TASK_UNINTERRUPTIBLE, false);
>  }
>  EXPORT_SYMBOL(wait_on_page_bit);
>  
>  int wait_on_page_bit_killable(struct page *page, int bit_nr)
>  {
> -	wait_queue_head_t *q = page_waitqueue(page);
> -	return wait_on_page_bit_common(q, page, bit_nr, TASK_KILLABLE, false);
> +	struct page_wait_rb *rb = page_waitqueue(page);
> +
> +	return wait_on_page_bit_common(rb, page, bit_nr, TASK_KILLABLE, false);
>  }
>  EXPORT_SYMBOL(wait_on_page_bit_killable);
>  
> +#if 0
>  /**
>   * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
>   * @page: Page defining the wait queue of interest
> @@ -1158,6 +1285,7 @@ void add_page_wait_queue(struct page *page, wait_queue_entry_t *waiter)
>  	spin_unlock_irqrestore(&q->lock, flags);
>  }
>  EXPORT_SYMBOL_GPL(add_page_wait_queue);
> +#endif
>  
>  #ifndef clear_bit_unlock_is_negative_byte
>  
> @@ -1268,16 +1396,18 @@ EXPORT_SYMBOL_GPL(page_endio);
>  void __lock_page(struct page *__page)
>  {
>  	struct page *page = compound_head(__page);
> -	wait_queue_head_t *q = page_waitqueue(page);
> -	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, true);
> +	struct page_wait_rb *rb = page_waitqueue(page);
> +
> +	wait_on_page_bit_common(rb, page, PG_locked, TASK_UNINTERRUPTIBLE, true);
>  }
>  EXPORT_SYMBOL(__lock_page);
>  
>  int __lock_page_killable(struct page *__page)
>  {
>  	struct page *page = compound_head(__page);
> -	wait_queue_head_t *q = page_waitqueue(page);
> -	return wait_on_page_bit_common(q, page, PG_locked, TASK_KILLABLE, true);
> +	struct page_wait_rb *rb = page_waitqueue(page);
> +
> +	return wait_on_page_bit_common(rb, page, PG_locked, TASK_KILLABLE, true);
>  }
>  EXPORT_SYMBOL_GPL(__lock_page_killable);
>  
> 
