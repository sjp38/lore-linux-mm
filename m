Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2947AC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFC842082C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFC842082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B8328E0002; Tue, 18 Jun 2019 08:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 767528E0001; Tue, 18 Jun 2019 08:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62EB08E0002; Tue, 18 Jun 2019 08:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 127398E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:25:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so21083638edt.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:25:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kWVRrUQj9mWoqQlvFFTdbBytWIYtInyZrJjLe8l2Oqs=;
        b=I1ov0sfSfV+pDtYpRfJ25rww29S18+wrxLmyKZiCIPPJKFqw75d4MAyTDFwXvs+E2u
         TyFcEvnbWOJNK06U6IuPlXYRjjfsRzESW4TKcJd/iA04dmC5SwrxvQ+dTqAIIhGR/FmO
         A9UHvlEFZIaZtIkeDQjUO+dzU0iOvwfxngMUEW/ScB/Eu1El5k8U5UUXuGvuhDFIbP4R
         SGtRKmRw4krMac/u8Iihw6O30l9jcVbCOlmLkaUSV0K8em119HnwW36VJ8/jBqXwKBRb
         hYDCN4U6Qy0nTNAOPVDGoD5bTGIMfqufE2w921DjpOnOHPVEsteQcqOL4iOTqUKKsFaz
         gSrA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUmR8QueKzQHyqhgPFnBOZIxVB1YTsTCAZDH4z/CYBm6sEGq+Ti
	QMVRTqTUHUNnw8N0cPzNMd09sLFCVNjjbLLb5YTMrK/zoet18YlQmOfIt4/iBJSseRwGcc7sYM6
	rqmw8R2pWJmQgJ40EvP5BKK275oGGnnAnThYtQ+BeAe+Y6xf15E2umjkSN3TAgRg=
X-Received: by 2002:a50:9273:: with SMTP id j48mr98120018eda.285.1560860702597;
        Tue, 18 Jun 2019 05:25:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDGc0IjzBXcoCOGu1/znWEVzDAqWFgd5SlGeYtCjU/L3CD137OVKg8Npc2c0R5OX8auWdU
X-Received: by 2002:a50:9273:: with SMTP id j48mr98119938eda.285.1560860701811;
        Tue, 18 Jun 2019 05:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560860701; cv=none;
        d=google.com; s=arc-20160816;
        b=JJqA9GeC64JTmah7kM9/ROFPFYBSjAfrDIsQB5A4w4JV4Dc4idE7s0HIAxcnq78gKR
         rAtHJaICX50Cnjc2Ibd9liCUNvIMb1N8PgReXMYoqMfLT4AiG7kvmKIyej6kLIRr6VuN
         /xOgox8h7LhQBdo0LDy5NJ5GV6tYZHGz42DgDpxdGeOgjpG/q6mqveJashIhGW8XI+wb
         8ITvSPfvBnt9Co4K97i7zUu/zOB/XpDvKZGTlZ8BHb3r9sbLJdYllvaCqtrOmPGC1rjM
         adFC/+68QhX0a4d5MaqDobZO5xZm2v6r5vRJBHvlL3/4ru1oBiimkCvfsIaZ4tXfmFDz
         yXLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kWVRrUQj9mWoqQlvFFTdbBytWIYtInyZrJjLe8l2Oqs=;
        b=QZ9hytDQoTu3UhGBgdEyM4IW76ru2vqrMlIZLIyveH8uq7TsRPYHUzkm0pzFZY1EDL
         yqb+pI1QpgKVbMWnvrq4lucR+4XrzsO0FjcufNbY6E35HvYUnkFa8afw5x/avgNFCD+p
         yIMuOIBE4xl5HoL4o0VPEkmw1IkYNRXlTymKIaAlneVS3vwzlVIsoj2cClP1G8CQk5UR
         /aM0D9+5lGdjvW7n/GUlnBe0KFxquw3SLl6ln1A4WKkXofptjiztU6PPo3rzFP6w1EnX
         OToKbYRRkOVPK/pPMMbvAto1kf2IndKik5zdiEPbkTbOse8Naw/xY8y8qm2NER6O7QIW
         ocRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26si8920300eju.361.2019.06.18.05.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:25:01 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4181EAF49;
	Tue, 18 Jun 2019 12:25:01 +0000 (UTC)
