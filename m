Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 776A36B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 17:04:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1014857pbb.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 14:04:38 -0700 (PDT)
Date: Tue, 10 Jul 2012 14:04:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/5] mm, oom: reduce dependency on tasklist_lock
In-Reply-To: <20120703181708.GB14104@redhat.com>
Message-ID: <alpine.DEB.2.00.1207101400500.12399@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com> <20120703181708.GB14104@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 3 Jul 2012, Oleg Nesterov wrote:

> >  		      unsigned int points, unsigned long totalpages,
> >  		      struct mem_cgroup *memcg, nodemask_t *nodemask,
> > @@ -454,6 +462,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	 */
> >  	if (p->flags & PF_EXITING) {
> >  		set_tsk_thread_flag(p, TIF_MEMDIE);
> > +		put_task_struct(p);
> >  		return;
> >  	}
> >  
> > @@ -471,6 +480,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	 * parent.  This attempts to lose the minimal amount of work done while
> >  	 * still freeing memory.
> >  	 */
> > +	read_lock(&tasklist_lock);
> >  	do {
> >  		list_for_each_entry(child, &t->children, sibling) {
> >  			unsigned int child_points;
> > @@ -483,15 +493,26 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  			child_points = oom_badness(child, memcg, nodemask,
> >  								totalpages);
> >  			if (child_points > victim_points) {
> > +				put_task_struct(victim);
> >  				victim = child;
> >  				victim_points = child_points;
> > +				get_task_struct(victim);
> >  			}
> >  		}
> >  	} while_each_thread(p, t);
> > +	read_unlock(&tasklist_lock);
> >  
> > -	victim = find_lock_task_mm(victim);
> > -	if (!victim)
> > +	rcu_read_lock();
> > +	p = find_lock_task_mm(victim);
> > +	if (!p) {
> > +		rcu_read_unlock();
> > +		put_task_struct(victim);
> >  		return;
> > +	} else if (victim != p) {
> > +		get_task_struct(p);
> > +		put_task_struct(victim);
> > +		victim = p;
> > +	}
> >  
> >  	/* mm cannot safely be dereferenced after task_unlock(victim) */
> >  	mm = victim->mm;
> > @@ -522,9 +543,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  			task_unlock(p);
> >  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> >  		}
> > +	rcu_read_unlock();
> >  
> >  	set_tsk_thread_flag(victim, TIF_MEMDIE);
> >  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> > +	put_task_struct(victim);
> 
> It seems to me we can avoid this get/put dance in oom_kill_process(),
> just you need to extend the rcu-protected area. In this case the caller
> of select_bad_process() does a single put_, and
> sysctl_oom_kill_allocating_task doesn't need get_task_struct(current).
> Look more clean/simple to me.
> 

We could grab rcu_read_lock() before the first tasklist scan and hold it 
until a process is killed, yes, but there's a higher liklihood that it 
will never be dropped for concurrent oom kills in the same way that the 
write-side of tasklist_lock is currently starved.  On a system with a 
large number of cpus this isn't even a rare situation to run into: the 
read lock will never be dropped on all cpus.  I've attempted to make it as 
fine-grained as possible and only hold it when absolutely required and use 
task references to keep the selected threads around until they are killed.

Let me know if you have a better solution to rcu read lock starvation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
