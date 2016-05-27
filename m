Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2F246B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:21:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so365846wmf.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:21:45 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gg9si24830925wjb.19.2016.05.27.10.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:21:44 -0700 (PDT)
Date: Fri, 27 May 2016 13:19:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: add RCU locking around
 css_for_each_descendant_pre() in memcg_offline_kmem()
Message-ID: <20160527171934.GA2531@cmpxchg.org>
References: <20160526203018.GG23194@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160526203018.GG23194@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu, May 26, 2016 at 04:30:18PM -0400, Tejun Heo wrote:
> memcg_offline_kmem() may be called from memcg_free_kmem() after a css
> init failure.  memcg_free_kmem() is a ->css_free callback which is
> called without cgroup_mutex and memcg_offline_kmem() ends up using
> css_for_each_descendant_pre() without any locking.  Fix it by adding
> rcu read locking around it.
> 
>  mkdir: cannot create directory a??65530a??: No space left on device
>  [  527.241361] ===============================
>  [  527.241845] [ INFO: suspicious RCU usage. ]
>  [  527.242367] 4.6.0-work+ #321 Not tainted
>  [  527.242730] -------------------------------
>  [  527.243220] kernel/cgroup.c:4008 cgroup_mutex or RCU read lock required!
>  [  527.243970]
>  [  527.243970] other info that might help us debug this:
>  [  527.243970]
>  [  527.244715]
>  [  527.244715] rcu_scheduler_active = 1, debug_locks = 0
>  [  527.245463] 2 locks held by kworker/0:5/1664:
>  [  527.245939]  #0:  ("cgroup_destroy"){.+.+..}, at: [<ffffffff81060ab5>] process_one_work+0x165/0x4a0
>  [  527.246958]  #1:  ((&css->destroy_work)#3){+.+...}, at: [<ffffffff81060ab5>] process_one_work+0x165/0x4a0
>  [  527.248098]
>  [  527.248098] stack backtrace:
>  [  527.249565] CPU: 0 PID: 1664 Comm: kworker/0:5 Not tainted 4.6.0-work+ #321
>  [  527.250429] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.1-1.fc24 04/01/2014
>  [  527.250555] Workqueue: cgroup_destroy css_free_work_fn
>  [  527.250555]  0000000000000000 ffff880178747c68 ffffffff8128bfc7 ffff880178b8ac40
>  [  527.250555]  0000000000000001 ffff880178747c98 ffffffff8108c297 0000000000000000
>  [  527.250555]  ffff88010de54138 000000000000fffb ffff88010de537e8 ffff880178747cc0
>  [  527.250555] Call Trace:
>  [  527.250555]  [<ffffffff8128bfc7>] dump_stack+0x68/0xa1
>  [  527.250555]  [<ffffffff8108c297>] lockdep_rcu_suspicious+0xd7/0x110
>  [  527.250555]  [<ffffffff810ca03d>] css_next_descendant_pre+0x7d/0xb0
>  [  527.250555]  [<ffffffff8114d14a>] memcg_offline_kmem.part.44+0x4a/0xc0
>  [  527.250555]  [<ffffffff8114d3ac>] mem_cgroup_css_free+0x1ec/0x200
>  [  527.250555]  [<ffffffff810ccdc9>] css_free_work_fn+0x49/0x5e0
>  [  527.250555]  [<ffffffff81060b15>] process_one_work+0x1c5/0x4a0
>  [  527.250555]  [<ffffffff81060ab5>] ? process_one_work+0x165/0x4a0
>  [  527.250555]  [<ffffffff81060e39>] worker_thread+0x49/0x490
>  [  527.250555]  [<ffffffff81060df0>] ? process_one_work+0x4a0/0x4a0
>  [  527.250555]  [<ffffffff81060df0>] ? process_one_work+0x4a0/0x4a0
>  [  527.250555]  [<ffffffff810672ba>] kthread+0xea/0x100
>  [  527.250555]  [<ffffffff814cbcff>] ret_from_fork+0x1f/0x40
>  [  527.250555]  [<ffffffff810671d0>] ? kthread_create_on_node+0x200/0x200
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