Date: Tue, 18 Jun 2019 14:24:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 1/2] mm, oom: refactor dump_tasks for memcg OOMs
Message-ID: <20190618122457.GD3318@dhcp22.suse.cz>
References: <20190617231207.160865-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617231207.160865-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 16:12:06, Shakeel Butt wrote:
> dump_tasks() currently goes through all the processes present on the
> system even for memcg OOMs. Change dump_tasks() similar to
> select_bad_process() and use mem_cgroup_scan_tasks() to selectively
> traverse the processes of the memcgs during memcg OOM.

The changelog is quite modest to be honest. I would go with

"
dump_tasks() traverses all the existing processes even for the memcg OOM
context which is not only unnecessary but also wasteful. This imposes
a long RCU critical section even from a contained context which can be
quite disruptive.

Change dump_tasks() to be aligned with select_bad_process and use
mem_cgroup_scan_tasks to selectively traverse only processes of the
target memcg hierarchy during memcg OOM.
"

> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> Changelog since v1:
> - Divide the patch into two patches.
> 
>  mm/oom_kill.c | 68 ++++++++++++++++++++++++++++++---------------------
>  1 file changed, 40 insertions(+), 28 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 05aaa1a5920b..bd80997e0969 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -385,10 +385,38 @@ static void select_bad_process(struct oom_control *oc)
>  	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
>  }
>  
> +static int dump_task(struct task_struct *p, void *arg)
> +{
> +	struct oom_control *oc = arg;
> +	struct task_struct *task;
> +
> +	if (oom_unkillable_task(p, NULL, oc->nodemask))
> +		return 0;
> +
> +	task = find_lock_task_mm(p);
> +	if (!task) {
> +		/*
> +		 * This is a kthread or all of p's threads have already
> +		 * detached their mm's.  There's no need to report
> +		 * them; they can't be oom killed anyway.
> +		 */
> +		return 0;
> +	}
> +
> +	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
> +		task->pid, from_kuid(&init_user_ns, task_uid(task)),
> +		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> +		mm_pgtables_bytes(task->mm),
> +		get_mm_counter(task->mm, MM_SWAPENTS),
> +		task->signal->oom_score_adj, task->comm);
> +	task_unlock(task);
> +
> +	return 0;
> +}
> +
>  /**
>   * dump_tasks - dump current memory state of all system tasks
> - * @memcg: current's memory controller, if constrained
> - * @nodemask: nodemask passed to page allocator for mempolicy ooms
> + * @oc: pointer to struct oom_control
>   *
>   * Dumps the current memory state of all eligible tasks.  Tasks not in the same
>   * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
> @@ -396,37 +424,21 @@ static void select_bad_process(struct oom_control *oc)
>   * State information includes task's pid, uid, tgid, vm size, rss,
>   * pgtables_bytes, swapents, oom_score_adj value, and name.
>   */
> -static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +static void dump_tasks(struct oom_control *oc)
>  {
> -	struct task_struct *p;
> -	struct task_struct *task;
> -
>  	pr_info("Tasks state (memory values in pages):\n");
>  	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> -	rcu_read_lock();
> -	for_each_process(p) {
> -		if (oom_unkillable_task(p, memcg, nodemask))
> -			continue;
>  
> -		task = find_lock_task_mm(p);
> -		if (!task) {
> -			/*
> -			 * This is a kthread or all of p's threads have already
> -			 * detached their mm's.  There's no need to report
> -			 * them; they can't be oom killed anyway.
> -			 */
> -			continue;
> -		}
> +	if (is_memcg_oom(oc))
> +		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
> +	else {
> +		struct task_struct *p;
>  
> -		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
> -			task->pid, from_kuid(&init_user_ns, task_uid(task)),
> -			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> -			mm_pgtables_bytes(task->mm),
> -			get_mm_counter(task->mm, MM_SWAPENTS),
> -			task->signal->oom_score_adj, task->comm);
> -		task_unlock(task);
> +		rcu_read_lock();
> +		for_each_process(p)
> +			dump_task(p, oc);
> +		rcu_read_unlock();
>  	}
> -	rcu_read_unlock();
>  }
>  
>  static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
> @@ -458,7 +470,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  			dump_unreclaimable_slab();
>  	}
>  	if (sysctl_oom_dump_tasks)
> -		dump_tasks(oc->memcg, oc->nodemask);
> +		dump_tasks(oc);
>  	if (p)
>  		dump_oom_summary(oc, p);
>  }
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Michal Hocko
SUSE Labs

