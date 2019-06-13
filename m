Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EB40C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02C0020B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 18:56:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02C0020B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BAE88E0004; Thu, 13 Jun 2019 14:56:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86D0A8E0001; Thu, 13 Jun 2019 14:56:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75A978E0004; Thu, 13 Jun 2019 14:56:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 254FF8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:56:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k22so115033ede.0
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VQknKYl4JCcMbhSVgoAsms70D+MeIlcn5Ppo+ZHTUMM=;
        b=AJ2GJwnDDtvUffvXPO7loV3t6epssf7yqhleXWtQ8Eb3IhI5DYLa8PcJ6WGADNmLBl
         PQhP3XwxbsWNb0qqATs6yar9A85DcfJO00tLUagE9uOE0Iqx1uwk7h2wA0QsFJZvlREH
         uj5fijwU2mN56dyejQV7BsfuDLyVuUdgGun1LJkWqumCrwzc6SjPJMaOHW95N4qsOfnW
         N21SJdPkxIfYWzRJOSUVmR4D6lME36wVaO9efVGC1XE8Y9kQu60fVdw3wt7BJENnHxMt
         oOLK+zV0UY7TsdPxpQIIRHHwMUYlckReXPsExQymI+Q/huS6aFVA5s6x9kVCRzz6plzo
         WQzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAXsQeK47qViH7RE66IXxn+1AshUXd0c16C0laRpW2Nh/QdkJnEG
	OEJLs8lvwZKnmI4rFNU0GXEpNy+GojP3ro3bIWlwUEUkpLz0OGSU1bE5XHXFj7j3XazekNRIH3w
	HBtkYh0zgxsQihOtxw37rXY4v7VOfZLfk970aBSEjoM1hEnxokNga53yRpBmAQ4YQKA==
X-Received: by 2002:a50:b839:: with SMTP id j54mr64311182ede.155.1560452203689;
        Thu, 13 Jun 2019 11:56:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKWfWp2WlpgIWpqK9JhuVuaeogzRiXQexU7Kti2wSFijtomMhQ8vamexRMAsiVm1d127je
X-Received: by 2002:a50:b839:: with SMTP id j54mr64311120ede.155.1560452202898;
        Thu, 13 Jun 2019 11:56:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560452202; cv=none;
        d=google.com; s=arc-20160816;
        b=eu8Zy2l6GqljX3Yh0oKrFs/ozeXbNOuXlBmRZsEiySvaF7Qb1sGyFyjNXe6SCdVUet
         V8DweC7zK+AUTmOR6XGY6LHFcdGrAhFtgR3XYigbSrIWzU7jV5F5TJcfQN9oX3jeT852
         nQJd+LVTk046GCk/T9T32r9pziFEh+zpJ8aotO/MqIuiJMYs+BnDfQ+KWdMqkt+SlzJr
         Whgd6/IAZrWqDjX04l3lLHFb/DfN7DD6AlhvysoumQ0Ql7cFUPJyWrymiXY7x0X8L0Is
         rxSMt6U5BLgHu0DltjG8THJOBnsSFUdTjRsVjJItFp9kVZPm9qLZyTbZ/N2LTRihyewX
         Q16Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VQknKYl4JCcMbhSVgoAsms70D+MeIlcn5Ppo+ZHTUMM=;
        b=zU0bMusLNk7jqKy+mfsXVXIULGjif883d4eL/YtIHIwU2TGDkkiwgh/wuRh3w9IP0x
         jcgcaYxa0DdcE6mIiYKD5s9rSlgmb4vVqTQ2/X+06Nge2yCSvcvxzfbWAkh6lRF7MAZt
         uagQxcc6X/8U84AkW61F3RUCSh4+2tds7UM+fmWpoxDmLxEN1TdSnL3KcUevNnn5H3Ds
         PPaPM56GY2mEIGL6T07vRmYcncIhr8vioqClBSGLqF5voVub+WD5lbBTHQZgEEzItmzN
         XwiNhy8my/npi+3YwW2a0xy9PRgy1rrESoB7cs//7jUDNi+/GDIZo01se8z7zG8rZhkE
         vpNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l11si317725edb.116.2019.06.13.11.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 11:56:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1CD73AC31;
	Thu, 13 Jun 2019 18:56:42 +0000 (UTC)
Date: Thu, 13 Jun 2019 20:56:40 +0200
From: Michal Hocko <mhocko@suse.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	yuzhoujian <yuzhoujian@didichuxing.com>
Subject: Re: [PATCH] mm/oom_kill: set oc->constraint in constrained_alloc()
Message-ID: <20190613185640.GA1405@dhcp22.suse.cz>
References: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 13-06-19 21:55:50, Yafang Shao wrote:
> In dump_oom_summary() oc->constraint is used to show
> oom_constraint_text, but it hasn't been set before.
> So the value of it is always the default value 0.
> We should set it in constrained_alloc().

