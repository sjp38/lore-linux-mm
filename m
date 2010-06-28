Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8C73B6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 19:48:18 -0400 (EDT)
Received: by pxi17 with SMTP id 17so3923643pxi.14
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 16:48:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1277733320.3561.50.camel@laptop>
References: <AANLkTilJDrpoFGyTSrKg3Hg59u9TvBLbxk4HAVKBvjxQ@mail.gmail.com>
	<1277733320.3561.50.camel@laptop>
Date: Tue, 29 Jun 2010 07:48:12 +0800
Message-ID: <AANLkTinuas0MPFvZk9nOd91PuHXtaluHkkcWjGKYPZOl@mail.gmail.com>
Subject: Re: [PATCH] avoid return NULL on root rb_node in rb_next/rb_prev in
	lib/rbtree.c
From: shenghui <crosslonelyover@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

2010/6/28 Peter Zijlstra <peterz@infradead.org>:
> So if ->rb_leftmost is NULL, then the if (!left) check in
> __pick_next_entity() would return null.
>
> As to the NULL deref in in pick_next_task_fair()->set_next_entity() that
> should never happen because pick_next_task_fair() will bail
> on !->nr_running.
>
> Furthermore, you've failed to mention what kernel version you're looking
> at.
>

The kernel version is 2.6.35-rc3, and 2.6.34 has the same code.

For nr->running, if current is the only process in the run queue, then
nr->running would not be zero.
1784        if (!cfs_rq->nr_running)
1785                return NULL;
pick_next_task_fair() could pass above check and run to following:
1787        do {
1788                se = pick_next_entity(cfs_rq);
1789                set_next_entity(cfs_rq, se);
1790                cfs_rq = group_cfs_rq(se);
1791        } while (cfs_rq);

Then pick_next_entity will get NULL for current is the root rb_node.
Then set_next_entity would fail on NULL deference.



-- 


Thanks and Best Regards,
shenghui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
