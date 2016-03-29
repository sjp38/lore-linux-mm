Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id CD9446B025E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:22:18 -0400 (EDT)
Received: by mail-wm0-f45.google.com with SMTP id 127so60724019wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:22:18 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id p134si16851130wmb.103.2016.03.29.07.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 07:22:17 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id p65so141505677wmp.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:22:17 -0700 (PDT)
Date: Tue, 29 Mar 2016 16:22:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Message-ID: <20160329142216.GE4466@dhcp22.suse.cz>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
 <201603292245.AAC12437.JFLMQVtSOHFFOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603292245.AAC12437.JFLMQVtSOHFFOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 29-03-16 22:45:40, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __alloc_pages_may_oom is the central place to decide when the
> > out_of_memory should be invoked. This is a good approach for most checks
> > there because they are page allocator specific and the allocation fails
> > right after.
> > 
> > The notable exception is GFP_NOFS context which is faking
> > did_some_progress and keep the page allocator looping even though there
> > couldn't have been any progress from the OOM killer. This patch doesn't
> > change this behavior because we are not ready to allow those allocation
> > requests to fail yet. Instead __GFP_FS check is moved down to
> > out_of_memory and prevent from OOM victim selection there. There are
> > two reasons for that
> > 	- OOM notifiers might release some memory even from this context
> > 	  as none of the registered notifier seems to be FS related
> > 	- this might help a dying thread to get an access to memory
> >           reserves and move on which will make the behavior more
> >           consistent with the case when the task gets killed from a
> >           different context.
> 
> Allowing !__GFP_FS allocations to get TIF_MEMDIE by calling the shortcuts in
> out_of_memory() would be fine. But I don't like the direction you want to go.
> 
> I don't like failing !__GFP_FS allocations without selecting OOM victim
> ( http://lkml.kernel.org/r/201603252054.ADH30264.OJQFFLMOHFSOVt@I-love.SAKURA.ne.jp ).

I didn't get to read and digest that email yet but from a quick glance
it doesn't seem to be directly related to this patch. Even if we decide
that __GFP_FS vs. OOM killer logic is flawed for some reason then would
build on top as granting the access to memory reserves is not against
it.

> Also, I suggested removing all shortcuts by setting TIF_MEMDIE from oom_kill_process()
> ( http://lkml.kernel.org/r/1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

I personally do not like this much. I believe we have already tried to
explain why we have (some of) those shortcuts. They might be too
optimistic and there is a room for improvements for sure but I am not
convinced we can get rid of them that easily.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
