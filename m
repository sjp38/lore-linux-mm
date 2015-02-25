Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3564F6B006C
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 11:02:28 -0500 (EST)
Received: by lbiz11 with SMTP id z11so4802965lbi.8
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 08:02:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dg7si29932430wib.15.2015.02.25.08.02.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 08:02:25 -0800 (PST)
Date: Wed, 25 Feb 2015 17:02:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
Message-ID: <20150225160223.GH26680@dhcp22.suse.cz>
References: <20150221011907.2d26c979.akpm@linux-foundation.org>
 <201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
 <20150223102147.GB24272@dhcp22.suse.cz>
 <201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
 <20150224181408.GD14939@dhcp22.suse.cz>
 <201502252022.AAH51015.OtHLOVFJSMFFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502252022.AAH51015.OtHLOVFJSMFFQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

On Wed 25-02-15 20:22:22, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > This commit hasn't introduced any behavior changes. GFP_NOFAIL
> > allocations fail when OOM killer is disabled since beginning
> > 7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).
> 
> I thought that
> 
> -       out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false);
> -       *did_some_progress = 1;
> +       if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
> +               *did_some_progress = 1;
> 
> in commit c32b3cbe0d067a9c "oom, PM: make OOM detection in the freezer
> path raceless" introduced a code path which fails to set
> *did_some_progress to non 0 value.

But this commit had also the following hunk:
@@ -2317,9 +2315,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 
        *did_some_progress = 0;
 
-       if (oom_killer_disabled)
-               return NULL;
-

so we even wouldn't get down to out_of_memory and returned with
did_some_progress=0 right away. So the patch hasn't changed the logic.

> > "
> > We haven't seen any bug reports since 2009 so I haven't marked the patch
> > for stable. I have no problem to backport it to stable trees though if
> > people think it is a good precaution.
> > "
> 
> Until 3.18, GFP_NOFAIL for GFP_NOFS / GFP_NOIO did not fail with
> oom_killer_disabled == true because of
> 
> ----------
>         if (!did_some_progress) {
>                 if (oom_gfp_allowed(gfp_mask)) {
>                         if (oom_killer_disabled)
>                                 goto nopage;
> 			(...snipped...)
>                         goto restart;
>                 }
>         }
> 	(...snipped...)
> 	goto rebalance;
> ----------
> 
> and that might be the reason you did not see bug reports.
> In 3.19, GFP_NOFAIL for GFP_NOFS / GFP_NOIO started to fail with
> oom_killer_disabled == true because of

OK, that would change the bahavior for __GFP_NOFAIL|~__GFP_FS
allocations. The patch from Johannes which reverts GFP_NOFS failure mode
should go to stable and that should be sufficient IMO.
 
[...]

> So, it is commit 9879de7373fc "mm: page_alloc: embed OOM killing naturally
> into allocation slowpath" than commit c32b3cbe0d067a9c "oom, PM: make OOM
> detection in the freezer path raceless" that introduced behavior changes?

Yes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
