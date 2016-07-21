Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D231A82963
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 08:41:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id r97so51578329lfi.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 05:41:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t16si4215331lfd.323.2016.07.21.05.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 05:41:56 -0700 (PDT)
Date: Thu, 21 Jul 2016 08:41:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160721124144.GB21806@cmpxchg.org>
References: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467045594-20990-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Vladimir,

Sorry for getting to this only now.

On Mon, Jun 27, 2016 at 07:39:54PM +0300, Vladimir Davydov wrote:
> When selecting an oom victim, we use the same heuristic for both memory
> cgroup and global oom. The only difference is the scope of tasks to
> select the victim from. So we could just export an iterator over all
> memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> duplicate pieces of it in memcontrol.c reusing some initially private
> functions of oom_kill.c in order to not duplicate all of it. That looks
> ugly and error prone, because any modification of select_bad_process
> should also be propagated to mem_cgroup_out_of_memory.
> 
> Let's rework this as follows: keep all oom heuristic related code
> private to oom_kill.c and make oom_kill.c use exported memcg functions
> when it's really necessary (like in case of iterating over memcg tasks).

This approach, with the control flow in the OOM code, makes a lot of
sense to me. I think it's particularly useful in preparation for
supporting cgroup-aware OOM killing, where not just individual tasks
but entire cgroups are evaluated and killed as opaque memory units.

I'm thinking about doing something like the following, which should be
able to work regardless on what cgroup level - root, intermediate, or
leaf node - the OOM killer is invoked, and this patch works toward it:

struct oom_victim {
        bool is_memcg;
        union {
                struct task_struct *task;
                struct mem_cgroup *memcg;
        } entity;
        unsigned long badness;
};

oom_evaluate_memcg(oc, memcg, victim)
{
        if (memcg == root) {
                for_each_memcg_process(p, memcg) {
                        badness = oom_badness(oc, memcg, p);
                        if (badness == some_special_value) {
                                ...
                        } else if (badness > victim->badness) {
				victim->is_memcg = false;
				victim->entity.task = p;
				victim->badness = badness;
			}
                }
        } else {
                badness = 0;
                for_each_memcg_process(p, memcg) {
                        b = oom_badness(oc, memcg, p);
                        if (b == some_special_value)
                                ...
                        else
                                badness += b;
                }
                if (badness > victim.badness)
                        victim->is_memcg = true;
			victim->entity.memcg = memcg;
			victim->badness = badness;
		}
        }
}

oom()
{
        struct oom_victim victim = {
                .badness = 0,
        };

        for_each_mem_cgroup_tree(memcg, oc->memcg)
                oom_evaluate_memcg(oc, memcg, &victim);

        if (!victim.badness && !is_sysrq_oom(oc)) {
                dump_header(oc, NULL);
                panic("Out of memory and no killable processes...\n");
        }

        if (victim.badness != -1) {
                oom_kill_victim(oc, &victim);
                schedule_timeout_killable(1);
        }

        return true;
}

But even without that, with the unification of two identical control
flows and the privatization of a good amount of oom killer internals,
the patch speaks for itself.
	
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
