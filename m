Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 08F0F6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 10:00:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so252959213pgx.6
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 07:00:04 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h63si43649119pge.110.2016.12.12.07.00.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 07:00:02 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161209144624.GB4334@dhcp22.suse.cz>
	<201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
	<20161212090702.GD18163@dhcp22.suse.cz>
	<201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
	<20161212125535.GA3185@dhcp22.suse.cz>
In-Reply-To: <20161212125535.GA3185@dhcp22.suse.cz>
Message-Id: <201612122359.BDJ39539.HtVOQOJFFOLFSM@I-love.SAKURA.ne.jp>
Date: Mon, 12 Dec 2016 23:59:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> On Mon 12-12-16 21:12:06, Tetsuo Handa wrote:
> > > I would rather not mix the two. Even if both use show_mem then there is
> > > no reason to abuse the oom_lock.
> > > 
> > > Maybe I've missed that but you haven't responded to the question whether
> > > the warn_lock actually resolves the problem you are seeing.
> > 
> > I haven't tried warn_lock, but is warn_lock in warn_alloc() better than
> > serializing oom_lock in __alloc_pages_may_oom() ? I think we don't need to
> > waste CPU cycles before the OOM killer sends SIGKILL.
> 
> Yes, I find a separate lock better because there is no real reason to
> abuse an unrelated lock.

Using separate lock for warn_alloc() is fine for me. I can still consider
serialization of oom_lock independent with warn_alloc(). But

> > Maybe more, but no need to enumerate in this thread.
> > How many of these precautions can be achieved by tuning warn_alloc() ?
> > printk() tries to solve unbounded delay problem by using (I guess) a
> > dedicated kernel thread. I don't think we can achieve these precautions
> > without a centralized state tracking which can sleep and synchronize as
> > needed.
> > 
> > Quite few people are responding to discussions regarding almost
> > OOM situation. I beg for your joining to discussions.
> 
> I have already stated my position. I do not think that the code this
> patch introduces is really justified for the advantages it provides over
> a simple warn_alloc approach. Additional debugging information might be
> nice but not necessary in 99% cases. If there are definciences in
> warn_alloc (which I agree there are if there are thousands of contexts
> hitting the path) then let's try to address them.

I'm not happy with keeping kmallocwd out-of-tree.

http://I-love.SAKURA.ne.jp/tmp/serial-20161212.txt.xz is a console log
which I've just captured using stock 4.9 kernel (as a preparation step for
trying http://lkml.kernel.org/r/20161212131910.GC3185@dhcp22.suse.cz ) using
http://lkml.kernel.org/r/201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp .
Only warn_alloc() by GFP_NOIO allocation request was reported (uptime > 148).
Guessing from

  INFO: task kswapd0:60 blocked for more than 60 seconds.

message, I hit kswapd v.s. shrink_inactive_list() trap. But there are
no other hints which would have been reported if kmallocwd is available.
This is one of unsolvable definciences in warn_alloc() (or any synchronous
watchdog).

It is administrators who decide whether to utilize debugging capability
with state tracking. Let's give administrators a choice and a chance.

Although you think most users won't need kmallcwd, there is no objection
for asynchronous watchdog, isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
