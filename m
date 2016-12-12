Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB6756B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:56:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so14814775wmu.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 07:56:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qe14si44967597wjb.66.2016.12.12.07.55.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 07:55:59 -0800 (PST)
Date: Mon, 12 Dec 2016 16:55:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161212155557.GD3185@dhcp22.suse.cz>
References: <20161209144624.GB4334@dhcp22.suse.cz>
 <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <201612122359.BDJ39539.HtVOQOJFFOLFSM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612122359.BDJ39539.HtVOQOJFFOLFSM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Mon 12-12-16 23:59:55, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 12-12-16 21:12:06, Tetsuo Handa wrote:
> > > > I would rather not mix the two. Even if both use show_mem then there is
> > > > no reason to abuse the oom_lock.
> > > > 
> > > > Maybe I've missed that but you haven't responded to the question whether
> > > > the warn_lock actually resolves the problem you are seeing.
> > > 
> > > I haven't tried warn_lock, but is warn_lock in warn_alloc() better than
> > > serializing oom_lock in __alloc_pages_may_oom() ? I think we don't need to
> > > waste CPU cycles before the OOM killer sends SIGKILL.
> > 
> > Yes, I find a separate lock better because there is no real reason to
> > abuse an unrelated lock.
> 
> Using separate lock for warn_alloc() is fine for me. I can still consider
> serialization of oom_lock independent with warn_alloc().

Could you try the ratelimit update as well? Maybe it will be sufficient
on its own.

> But
> 
> > > Maybe more, but no need to enumerate in this thread.
> > > How many of these precautions can be achieved by tuning warn_alloc() ?
> > > printk() tries to solve unbounded delay problem by using (I guess) a
> > > dedicated kernel thread. I don't think we can achieve these precautions
> > > without a centralized state tracking which can sleep and synchronize as
> > > needed.
> > > 
> > > Quite few people are responding to discussions regarding almost
> > > OOM situation. I beg for your joining to discussions.
> > 
> > I have already stated my position. I do not think that the code this
> > patch introduces is really justified for the advantages it provides over
> > a simple warn_alloc approach. Additional debugging information might be
> > nice but not necessary in 99% cases. If there are definciences in
> > warn_alloc (which I agree there are if there are thousands of contexts
> > hitting the path) then let's try to address them.
> 
> I'm not happy with keeping kmallocwd out-of-tree.

I completely fail why you are still bringing this up. I will repeat it
for the last time and won't reply to any further note about kmallocwd
here or anywhere else where it is not directly discussed. If you think
your code is valuable document that in the patch description and post
your patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
