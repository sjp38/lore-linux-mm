Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E08F26B0256
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:15:40 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so25926072wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:15:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j10si7417569wjf.167.2015.07.29.06.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 06:15:39 -0700 (PDT)
Date: Wed, 29 Jul 2015 09:14:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150729131454.GB10001@cmpxchg.org>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150710140533.GB29540@dhcp22.suse.cz>
 <20150714151823.GG17660@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714151823.GG17660@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 14, 2015 at 05:18:23PM +0200, Michal Hocko wrote:
> On Fri 10-07-15 16:05:33, Michal Hocko wrote:
> > JFYI: I've found some more issues while hamerring this more.
> 
> OK so the main issue is quite simple but I have completely missed it when
> thinking about the patch before. clone(CLONE_VM) without CLONE_THREAD is
> really nasty and it will easily lockup the machine with preempt. disabled
> for ever. It goes like this:
> taskA (in memcg A)
>   taskB = clone(CLONE_VM)
> 				taskB
> 				  A -> B	# Both tasks charge to B now
> 				  exit()	# No tasks in B -> can be
> 				  		# offlined now
> 				css_offline()
>   mem_cgroup_try_charge
>     get_mem_cgroup_from_mm
>       rcu_read_lock()
>       do {
>       } while css_tryget_online(mm->memcg)	# will never succeed
>       rcu_read_unlock()
> 
> taskA and taskB are basically independent entities wrt. the life
> cycle (unlike threads which are bound to the group leader). The
> previous code handles this by re-ownering during exit by the monster
> mm_update_next_owner.
>
> I can see the following options without reintroducing reintroducing
> some form of mm_update_next_owner:
> 
> 1) Do not allow offlining a cgroup if we have active users in it.  This
> would require a callback from the cgroup core to the subsystem called if
> there are no active tasks tracked by the cgroup core. Tracking on the memcg
> side doesn't sound terribly hard - just mark a mm_struct as an alien and
> count the number of aliens during the move in mem_cgroup. mm_drop_memcg
> then drops the counter. We could end up with EBUSY cgroup without any
> visible tasks which is a bit awkward.

You couldn't remove the group, and you wouldn't know which task needs
to move to get the mm out of there. That's no good.

> 2) update get_mem_cgroup_from_mm and others to fallback to the parent
> memcg if the current one is offline. This would be in line with charge
> reparenting we used to do. I cannot say I would like this because it
> allows for easy runaway to the root memcg if the hierarchy is not
> configured cautiously. The code would be also quite tricky because each
> direct consumer of mm->memcg would have to be aware of this. This is
> awkward.

In the unified hierarchy, there won't be tasks inside intermediate
nodes, so reparenting would lead to surprising behavior.

> 3) fail mem_cgroup_can_attach if we are trying to migrate a task sharing
> mm_struct with a process outside of the tset. If I understand the
> tset properly this would require all the sharing tasks to be migrated
> together and we would never end up with task_css != &task->mm->css.
> __cgroup_procs_write doesn't seem to support multi pid move currently
> AFAICS, though. cgroup_migrate_add_src, however, seems to be intended
> for this purpose so this should be doable. Without that support we would
> basically disallow migrating these tasks - I wouldn't object if you ask
> me.

I'd prefer not adding controller-specific failure modes for attaching,
and this too would lead to very non-obvious behavior.

> Do you see other options? From the above three options the 3rd one
> sounds the most sane to me and the 1st quite easy to implement. Both will
> require some cgroup core work though. But maybe we would be good enough
> with 3rd option without supporting moving schizophrenic tasks and that
> would be reduced to memcg code.

A modified form of 1) would be to track the mms referring to a memcg
but during offline search the process tree for a matching task. This
is heavy-handed, but it's a rare case and this work would be done in
the cgroup removal path rather than during task exit. This is stolen
from the current mm_update_next_owner():

list_for_each_entry(mm, memcg->mms, memcg_list) {
    for_each_process(g) {
        if (g->flags & PF_KTHREAD)
            continue;
        for_each_thread(g, c) {
            if (c->mm == mm)
                goto assign;
            if (c->mm)
                break;
        }
    }
assign:
    memcg = mem_cgroup_from_task(c);
    mm->memcg = memcg;
    list_move(&mm->memcg_list, &memcg->mms);
}

(plus appropriate synchronization, of course)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
