Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 6EF5C6B004D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:18:43 -0400 (EDT)
Date: Thu, 28 Jun 2012 19:16:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to
	iterate only over its own threads
Message-ID: <20120628171618.GA27089@redhat.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com> <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com> <alpine.DEB.2.00.1206271837460.14446@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271837460.14446@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On 06/27, David Rientjes wrote:
>
> On Tue, 26 Jun 2012, David Rientjes wrote:
>
> > It turns out that task->children is not an rcu-protected list so this
> > doesn't work.

Yes. And just in case, we can't rcuify ->children because of re-parenting.

> It's a tough patch to review, but the basics are that
>
>  - oom_kill_process() is made to no longer need tasklist_lock; it's only
>    taken for the iteration over children and everything else, including
>    dump_header() is protected by rcu_read_lock() for kernels enabling
>    /proc/sys/vm/oom_dump_tasks,
>
>  - oom_kill_process() assumes that we have a reference to p, the victim,
>    when it's called.  It can release this reference and grab a child's
>    reference if necessary and drops it before returning, and
>
>  - select_bad_process() does not require tasklist_lock, it gets
>    protected by rcu_read_lock() as well.

Looks correct at first glance... (ignoring the fact we need the fixes
in while_each_thread/rcu interaction but this is off-topic and should
be fixed anyway).

> @@ -348,6 +348,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	struct task_struct *chosen = NULL;
>  	unsigned long chosen_points = 0;
>
> +	rcu_read_lock();
>  	do_each_thread(g, p) {
>  		unsigned int points;
>
> @@ -370,6 +371,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			chosen_points = points;
>  		}
>  	} while_each_thread(g, p);
> +	if (chosen)
> +		get_task_struct(chosen);

OK, so the caller should do put_task_struct().

But, unless I misread the patch,

> @@ -454,6 +458,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> ...
> +	rcu_read_lock();
> +	p = find_lock_task_mm(victim);
> +	if (!p) {
> +		rcu_read_unlock();
> +		put_task_struct(victim);
>  		return;
> +	} else
> +		victim = p;

And, before return,

> +	put_task_struct(victim);

Doesn't look right if victim != p.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
