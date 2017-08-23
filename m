Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBA416B04EA
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 12:21:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a2so4165584pfj.12
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 09:21:06 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m16si1390952pli.707.2017.08.23.09.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 09:21:01 -0700 (PDT)
Date: Wed, 23 Aug 2017 17:20:31 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170823162031.GA13578@castle.dhcp.TheFacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <20170822170344.GA13547@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170822170344.GA13547@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Johannes!

Thank you for review!

I do agree with most of the comments, and I will address them in v6.
I'll post it soon.

Please, find some comments below.

On Tue, Aug 22, 2017 at 01:03:44PM -0400, Johannes Weiner wrote:
> Hi Roman,
> 
> great work! This looks mostly good to me now. Below are some nitpicks
> concerning naming and code layout, but nothing major.
> 
> > +
> > +	css_task_iter_start(&memcg->css, 0, &it);
> > +	while ((task = css_task_iter_next(&it))) {
> > +		/*
> > +		 * If there are no tasks, or all tasks have oom_score_adj set
> > +		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
> > +		 * don't select this memory cgroup.
> > +		 */
> > +		if (!elegible &&
> > +		    (memcg->oom_kill_all_tasks ||
> > +		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
> > +			elegible = 1;
> 
> This is a little awkward to read. How about something like this:
> 
> 	/*
> 	 * When killing individual tasks, we respect OOM score adjustments:
> 	 * at least one task in the group needs to be killable for the group
> 	 * to be oomable.
> 	 *
> 	 * Also check that previous OOM kills have finished, and abort if
> 	 * there are any pending OOM victims.
> 	 */
> 	oomable = memcg->oom_kill_all_tasks;
> 	while ((task = css_task_iter_next(&it))) {
> 		if (!oomable && task->signal_oom_score_adj != OOM_SCORE_ADJ_MIN)
> 			oomable = 1;
> 
> > +		if (tsk_is_oom_victim(task) &&
> > +		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
> > +			elegible = -1;
> > +			break;
> > +		}
> > +	}
> > +	css_task_iter_end(&it);

We ignore oom_score_adj if oom_kill_all_tasks is set, it's
not reflected in your version. Anyway, I've moved the comments block
outside and rephrased it to make more clear.

> 
> etc.
> 
> > +
> > +	return elegible > 0 ? memcg_oom_badness(memcg, nodemask) : elegible;
> 
> I find these much easier to read if broken up, even if it's more LOC:
> 
> 	if (eligible <= 0)
> 		return eligible;
> 
> 	return memcg_oom_badness(memcg, nodemask);
> 
> > +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> > +{
> > +	struct mem_cgroup *iter, *parent;
> > +
> > +	for_each_mem_cgroup_tree(iter, root) {
> > +		if (memcg_has_children(iter)) {
> > +			iter->oom_score = 0;
> > +			continue;
> > +		}
> > +
> > +		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask);
> > +		if (iter->oom_score == -1) {
> 
> Please add comments to document the special returns. Maybe #defines
> would be clearer, too.
> 
> > +			oc->chosen_memcg = (void *)-1UL;
> > +			mem_cgroup_iter_break(root, iter);
> > +			return;
> > +		}
> > +
> > +		if (!iter->oom_score)
> > +			continue;
> 
> Same here.
> 
> Maybe a switch would be suitable to handle the abort/no-score cases. 

Not sure about switch/defines, but I've added several comment blocks
to describe possible return values, as well as their handling.
Hope, it will be enough.

> >  static int memory_events_show(struct seq_file *m, void *v)
> >  {
> >  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> > @@ -5310,6 +5512,12 @@ static struct cftype memory_files[] = {
> >  		.write = memory_max_write,
> >  	},
> >  	{
> > +		.name = "oom_kill_all_tasks",
> > +		.flags = CFTYPE_NOT_ON_ROOT,
> > +		.seq_show = memory_oom_kill_all_tasks_show,
> > +		.write = memory_oom_kill_all_tasks_write,
> > +	},
> 
> This name is quite a mouthful and reminiscent of the awkward v1
> interface names. It doesn't really go well with the v2 names.
> 
> How about memory.oom_group?

I'd prefer to have something more obvious. I've renamed
memory.oom_kill_all_tasks to memory.oom_kill_all, which was earlier suggested
by Vladimir. Are you ok with it?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
