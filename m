Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86F956B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:42:35 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id bk3so8458566wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:42:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h70si6996264wme.114.2016.12.14.04.42.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 04:42:32 -0800 (PST)
Date: Wed, 14 Dec 2016 13:42:31 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214124231.GI25573@dhcp22.suse.cz>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161213170628.GC18362@dhcp22.suse.cz>
 <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Wed 14-12-16 20:37:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 13-12-16 21:06:57, Tetsuo Handa wrote:
> > > http://I-love.SAKURA.ne.jp/tmp/serial-20161213.txt.xz is a console log with
> > > this patch applied. Due to hung task warnings disabled, amount of messages
> > > are significantly reduced.
> > > 
> > > Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> > > Since there are some "** XXX printk messages dropped **" messages, I can't
> > > tell whether the OOM killer was able to make forward progress. But guessing
> > >  from the result that there is no corresponding "Killed process" line for
> > > "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> > > I think it is OK to say that the system got stuck because the OOM killer was
> > > not able to make forward progress.
> > 
> > The oom situation certainly didn't get resolved. I would be really
> > curious whether we can rule out the printk out of the picture, though. I
> > am still not sure we can rule out some obscure OOM killer bug at this
> > stage.
> > 
> > What if we lower the loglevel as much as possible to only see KERN_ERR
> > should be sufficient to see few oom killer messages while suppressing
> > most of the other noise. Unfortunatelly, even messages with level >
> > loglevel get stored into the ringbuffer (as I've just learned) so
> > console_unlock() has to crawl through them just to drop them (Meh) but
> > at least it doesn't have to go to the serial console drivers and spend
> > even more time there. An alternative would be to tweak printk to not
> > even store those messaes. Something like the below
> 
> Changing loglevel is not a option for me. Under OOM, syslog cannot work.
> Only messages sent to serial console / netconsole are available for
> understanding something went wrong. And serial consoles may be very slow.
> We need to try to avoid uncontrolled printk().

That is definitely true I just wanted the above for the sake of testing
and rulling out a different problem because currently it is not clear to
me that this is the printk livelock issue. Evidences are quite
convincing but not 100% sure. So...

> > So it would be really great if you could
> > 	1) test with the fixed throttling
> > 	2) loglevel=4 on the kernel command line
> > 	3) try the above with the same loglevel
> > 
> > ideally 1) would be sufficient and that would make the most sense from
> > the warn_alloc point of view. If this is 2 or 3 then we are hitting a
> > more generic problem and I would be quite careful to hack it around.
> 
> Thus, I don't think I can do these.

i think this would be really valuable.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