Thanks for catching that.

> Bellow is the output when memcg oom occurs,
> 
> before this patch:
> [  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
> cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0
> 
> after this patch:
> [  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
> cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0
> 

unless I am missing something
Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")

The patch looks correct but I think it is more complicated than it needs
to be. Can we do the following instead?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5a58778c91d4..f719b64741d6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -987,8 +987,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 /*
  * Determines whether the kernel must panic because of the panic_on_oom sysctl.
  */
-static void check_panic_on_oom(struct oom_control *oc,
-			       enum oom_constraint constraint)
+static void check_panic_on_oom(struct oom_control *oc)
 {
 	if (likely(!sysctl_panic_on_oom))
 		return;
@@ -998,7 +997,7 @@ static void check_panic_on_oom(struct oom_control *oc,
 		 * does not panic for cpuset, mempolicy, or memcg allocation
 		 * failures.
 		 */
-		if (constraint != CONSTRAINT_NONE)
+		if (oc->constraint != CONSTRAINT_NONE)
 			return;
 	}
 	/* Do not panic for oom kills triggered by sysrq */
@@ -1035,7 +1034,6 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 bool out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
-	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
@@ -1071,10 +1069,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
 	 */
-	constraint = constrained_alloc(oc);
-	if (constraint != CONSTRAINT_MEMORY_POLICY)
+	oc->constraint = constrained_alloc(oc);
+	if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
 		oc->nodemask = NULL;
-	check_panic_on_oom(oc, constraint);
+	check_panic_on_oom(oc);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
 	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&

I guess the current confusion comes from the fact that we have
constraint both in the oom_control and a local variable so I would
rather remove that. What do you think?

> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/oom_kill.c | 35 +++++++++++++++++++++++++----------
>  1 file changed, 25 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5a58778..075e5cf 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -261,29 +261,37 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
>  	struct zone *zone;
>  	struct zoneref *z;
>  	enum zone_type high_zoneidx = gfp_zone(oc->gfp_mask);
> +	enum oom_constraint constraint;
>  	bool cpuset_limited = false;
>  	int nid;
>  
>  	if (is_memcg_oom(oc)) {
>  		oc->totalpages = mem_cgroup_get_max(oc->memcg) ?: 1;
> -		return CONSTRAINT_MEMCG;
> +		constraint = CONSTRAINT_MEMCG;
> +		goto out;
>  	}
>  
>  	/* Default to all available memory */
>  	oc->totalpages = totalram_pages() + total_swap_pages;
>  
> -	if (!IS_ENABLED(CONFIG_NUMA))
> -		return CONSTRAINT_NONE;
> +	if (!IS_ENABLED(CONFIG_NUMA)) {
> +		constraint = CONSTRAINT_NONE;
> +		goto out;
> +	}
>  
> -	if (!oc->zonelist)
> -		return CONSTRAINT_NONE;
> +	if (!oc->zonelist) {
> +		constraint = CONSTRAINT_NONE;
> +		goto out;
> +	}
>  	/*
>  	 * Reach here only when __GFP_NOFAIL is used. So, we should avoid
>  	 * to kill current.We have to random task kill in this case.
>  	 * Hopefully, CONSTRAINT_THISNODE...but no way to handle it, now.
>  	 */
> -	if (oc->gfp_mask & __GFP_THISNODE)
> -		return CONSTRAINT_NONE;
> +	if (oc->gfp_mask & __GFP_THISNODE) {
> +		constraint = CONSTRAINT_NONE;
> +		goto out;
> +	}
>  
>  	/*
>  	 * This is not a __GFP_THISNODE allocation, so a truncated nodemask in
> @@ -295,7 +303,8 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
>  		oc->totalpages = total_swap_pages;
>  		for_each_node_mask(nid, *oc->nodemask)
>  			oc->totalpages += node_spanned_pages(nid);
> -		return CONSTRAINT_MEMORY_POLICY;
> +		constraint = CONSTRAINT_MEMORY_POLICY;
> +		goto out;
>  	}
>  
>  	/* Check this allocation failure is caused by cpuset's wall function */
> @@ -308,9 +317,15 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
>  		oc->totalpages = total_swap_pages;
>  		for_each_node_mask(nid, cpuset_current_mems_allowed)
>  			oc->totalpages += node_spanned_pages(nid);
> -		return CONSTRAINT_CPUSET;
> +		constraint = CONSTRAINT_CPUSET;
> +		goto out;
>  	}
> -	return CONSTRAINT_NONE;
> +
> +	constraint = CONSTRAINT_NONE;
> +
> +out:
> +	oc->constraint = constraint;
> +	return constraint;
>  }
>  
>  static int oom_evaluate_task(struct task_struct *task, void *arg)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

