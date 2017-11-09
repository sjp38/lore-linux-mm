Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDE14440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:27:37 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id n74so1657188ota.18
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:27:37 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0161.hostedemail.com. [216.40.44.161])
        by mx.google.com with ESMTPS id e132si1558446itb.1.2017.11.09.08.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 08:27:36 -0800 (PST)
Message-ID: <1510244853.15768.64.camel@perches.com>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
From: Joe Perches <joe@perches.com>
Date: Thu, 09 Nov 2017 08:27:33 -0800
In-Reply-To: <20171109100531.3cn2hcqnuj7mjaju@dhcp22.suse.cz>
References: 
	<b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
	 <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
	 <1510068865.1000.19.camel@perches.com>
	 <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
	 <1510070607.1000.23.camel@perches.com>
	 <20171109100531.3cn2hcqnuj7mjaju@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2017-11-09 at 11:05 +0100, Michal Hocko wrote:
[]
> Subject: [PATCH] mm: simplify nodemask printing
> 
> alloc_warn and dump_header have to explicitly handle NULL nodemask which
> forces both paths to use pr_cont. We can do better. printk already
> handles NULL pointers properly so all what we need is to teach
> nodemask_pr_args to handle NULL nodemask carefully. This allows
> simplification of both alloc_warn and dump_header and get rid of pr_cont
> altogether.
[]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
[]
> @@ -426,14 +426,10 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  
>  static void dump_header(struct oom_control *oc, struct task_struct *p)
>  {
> -	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=",
> -		current->comm, oc->gfp_mask, &oc->gfp_mask);
> -	if (oc->nodemask)
> -		pr_cont("%*pbl", nodemask_pr_args(oc->nodemask));
> -	else
> -		pr_cont("(null)");
> -	pr_cont(",  order=%d, oom_score_adj=%hd\n",
> -		oc->order, current->signal->oom_score_adj);
> +	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
> +		current->comm, oc->gfp_mask, &oc->gfp_mask,
> +		nodemask_pr_args(oc->nodemask), oc->order,
> +			current->signal->oom_score_adj);

trivia:

You could align the arguments to the open parenthesis here

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
[]
> @@ -3281,20 +3281,14 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
>  		return;
>  
> -	pr_warn("%s: ", current->comm);
> -
>  	va_start(args, fmt);
>  	vaf.fmt = fmt;
>  	vaf.va = &args;
> -	pr_cont("%pV", &vaf);
> +	pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
> +			current->comm, &vaf, gfp_mask, &gfp_mask,
> +			nodemask_pr_args(nodemask));

and here

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
