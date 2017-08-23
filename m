Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02B5B2803E9
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:05:30 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so6143937pfj.11
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 11:05:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f35si1473597plh.628.2017.08.23.11.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 11:05:28 -0700 (PDT)
Date: Wed, 23 Aug 2017 19:04:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170823174603.GA26190@castle.DHCP.thefacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <20170822170344.GA13547@cmpxchg.org>
 <20170823162031.GA13578@castle.dhcp.TheFacebook.com>
 <20170823172441.GA29085@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170823172441.GA29085@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 23, 2017 at 01:24:41PM -0400, Johannes Weiner wrote:
> Hi,
> 
> On Wed, Aug 23, 2017 at 05:20:31PM +0100, Roman Gushchin wrote:
> > On Tue, Aug 22, 2017 at 01:03:44PM -0400, Johannes Weiner wrote:
> > > > +	css_task_iter_start(&memcg->css, 0, &it);
> > > > +	while ((task = css_task_iter_next(&it))) {
> > > > +		/*
> > > > +		 * If there are no tasks, or all tasks have oom_score_adj set
> > > > +		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
> > > > +		 * don't select this memory cgroup.
> > > > +		 */
> > > > +		if (!elegible &&
> > > > +		    (memcg->oom_kill_all_tasks ||
> > > > +		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
> > > > +			elegible = 1;
> > > 
> > > This is a little awkward to read. How about something like this:
> > > 
> > > 	/*
> > > 	 * When killing individual tasks, we respect OOM score adjustments:
> > > 	 * at least one task in the group needs to be killable for the group
> > > 	 * to be oomable.
> > > 	 *
> > > 	 * Also check that previous OOM kills have finished, and abort if
> > > 	 * there are any pending OOM victims.
> > > 	 */
> > > 	oomable = memcg->oom_kill_all_tasks;
> > > 	while ((task = css_task_iter_next(&it))) {
> > > 		if (!oomable && task->signal_oom_score_adj != OOM_SCORE_ADJ_MIN)
> > > 			oomable = 1;
> > > 
> > > > +		if (tsk_is_oom_victim(task) &&
> > > > +		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
> > > > +			elegible = -1;
> > > > +			break;
> > > > +		}
> > > > +	}
> > > > +	css_task_iter_end(&it);
> > 
> > We ignore oom_score_adj if oom_kill_all_tasks is set, it's
> > not reflected in your version. Anyway, I've moved the comments block
> > outside and rephrased it to make more clear.
> 
> Yes it is...? We only respect the score if !oomable, which is set to
> oom_kill_all_tasks.

Sorry, haven't noticed this.

> > > >  static int memory_events_show(struct seq_file *m, void *v)
> > > >  {
> > > >  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> > > > @@ -5310,6 +5512,12 @@ static struct cftype memory_files[] = {
> > > >  		.write = memory_max_write,
> > > >  	},
> > > >  	{
> > > > +		.name = "oom_kill_all_tasks",
> > > > +		.flags = CFTYPE_NOT_ON_ROOT,
> > > > +		.seq_show = memory_oom_kill_all_tasks_show,
> > > > +		.write = memory_oom_kill_all_tasks_write,
> > > > +	},
> > > 
> > > This name is quite a mouthful and reminiscent of the awkward v1
> > > interface names. It doesn't really go well with the v2 names.
> > > 
> > > How about memory.oom_group?
> > 
> > I'd prefer to have something more obvious. I've renamed
> > memory.oom_kill_all_tasks to memory.oom_kill_all, which was earlier suggested
> > by Vladimir. Are you ok with it?
> 
> No, we should be striving for short and sweet mnemonics that express a
> concept (oom applies to group, not member tasks) instead of underscore
> sentences that describe an implementation (upon oom, kill all tasks in
> the group).

Why do you call it implementation, it's definitely an user's intention
"if a cgroup is under OOM, all belonging processes should be killed".

How it can be implemented differently?

> 
> It's better to have newbies consult the documentation once than making
> everybody deal with long and cumbersome names for the rest of time.
> 
> Like 'ls' being better than 'read_and_print_directory_contents'.

I don't think it's a good argument here: realistically, nobody will type
the knob's name often. Your option is shorter only by 3 characters :)

Anyway, I'm ok with memory.oom_group too, if everybody else prefer it.
Michal, David?
What's your opinion?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
