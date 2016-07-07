Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1A776B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:31:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so9471949lfa.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:31:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bp6si2542409wjb.147.2016.07.07.04.31.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:31:32 -0700 (PDT)
Date: Thu, 7 Jul 2016 13:31:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160707113130.GI5379@dhcp22.suse.cz>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

I've got lost in the follow up patches. Could you post only rework of
this particular one, please?

You have already noticed that nodemask check is tricky and the memcg
check would be tricky for different reason.

On Sun 03-07-16 11:38:20, Tetsuo Handa wrote:
[...]
> +bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +{
> +	struct oom_mm *mm;
> +	bool ret = false;
> +
> +	spin_lock(&oom_mm_lock);
> +	list_for_each_entry(mm, &oom_mm_list, list) {
> +		if (memcg && mm->memcg != memcg)
> +			continue;
> +		if (nodemask && mm->nodemask != nodemask)
> +			continue;
> +		ret = true;
> +		break;
> +	}
> +	spin_unlock(&oom_mm_lock);
> +	return ret;
> +}
> +
>  enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  					struct task_struct *task)
>  {
[...]
> @@ -647,18 +668,37 @@ subsys_initcall(oom_init)
>  /**
>   * mark_oom_victim - mark the given task as OOM victim
>   * @tsk: task to mark
> + * @oc: oom_control
>   *
>   * Has to be called with oom_lock held and never after
>   * oom has been disabled already.
>   */
> -void mark_oom_victim(struct task_struct *tsk)
> +void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
>  {
> +	struct mm_struct *mm = tsk->mm;
> +
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>  		return;
>  	atomic_inc(&tsk->signal->oom_victims);
>  	/*
> +	 * Since mark_oom_victim() is called from multiple threads,
> +	 * connect this mm to oom_mm_list only if not yet connected.
> +	 *
> +	 * Since mark_oom_victim() is called with a stable mm (i.e.
> +	 * mm->mm_userst > 0), exit_oom_mm() from __mmput() can't be called
> +	 * before we add this mm to the list.
> +	 */
> +	spin_lock(&oom_mm_lock);
> +	if (!mm->oom_mm.list.next) {
> +		atomic_inc(&mm->mm_count);
> +		mm->oom_mm.memcg = oc->memcg;
> +		mm->oom_mm.nodemask = oc->nodemask;
> +		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
> +	}

Here you are storing the memcg where the OOM killer happened but later
on we might encounter an OOM on upper level of the memcg hierarchy and
we want to prevent from the oom killer if there is an mm which hasn't
released a memory from the lower level of the hierarchy. E.g.
          A
         / \
        B   C

C hits a limit and invokes oom. Then we hit oom on A because of a charge
for B. Now for_each_mem_cgroup_tree would encounter such a task/mm and
abort the selection. With a pure memcg pointer check we would skip that
mm. This would be fixable by doing mem_cgroup_is_descendant but that
requires an alive memcg's css so you have to pin it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
