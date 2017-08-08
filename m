Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5D5E6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 19:14:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so46602218pfg.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:14:53 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id v8si1690161plg.655.2017.08.08.16.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 16:14:52 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id y129so20551202pgy.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:14:52 -0700 (PDT)
Date: Tue, 8 Aug 2017 16:14:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v4 3/4] mm, oom: introduce oom_priority for memory cgroups
In-Reply-To: <20170726132718.14806-4-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708081607230.54505@chino.kir.corp.google.com>
References: <20170726132718.14806-1-guro@fb.com> <20170726132718.14806-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 26 Jul 2017, Roman Gushchin wrote:

> Introduce a per-memory-cgroup oom_priority setting: an integer number
> within the [-10000, 10000] range, which defines the order in which
> the OOM killer selects victim memory cgroups.
> 
> OOM killer prefers memory cgroups with larger priority if they are
> populated with elegible tasks.
> 
> The oom_priority value is compared within sibling cgroups.
> 
> The root cgroup has the oom_priority 0, which cannot be changed.
> 

Awesome!  Very excited to see that you implemented this suggestion and it 
is similar to priority based oom killing that we have done.  I think this 
kind of support is long overdue in the oom killer.

Comment inline.

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/memcontrol.h |  3 +++
>  mm/memcontrol.c            | 55 ++++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 56 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b21bbb0edc72..d31ac58e08ad 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -206,6 +206,9 @@ struct mem_cgroup {
>  	/* cached OOM score */
>  	long oom_score;
>  
> +	/* OOM killer priority */
> +	short oom_priority;
> +
>  	/* handle for "memory.events" */
>  	struct cgroup_file events_file;
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba72d1cf73d0..2c1566995077 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2710,12 +2710,21 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  	for (;;) {
>  		struct cgroup_subsys_state *css;
>  		struct mem_cgroup *memcg = NULL;
> +		short prio = SHRT_MIN;
>  		long score = LONG_MIN;
>  
>  		css_for_each_child(css, &root->css) {
>  			struct mem_cgroup *iter = mem_cgroup_from_css(css);
>  
> -			if (iter->oom_score > score) {
> +			if (iter->oom_score == 0)
> +				continue;
> +
> +			if (iter->oom_priority > prio) {
> +				memcg = iter;
> +				prio = iter->oom_priority;
> +				score = iter->oom_score;
> +			} else if (iter->oom_priority == prio &&
> +				   iter->oom_score > score) {
>  				memcg = iter;
>  				score = iter->oom_score;
>  			}

Your tiebreaking is done based on iter->oom_score, which I suppose makes 
sense given that the oom killer traditionally tries to kill from the 
largest memory hogging process.

We actually tiebreak on a timestamp of memcg creation and prefer to kill 
from the newer memcg when iter->oom_priority is the same.  The reasoning 
is that we schedule jobs on a machine that have an inherent priority but 
is unaware of other jobs running at the same priority and so the kill 
decision, if based on iter->oom_score, may differ based on current memory 
usage.

I'm not necessarily arguing against using iter->oom_score, but was 
wondering if you would also find that tiebreaking based on a timestamp 
when priorities are the same is a more clear semantic to describe?  It's 
similar to how the system oom killer tiebreaked based on which task_struct 
appeared later in the tasklist when memory usage was the same.

Your approach makes oom killing less likely in the near term since it 
kills a more memory hogging memcg, but has the potential to lose less 
work.  A timestamp based approach loses the least amount of work by 
preferring to kill newer memcgs but oom killing may be more frequent if 
smaller child memcgs are killed.  I would argue the former is the 
responsibility of the user for using the same priority.

> @@ -2782,7 +2791,15 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
>  	 * For system-wide OOMs we should consider tasks in the root cgroup
>  	 * with oom_score larger than oc->chosen_points.
>  	 */
> -	if (!oc->memcg) {
> +	if (!oc->memcg && !(oc->chosen_memcg &&
> +			    oc->chosen_memcg->oom_priority > 0)) {
> +		/*
> +		 * Root memcg has priority 0, so if chosen memcg has lower
> +		 * priority, any task in root cgroup is preferable.
> +		 */
> +		if (oc->chosen_memcg && oc->chosen_memcg->oom_priority < 0)
> +			oc->chosen_points = 0;
> +
>  		select_victim_root_cgroup_task(oc);
>  
>  		if (oc->chosen && oc->chosen_memcg) {
> @@ -5373,6 +5390,34 @@ static ssize_t memory_oom_kill_all_tasks_write(struct kernfs_open_file *of,
>  	return nbytes;
>  }
>  
> +static int memory_oom_priority_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +
> +	seq_printf(m, "%d\n", memcg->oom_priority);
> +
> +	return 0;
> +}
> +
> +static ssize_t memory_oom_priority_write(struct kernfs_open_file *of,
> +				char *buf, size_t nbytes, loff_t off)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	int oom_priority;
> +	int err;
> +
> +	err = kstrtoint(strstrip(buf), 0, &oom_priority);
> +	if (err)
> +		return err;
> +
> +	if (oom_priority < -10000 || oom_priority > 10000)
> +		return -EINVAL;
> +
> +	memcg->oom_priority = (short)oom_priority;
> +
> +	return nbytes;
> +}
> +
>  static int memory_events_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> @@ -5499,6 +5544,12 @@ static struct cftype memory_files[] = {
>  		.write = memory_oom_kill_all_tasks_write,
>  	},
>  	{
> +		.name = "oom_priority",
> +		.flags = CFTYPE_NOT_ON_ROOT,
> +		.seq_show = memory_oom_priority_show,
> +		.write = memory_oom_priority_write,
> +	},
> +	{
>  		.name = "events",
>  		.flags = CFTYPE_NOT_ON_ROOT,
>  		.file_offset = offsetof(struct mem_cgroup, events_file),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
