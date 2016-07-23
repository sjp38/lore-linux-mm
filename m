Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F97B6B0253
	for <linux-mm@kvack.org>; Sat, 23 Jul 2016 10:49:24 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q62so276467738oih.0
        for <linux-mm@kvack.org>; Sat, 23 Jul 2016 07:49:24 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50134.outbound.protection.outlook.com. [40.107.5.134])
        by mx.google.com with ESMTPS id h24si8606786ote.149.2016.07.23.07.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 23 Jul 2016 07:49:22 -0700 (PDT)
Date: Sat, 23 Jul 2016 17:49:13 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160723144913.GA2027@esperanza>
References: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
 <20160721124144.GB21806@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160721124144.GB21806@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 21, 2016 at 08:41:44AM -0400, Johannes Weiner wrote:
> On Mon, Jun 27, 2016 at 07:39:54PM +0300, Vladimir Davydov wrote:
> > When selecting an oom victim, we use the same heuristic for both memory
> > cgroup and global oom. The only difference is the scope of tasks to
> > select the victim from. So we could just export an iterator over all
> > memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> > duplicate pieces of it in memcontrol.c reusing some initially private
> > functions of oom_kill.c in order to not duplicate all of it. That looks
> > ugly and error prone, because any modification of select_bad_process
> > should also be propagated to mem_cgroup_out_of_memory.
> > 
> > Let's rework this as follows: keep all oom heuristic related code
> > private to oom_kill.c and make oom_kill.c use exported memcg functions
> > when it's really necessary (like in case of iterating over memcg tasks).
> 
> This approach, with the control flow in the OOM code, makes a lot of
> sense to me. I think it's particularly useful in preparation for
> supporting cgroup-aware OOM killing, where not just individual tasks
> but entire cgroups are evaluated and killed as opaque memory units.

Yeah, that too. Also, this patch can be thought of as a preparation step
for unified oom locking and oom timeouts (provided we ever agree to add
them). Currently, there's some code in memcg trying to implement proper
locking that would allow running oom in parallel in different cgroups
and wait until memory is actually freed instead of looping and retrying
reclaim. I think it could be reused for global case, although it's going
to be tricky as we need to support legacy cgroup oom control api.

> 
> I'm thinking about doing something like the following, which should be
> able to work regardless on what cgroup level - root, intermediate, or
> leaf node - the OOM killer is invoked, and this patch works toward it:
> 
> struct oom_victim {
>         bool is_memcg;
>         union {
>                 struct task_struct *task;
>                 struct mem_cgroup *memcg;
>         } entity;
>         unsigned long badness;
> };
> 
> oom_evaluate_memcg(oc, memcg, victim)
> {
>         if (memcg == root) {
>                 for_each_memcg_process(p, memcg) {
>                         badness = oom_badness(oc, memcg, p);
>                         if (badness == some_special_value) {
>                                 ...
>                         } else if (badness > victim->badness) {
> 				victim->is_memcg = false;
> 				victim->entity.task = p;
> 				victim->badness = badness;
> 			}
>                 }
>         } else {
>                 badness = 0;
>                 for_each_memcg_process(p, memcg) {
>                         b = oom_badness(oc, memcg, p);
>                         if (b == some_special_value)
>                                 ...
>                         else
>                                 badness += b;
>                 }
>                 if (badness > victim.badness)
>                         victim->is_memcg = true;
> 			victim->entity.memcg = memcg;
> 			victim->badness = badness;

Yeah, that makes sense. However, I don't think we should always kill the
whole cgroup, even if it's badness is highest. IMO what should be killed
- cgroup or task - depends on the workload running inside the container.
Some workloads (e.g. those that fork often) can put up with youngest of
their tasks getting oom-killed, others will just get stuck if one of the
workers is killed - for them we'd better kill the whole container. I
guess we could introduce a per cgroup tunable which would define oom
behavior - whether the whole cgroup should be killed on oom or just one
task/sub-cgroup in the cgroup.

> 		}
>         }
> }
> 
> oom()
> {
>         struct oom_victim victim = {
>                 .badness = 0,
>         };
> 
>         for_each_mem_cgroup_tree(memcg, oc->memcg)
>                 oom_evaluate_memcg(oc, memcg, &victim);
> 
>         if (!victim.badness && !is_sysrq_oom(oc)) {
>                 dump_header(oc, NULL);
>                 panic("Out of memory and no killable processes...\n");
>         }
> 
>         if (victim.badness != -1) {
>                 oom_kill_victim(oc, &victim);
>                 schedule_timeout_killable(1);
>         }
> 
>         return true;
> }
> 
> But even without that, with the unification of two identical control
> flows and the privatization of a good amount of oom killer internals,
> the patch speaks for itself.
> 	
> > Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
