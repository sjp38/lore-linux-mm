Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 852BBC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:34:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B4220873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:34:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B4220873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B81C28E0002; Tue, 18 Jun 2019 08:34:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B309C8E0001; Tue, 18 Jun 2019 08:34:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F91F8E0002; Tue, 18 Jun 2019 08:34:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 510118E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:34:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s7so21050415edb.19
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:34:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JvYzcBgQftDTYXLbzEaf4GddULUT5mptiejrlTjhiGI=;
        b=m7iV0asnUUr1AaBoSx5pPQiwovxQskjPbulonLGjlh1ZWhfCUvd4P9GjZRipi1qEu3
         MI0bJ6uEa1tJ6FcRvgL4ki9t4+aEaKSn2nzeuLA50D2fzBm/kgxKqXlmIbXtp5fIjJ2C
         2JgfwS8tor97B1xjYYJAoGqLK9I9/2ezXFqcWj+egAsJWmXP38RnsnGMFhh/79F4nC8r
         C5DL97MUSK6Grz/dajcFZSKRjqNVh3cxdGqz8PGHmWNKKAqr0xWkn+oVYJTY88ZrxE3z
         2tLPxpYx40qcIwWHMxtYwYWa8apKE//ygy+BBkwTmt2O4PEH2h+5yIsqTtV9TNYxTkSn
         kKaQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVr/2sEE5765DO0FXD3KbNd902ct6j6wbKgo/ay+BIpJBP9rFGC
	2G52k6qv1Y6+khASaHm7BTBfVrPiK1U8dD0vVGIJADEN5dteOnudIImjAx5j13fRE2CzlAFfZvN
	Qp54rJ/bqs4lMrPaMUYwu8xgZ+jmpN0BWZFWNacXJk7wN49PJXvUMXSC2w0Zv/n4=
X-Received: by 2002:a50:f98a:: with SMTP id q10mr57384196edn.267.1560861288879;
        Tue, 18 Jun 2019 05:34:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCOqETxx3gnQpLf4uEu3M3hVFDeK79+HwhYiiWhWQwXP7yHvyKAwIiQuJaEk/Ek8jloeU5
X-Received: by 2002:a50:f98a:: with SMTP id q10mr57384123edn.267.1560861288099;
        Tue, 18 Jun 2019 05:34:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560861288; cv=none;
        d=google.com; s=arc-20160816;
        b=oMyKVeyXSbTW1RPWs0BjHdhgSTcC7dgJ54T/VwMb7QX9W4D0if1MTSzv1LaudrW9bl
         xs4tryIhGmCELN6xBm9nEjsY+zyDUxYqYubEUMArx6Nr/t2gQl28pT9uUORj05WfuLok
         VoKPvjqrhc7sSCPTtu1sgh92xMKja2rh4GrPctjRsW+yNqrszxCSh4RYFtxxht1Y4DVS
         wT9LaKeUeBY8D0ElPBdEpCzifP+zUVRnAvzPqSKXa4dsCGjANWr/iOTinj83A0p6hJGV
         htveqtsDZyi5w+mmRYtbOp+yspjWm1qGV7qkZiugQXvgxAvRjnS4aCuHm33OcMb5ddeA
         h4ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JvYzcBgQftDTYXLbzEaf4GddULUT5mptiejrlTjhiGI=;
        b=iRTRhuFgk2rVQLFWL4ezbTm032V378VzcSghqQC80UDgg2Hr3Cwhz/+5XuUUFv5xls
         bnmUXrWyEmyzGeXqd0tIWflPbn/RfiJcvXt+M/92pZRVe8v20eICFB5SBWlHM6d1rfbf
         yjOnwjyYPmDAw9aqzntS2VUBrLXZCwcOeSoi1rWJdueEzH81Z5t309i0X/uCfPLUFNcB
         dw1kmVoEmyBkcGghaUcCNzaKUM9bFRvFHwW0YJbj7+Iwwy6S4cCGcwd+Ur1uRkZBJfzD
         kyfAS3qeofslJ8+F2Paa3VGvfxHRFx3X8FqsPLSdEwiTNwr6zGyL91Ez3eIm8YmpYGVW
         SLSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si10435153eds.315.2019.06.18.05.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:34:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B67BAE51;
	Tue, 18 Jun 2019 12:34:47 +0000 (UTC)
Date: Tue, 18 Jun 2019 14:34:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, oom: fix oom_unkillable_task for memcg OOMs
Message-ID: <20190618123446.GE3318@dhcp22.suse.cz>
References: <20190617231207.160865-1-shakeelb@google.com>
 <20190617231207.160865-2-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617231207.160865-2-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 16:12:07, Shakeel Butt wrote:
> Currently oom_unkillable_task() checks mems_allowed even for memcg OOMs
> which does not make sense as memcg OOMs can not be triggered due to
> numa constraints. Fixing that.

