Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3D36B025E
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 01:44:58 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so7251606wjc.0
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:44:57 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z84si961794wmg.75.2016.11.21.22.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 22:44:55 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id a20so1359836wme.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:44:55 -0800 (PST)
Date: Tue, 22 Nov 2016 07:44:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Don't fail costly __GFP_NOFAIL
 allocations.
Message-ID: <20161122064454.GB4829@dhcp22.suse.cz>
References: <1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20161121060313.GB29816@dhcp22.suse.cz>
 <201611212016.GGG52176.LSOVtOHJFMQFFO@I-love.SAKURA.ne.jp>
 <20161121125431.GA18112@dhcp22.suse.cz>
 <20161122062936.GA4829@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161122062936.GA4829@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, stable@vger.kernel.org

On Tue 22-11-16 07:29:36, Michal Hocko wrote:
> I would even go one step further and do the following because, honestly,
> I never liked GFP_NOFAIL having OOM side effects.
> 
> @@ -3078,32 +3078,31 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto out;
>  
> -	if (!(gfp_mask & __GFP_NOFAIL)) {
> -		/* Coredumps can quickly deplete all memory reserves */
> -		if (current->flags & PF_DUMPCORE)
> -			goto out;
> -		/* The OOM killer will not help higher order allocs */
> -		if (order > PAGE_ALLOC_COSTLY_ORDER)
> -			goto out;
> -		/* The OOM killer does not needlessly kill tasks for lowmem */
> -		if (ac->high_zoneidx < ZONE_NORMAL)
> -			goto out;
> -		if (pm_suspended_storage())
> -			goto out;
> -		/*
> -		 * XXX: GFP_NOFS allocations should rather fail than rely on
> -		 * other request to make a forward progress.
> -		 * We are in an unfortunate situation where out_of_memory cannot
> -		 * do much for this context but let's try it to at least get
> -		 * access to memory reserved if the current task is killed (see
> -		 * out_of_memory). Once filesystems are ready to handle allocation
> -		 * failures more gracefully we should just bail out here.
> -		 */
> +	/* Coredumps can quickly deplete all memory reserves */
> +	if (current->flags & PF_DUMPCORE)
> +		goto out;
> +	/* The OOM killer will not help higher order allocs */
> +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> +		goto out;
> +	/* The OOM killer does not needlessly kill tasks for lowmem */
> +	if (ac->high_zoneidx < ZONE_NORMAL)
> +		goto out;
> +	if (pm_suspended_storage())
> +		goto out;
> +	/*
> +	 * XXX: GFP_NOFS allocations should rather fail than rely on
> +	 * other request to make a forward progress.
> +	 * We are in an unfortunate situation where out_of_memory cannot
> +	 * do much for this context but let's try it to at least get
> +	 * access to memory reserved if the current task is killed (see
> +	 * out_of_memory). Once filesystems are ready to handle allocation
> +	 * failures more gracefully we should just bail out here.
> +	 */
> +
> +	/* The OOM killer may not free memory on a specific node */
> +	if (gfp_mask & __GFP_THISNODE)
> +		goto out;
>  
> -		/* The OOM killer may not free memory on a specific node */
> -		if (gfp_mask & __GFP_THISNODE)
> -			goto out;
> -	}
>  	/* Exhausted what can be done so it's blamo time */
>  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;

Forgot to include this part of course

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec9f11d4f094..12a6fce85f61 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * make sure exclude 0 mask - all other users should have at least
 	 * ___GFP_DIRECT_RECLAIM to get here.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
 		return true;
 
 	/*

Anyway I will think about this some more and prepapre patches with the
full changelog for further discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
