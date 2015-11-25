Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC7F06B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:31:57 -0500 (EST)
Received: by wmvv187 with SMTP id v187so259814183wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:31:57 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id pl6si35084030wjb.64.2015.11.25.06.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:31:56 -0800 (PST)
Received: by wmvv187 with SMTP id v187so259813625wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:31:56 -0800 (PST)
Date: Wed, 25 Nov 2015 15:31:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 9/9] mm, oom: print symbolic gfp_flags in oom warning
Message-ID: <20151125143155.GJ27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-10-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-10-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue 24-11-15 13:36:21, Vlastimil Babka wrote:
> It would be useful to translate gfp_flags into string representation when
> printing in case of an OOM, especially as the flags have been undergoing some
> changes recently and the script ./scripts/gfp-translate needs a matching source
> version to be accurate.
> 
> Example output:
> 
> a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)

I like this _very much_
 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

If this can be done with a printk formatter it would be even nicer but
this is good enough for the OOM purpose.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5314b20..542d56c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -386,10 +386,12 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  static void dump_header(struct oom_control *oc, struct task_struct *p,
>  			struct mem_cgroup *memcg)
>  {
> -	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
> -		"oom_score_adj=%hd\n",
> -		current->comm, oc->gfp_mask, oc->order,
> -		current->signal->oom_score_adj);
> +	pr_warning("%s invoked oom-killer: order=%d, oom_score_adj=%hd, "
> +			"gfp_mask=0x%x",
> +		current->comm, oc->order, current->signal->oom_score_adj,
> +		oc->gfp_mask);
> +	dump_gfpflag_names(oc->gfp_mask);
> +
>  	cpuset_print_current_mems_allowed();
>  	dump_stack();
>  	if (memcg)
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
