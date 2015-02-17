Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 758DF6B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 09:59:07 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id h11so33918363wiw.3
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:59:07 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id ca16si29420348wib.105.2015.02.17.06.59.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 06:59:05 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id em10so32525470wid.0
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:59:05 -0800 (PST)
Date: Tue, 17 Feb 2015 15:59:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217145902.GE32017@dhcp22.suse.cz>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue 17-02-15 21:23:26, Tetsuo Handa wrote:
[...]
> > Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?

Because they cannot perform any IO/FS transactions and that would lead
to a premature OOM conditions way too easily. OOM killer is a _last
resort_ reclaim opportunity not something that would happen just because
you happen to be not able to flush dirty pages. 

> I can see "possible memory allocation deadlock in %s (mode:0x%x)" warnings
> at kmem_alloc() in fs/xfs/kmem.c .

> I think commit 9879de7373fcfb46 "mm:
> page_alloc: embed OOM killing naturally into allocation slowpath" introduced
> a regression and below one is the fix.
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>                 /* The OOM killer does not needlessly kill tasks for lowmem */
>                 if (high_zoneidx < ZONE_NORMAL)
>                         goto out;
> -               /* The OOM killer does not compensate for light reclaim */
> -               if (!(gfp_mask & __GFP_FS))
> -                       goto out;
>                 /*
>                  * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>                  * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

So NAK to this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