"Fixing that" is a poor description of the fix. Also it is quite useful
to note that it is not only bogus to check mems_allowed. It is also
harmful as per the syzbot test IIRC. Pasting the report here would
be helpful as well.

> This commit also removed the bogus usage of oom_unkillable_task() from
> oom_badness(). Currently reading /proc/[pid]/oom_score will do a bogus
> cpuset_mems_allowed_intersects() check. Removing that.

Again, there shouldn't be any real reason to squash the two things into
a single patch. This is a subtle bug/behavior on its own because the
result of oom_badness depends on the calling process context. This
should be called out in the changelog explicitly.

> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Other than that it looks good to me. I will ack after the split out and
the changelog improvements.

Thanks!

> ---
> Changelog since v1:
> - Divide the patch into two patches.
> 
>  fs/proc/base.c      |  3 +--
>  include/linux/oom.h |  1 -
>  mm/oom_kill.c       | 28 +++++++++++++++-------------
>  3 files changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index b8d5d100ed4a..57b7a0d75ef5 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -532,8 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
>  	unsigned long totalpages = totalram_pages() + total_swap_pages;
>  	unsigned long points = 0;
>  
> -	points = oom_badness(task, NULL, NULL, totalpages) *
> -					1000 / totalpages;
> +	points = oom_badness(task, totalpages) * 1000 / totalpages;
>  	seq_printf(m, "%lu\n", points);
>  
>  	return 0;
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index d07992009265..c696c265f019 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -108,7 +108,6 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
>  bool __oom_reap_task_mm(struct mm_struct *mm);
>  
>  extern unsigned long oom_badness(struct task_struct *p,
> -		struct mem_cgroup *memcg, const nodemask_t *nodemask,
>  		unsigned long totalpages);
>  
>  extern bool out_of_memory(struct oom_control *oc);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index bd80997e0969..d779d9da1069 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -152,20 +152,23 @@ static inline bool is_memcg_oom(struct oom_control *oc)
>  }
>  
>  /* return true if the task is not adequate as candidate victim task. */
> -static bool oom_unkillable_task(struct task_struct *p,
> -		struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +static bool oom_unkillable_task(struct task_struct *p, struct oom_control *oc)
>  {
>  	if (is_global_init(p))
>  		return true;
>  	if (p->flags & PF_KTHREAD)
>  		return true;
>  
> -	/* When mem_cgroup_out_of_memory() and p is not member of the group */
> -	if (memcg && !task_in_mem_cgroup(p, memcg))
> -		return true;
> +	/*
> +	 * For memcg OOM, we reach here through mem_cgroup_scan_tasks(), no
> +	 * need to check p's memcg membership and the checks after this
> +	 * are irrelevant for memcg OOMs.
> +	 */
> +	if (is_memcg_oom(oc))
> +		return false;
>  
>  	/* p may not have freeable memory in nodemask */
> -	if (!has_intersects_mems_allowed(p, nodemask))
> +	if (!has_intersects_mems_allowed(p, oc->nodemask))
>  		return true;
>  
>  	return false;
> @@ -201,13 +204,12 @@ static bool is_dump_unreclaim_slabs(void)
>   * predictable as possible.  The goal is to return the highest value for the
>   * task consuming the most memory to avoid subsequent oom failures.
>   */
> -unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> -			  const nodemask_t *nodemask, unsigned long totalpages)
> +unsigned long oom_badness(struct task_struct *p, unsigned long totalpages)
>  {
>  	long points;
>  	long adj;
>  
> -	if (oom_unkillable_task(p, memcg, nodemask))
> +	if (is_global_init(p) || p->flags & PF_KTHREAD)
>  		return 0;
>  
>  	p = find_lock_task_mm(p);
> @@ -318,7 +320,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  	struct oom_control *oc = arg;
>  	unsigned long points;
>  
> -	if (oom_unkillable_task(task, NULL, oc->nodemask))
> +	if (oom_unkillable_task(task, oc))
>  		goto next;
>  
>  	/*
> @@ -342,7 +344,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  		goto select;
>  	}
>  
> -	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
> +	points = oom_badness(task, oc->totalpages);
>  	if (!points || points < oc->chosen_points)
>  		goto next;
>  
> @@ -390,7 +392,7 @@ static int dump_task(struct task_struct *p, void *arg)
>  	struct oom_control *oc = arg;
>  	struct task_struct *task;
>  
> -	if (oom_unkillable_task(p, NULL, oc->nodemask))
> +	if (oom_unkillable_task(p, oc))
>  		return 0;
>  
>  	task = find_lock_task_mm(p);
> @@ -1090,7 +1092,7 @@ bool out_of_memory(struct oom_control *oc)
>  	check_panic_on_oom(oc, constraint);
>  
>  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
> -	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
> +	    current->mm && !oom_unkillable_task(current, oc) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
>  		oc->chosen = current;
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Michal Hocko
SUSE Labs

