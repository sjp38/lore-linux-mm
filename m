Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C05426B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 05:20:23 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so20323162pfg.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 02:20:23 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id m8si52083576pgc.88.2016.12.14.02.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 02:20:22 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id x23so2018875pgx.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 02:20:22 -0800 (PST)
Date: Wed, 14 Dec 2016 19:20:28 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214102028.GA2462@jagdpanzerIV.localdomain>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214093706.GA16064@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On (12/14/16 10:37), Petr Mladek wrote:
[..]
> > ----------
> > [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> > [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> > [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> > [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > (...snipped...)
> > [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > ----------
> > 
> > Although it is fine to make warn_alloc() less verbose, this is not
> > a problem which can be avoided by simply reducing printk(). Unless
> > we give enough CPU time to the OOM killer and OOM victims, it is
> > trivial to lockup the system.
> 
> You could try to use printk_deferred() in warn_alloc(). It will not
> handle console. It will help to be sure that the blocked printk()
> is the main problem.

I thought about deferred printk, but I'm afraid in the given
conditions this has great chances to badly lockup the system.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
