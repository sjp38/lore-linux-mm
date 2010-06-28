Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CB9A56B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 09:17:04 -0400 (EDT)
Received: by pvg11 with SMTP id 11so1436786pvg.14
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 06:17:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 28 Jun 2010 21:17:03 +0800
Message-ID: <AANLkTilJDrpoFGyTSrKg3Hg59u9TvBLbxk4HAVKBvjxQ@mail.gmail.com>
Subject: [PATCH] avoid return NULL on root rb_node in rb_next/rb_prev in
	lib/rbtree.c
From: shenghui <crosslonelyover@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, mingo@elte.hu, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

Hi,

       I'm reading cfs code, and get the following potential bug.

In kernel/sched_fair.c, we can get the following call thread:

1778static struct task_struct *pick_next_task_fair(struct rq *rq)
1779{
...
1787        do {
1788                se = pick_next_entity(cfs_rq);
1789                set_next_entity(cfs_rq, se);
1790                cfs_rq = group_cfs_rq(se);
1791        } while (cfs_rq);
...
1797}

 925static struct sched_entity *pick_next_entity(struct cfs_rq *cfs_rq)
 926{
 927        struct sched_entity *se = __pick_next_entity(cfs_rq);
...
 941        return se;
 942}

 377static struct sched_entity *__pick_next_entity(struct cfs_rq *cfs_rq)
 378{
 379        struct rb_node *left = cfs_rq->rb_leftmost;
 380
 381        if (!left)
 382                return NULL;
 ...
 385}

To manipulate cfs_rq->rb_leftmost, __dequeue_entity does the following:

 365static void __dequeue_entity(struct cfs_rq *cfs_rq, struct sched_entity *se)
 366{
 367        if (cfs_rq->rb_leftmost == &se->run_node) {
 368                struct rb_node *next_node;
 369
 370                next_node = rb_next(&se->run_node);
 371                cfs_rq->rb_leftmost = next_node;
 372        }
 373
 374        rb_erase(&se->run_node, &cfs_rq->tasks_timeline);
 375}

Here, if se->run_node is the root rb_node, next_node will be set NULL
by rb_next.
Then __pick_next_entity may get NULL on some call, and set_next_entity
may deference
NULL value.

 892static void
 893set_next_entity(struct cfs_rq *cfs_rq, struct sched_entity *se)
 894{
 895        /* 'current' is not kept within the tree. */
 896        if (se->on_rq) {
...
 919        se->prev_sum_exec_runtime = se->sum_exec_runtime;
 920}

Following is my patch. Please check it.
