Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 716CE6B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:44:42 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id i5so100984550ige.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 07:44:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 135si7941388ion.104.2016.05.18.07.44.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 07:44:41 -0700 (PDT)
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160518125138.GH21654@dhcp22.suse.cz>
	<201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
In-Reply-To: <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
Message-Id: <201605182344.IBJ06800.HLJMStFFFQVOOO@I-love.SAKURA.ne.jp>
Date: Wed, 18 May 2016 23:44:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp

Michal Hocko wrote:
> On Wed 18-05-16 22:30:14, Tetsuo Handa wrote:
> > Even if you call p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN case a bug,
> > (p->flags & PF_KTHREAD) || is_global_init(p) case is still possible.
> 
> I couldn't care less about such a case to be honest, and that is not a
> reason the cripple the code for such an insanity. There simply doesn't
> make any sense to share init's mm with a different task.

The global init called vfork(), and the child tried to call execve() with
large argv/envp array, and the child got OOM-killed is possible.

> OK, this looks correct. Strictly speaking the patch is missing any note
> on _why_ this is needed or an improvement. I would add something like
> the following:
> "
> Although the original code was correct it was quite inefficient because
> each thread group was scanned num_threads times which can be a lot
> especially with processes with many threads. Even though the OOM is
> extremely cold path it is always good to be as effective as possible
> when we are inside rcu_read_lock() - aka unpreemptible context.
> "

rcu_read_lock() is not always unpreemptible context. rcu_read_lock() says:

  In non-preemptible RCU implementations (TREE_RCU and TINY_RCU),
  it is illegal to block while in an RCU read-side critical section.
  In preemptible RCU implementations (PREEMPT_RCU) in CONFIG_PREEMPT
  kernel builds, RCU read-side critical sections may be preempted,
  but explicit blocking is illegal.  Finally, in preemptible RCU
  implementations in real-time (with -rt patchset) kernel builds, RCU
  read-side critical sections may be preempted and they may also block, but
  only when acquiring spinlocks that are subject to priority inheritance.

We will need preempt_disable() if we want to make out_of_memory() return
as fast as possible.

> 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Oleg Nesterov <oleg@redhat.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
