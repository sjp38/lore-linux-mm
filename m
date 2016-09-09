Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 570506B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 10:00:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so37232605lfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:00:24 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 8si3090229wmo.24.2016.09.09.07.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 07:00:22 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id b187so2908425wme.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 07:00:22 -0700 (PDT)
Date: Fri, 9 Sep 2016 16:00:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/4] mm, oom: do not rely on TIF_MEMDIE for memory reserves
 access
Message-ID: <20160909140020.GN4844@dhcp22.suse.cz>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <1472723464-22866-2-git-send-email-mhocko@kernel.org>
 <201609041049.GIF51522.FOHLOJVSFOFMtQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609041049.GIF51522.FOHLOJVSFOFMtQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Sun 04-09-16 10:49:42, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > @@ -3309,6 +3318,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> >  	return alloc_flags;
> >  }
> >  
> > +static bool oom_reserves_allowed(struct task_struct *tsk)
> > +{
> > +	if (!tsk_is_oom_victim(tsk))
> > +		return false;
> > +
> > +	/*
> > +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> > +	 * depletion and shouldn't give access to memory reserves passed the
> > +	 * exit_mm
> > +	 */
> > +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> > +		return false;
> > +
> > +	return true;
> > +}
> > +
> 
> Are you aware that you are trying to make !MMU kernel's allocations not only
> after returning exit_mm() but also from __mmput() from mmput() from exit_mm()
> fail without allowing access to memory reserves?

Do we allocate from that path in !mmu and would that be more broken than
with the current code which clears TIF_MEMDIE after mmput even when
__mmput is not called (aka somebody is holding a reference to mm - e.g.
a proc file)?

> The comment says only after returning exit_mm(), but this change is
> not.

I can see that the comment is not ideal. Any suggestion how to make it
better?
 
> > @@ -3558,8 +3593,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		goto nopage;
> >  	}
> >  
> > -	/* Avoid allocations with no watermarks from looping endlessly */
> > -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > +	/* Avoid allocations for oom victims from looping endlessly */
> > +	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL))
> >  		goto nopage;
> 
> This change increases possibility of giving up without trying ALLOC_OOM
> (more allocation failure messages), for currently only one thread which
> remotely got TIF_MEMDIE when it was between gfp_to_alloc_flags() and
> test_thread_flag(TIF_MEMDIE) will give up without trying ALLOC_NO_WATERMARKS
> while all threads which remotely got current->signal->oom_mm when they were
> between gfp_to_alloc_flags() and test_thread_flag(TIF_MEMDIE) will give up
> without trying ALLOC_OOM. I think we should make sure that ALLOC_OOM is
> tried (by using a variable which remembers whether
> get_page_from_freelist(ALLOC_OOM) was tried).

Technically speaking you are right but I am not really sure that this
matters all that much. This code as always been racy. If we ever
consider the race harmfull we can reorganize the allo slow path in a way
to guarantee at least one allocation attempt with ALLOC_OOM I am just
not sure it is necessary right now. If this ever shows up as a problem
we would see a flood of allocation failures followed by the OOM report
so it would be quite easy to notice.

> We are currently allowing TIF_MEMDIE threads try ALLOC_NO_WATERMARKS for
> once and give up without invoking the OOM killer. This change makes
> current->signal->oom_mm threads try ALLOC_OOM for once and give up without
> invoking the OOM killer. This means that allocations for cleanly cleaning
> up by oom victims might fail prematurely, but we don't want to scatter
> around __GFP_NOFAIL. Since there are reasonable chances of the parallel
> memory freeing, we don't need to give up without invoking the OOM killer
> again. I think that
> 
> -	/* Avoid allocations with no watermarks from looping endlessly */
> -	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> +#ifndef CONFIG_MMU
> +	/* Avoid allocations for oom victims from looping endlessly */
> +	if (tsk_is_oom_victim(current) && !(gfp_mask & __GFP_NOFAIL))
> +		goto nopage;
> +#endif
> 
> is possible.

I would prefer to not spread out MMU ifdefs all over the place.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
