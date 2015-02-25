Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id A781F6B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 17:22:57 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id a3so6081079oib.3
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 14:22:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i4si1028035oep.17.2015.02.25.14.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 14:22:55 -0800 (PST)
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150223102147.GB24272@dhcp22.suse.cz>
	<201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
	<20150224181408.GD14939@dhcp22.suse.cz>
	<201502252022.AAH51015.OtHLOVFJSMFFQO@I-love.SAKURA.ne.jp>
	<20150225160223.GH26680@dhcp22.suse.cz>
In-Reply-To: <20150225160223.GH26680@dhcp22.suse.cz>
Message-Id: <201502260648.IBC35479.QMVHOtFOJSFFLO@I-love.SAKURA.ne.jp>
Date: Thu, 26 Feb 2015 06:48:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

Michal Hocko wrote:
> On Wed 25-02-15 20:22:22, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > This commit hasn't introduced any behavior changes. GFP_NOFAIL
> > > allocations fail when OOM killer is disabled since beginning
> > > 7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).
> > 
> > I thought that
> > 
> > -       out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false);
> > -       *did_some_progress = 1;
> > +       if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
> > +               *did_some_progress = 1;
> > 
> > in commit c32b3cbe0d067a9c "oom, PM: make OOM detection in the freezer
> > path raceless" introduced a code path which fails to set
> > *did_some_progress to non 0 value.
> 
> But this commit had also the following hunk:
> @@ -2317,9 +2315,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  
>         *did_some_progress = 0;
>  
> -       if (oom_killer_disabled)
> -               return NULL;
> -
> 
> so we even wouldn't get down to out_of_memory and returned with
> did_some_progress=0 right away. So the patch hasn't changed the logic.

OK.

> OK, that would change the bahavior for __GFP_NOFAIL|~__GFP_FS
> allocations. The patch from Johannes which reverts GFP_NOFS failure mode
> should go to stable and that should be sufficient IMO.
>  

mm-page_alloc-revert-inadvertent-__gfp_fs-retry-behavior-change.patch
fixes only ~__GFP_NOFAIL|~__GFP_FS case. I think we need David's version
http://marc.info/?l=linux-mm&m=142489687015873&w=2 for 3.19-stable .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
