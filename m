Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EF7896B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 02:57:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3B9E83EE0C0
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:57:10 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1B5645DEC0
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:57:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD27945DEB7
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:57:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A38DE1DB8040
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:57:09 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B3891DB8042
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 15:57:09 +0900 (JST)
Message-ID: <507E56A1.90809@jp.fujitsu.com>
Date: Wed, 17 Oct 2012 15:56:33 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 12/14] execute the whole memcg freeing in free_worker
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-13-git-send-email-glommer@parallels.com>
In-Reply-To: <1350382611-20579-13-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org

(2012/10/16 19:16), Glauber Costa wrote:
> A lot of the initialization we do in mem_cgroup_create() is done with
> softirqs enabled. This include grabbing a css id, which holds
> &ss->id_lock->rlock, and the per-zone trees, which holds
> rtpz->lock->rlock. All of those signal to the lockdep mechanism that
> those locks can be used in SOFTIRQ-ON-W context. This means that the
> freeing of memcg structure must happen in a compatible context,
> otherwise we'll get a deadlock, like the one bellow, caught by lockdep:
> 
>    [<ffffffff81103095>] free_accounted_pages+0x47/0x4c
>    [<ffffffff81047f90>] free_task+0x31/0x5c
>    [<ffffffff8104807d>] __put_task_struct+0xc2/0xdb
>    [<ffffffff8104dfc7>] put_task_struct+0x1e/0x22
>    [<ffffffff8104e144>] delayed_put_task_struct+0x7a/0x98
>    [<ffffffff810cf0e5>] __rcu_process_callbacks+0x269/0x3df
>    [<ffffffff810cf28c>] rcu_process_callbacks+0x31/0x5b
>    [<ffffffff8105266d>] __do_softirq+0x122/0x277
> 
> This usage pattern could not be triggered before kmem came into play.
> With the introduction of kmem stack handling, it is possible that we
> call the last mem_cgroup_put() from the task destructor, which is run in
> an rcu callback. Such callbacks are run with softirqs disabled, leading
> to the offensive usage pattern.
> 
> In general, we have little, if any, means to guarantee in which context
> the last memcg_put will happen. The best we can do is test it and try to
> make sure no invalid context releases are happening. But as we add more
> code to memcg, the possible interactions grow in number and expose more
> ways to get context conflicts. One thing to keep in mind, is that part
> of the freeing process is already deferred to a worker, such as vfree(),
> that can only be called from process context.
> 
> For the moment, the only two functions we really need moved away are:
> 
>    * free_css_id(), and
>    * mem_cgroup_remove_from_trees().
> 
> But because the later accesses per-zone info,
> free_mem_cgroup_per_zone_info() needs to be moved as well. With that, we
> are left with the per_cpu stats only. Better move it all.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Tested-by: Greg Thelen <gthelen@google.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Tejun Heo <tj@kernel.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
