Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0DD06B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:18:54 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so13354760wjc.6
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 10:18:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hm2si55566245wjb.167.2016.12.14.10.18.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 10:18:53 -0800 (PST)
Date: Wed, 14 Dec 2016 19:18:50 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214181850.GC16763@dhcp22.suse.cz>
References: <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161213170628.GC18362@dhcp22.suse.cz>
 <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
 <20161214124231.GI25573@dhcp22.suse.cz>
 <201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Thu 15-12-16 01:36:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 14-12-16 20:37:07, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
[...]
> > > > So it would be really great if you could
> > > > 	1) test with the fixed throttling
> > > > 	2) loglevel=4 on the kernel command line
> > > > 	3) try the above with the same loglevel
> > > > 
> > > > ideally 1) would be sufficient and that would make the most sense from
> > > > the warn_alloc point of view. If this is 2 or 3 then we are hitting a
> > > > more generic problem and I would be quite careful to hack it around.
> > > 
> > > Thus, I don't think I can do these.
> > 
> > i think this would be really valuable.
> 
> OK. I tried 1) and 2). I didn't try 3) because printk() did not work as expected.
> 
> Regarding 1), it did not help. I can still see "** XXX printk messages dropped **"
> ( http://I-love.SAKURA.ne.jp/tmp/serial-20161215-1.txt.xz ).

So we still manage to swamp the logbuffer. The question is whether you
can still see the lockup. This is not obvious from the output to me.

> Regarding 2), I can't tell whether it helped
> ( http://I-love.SAKURA.ne.jp/tmp/serial-20161215-2.txt.xz ).
> I can no longer see "** XXX printk messages dropped **", but sometimes they stalled.
> In most cases, "Out of memory: " and "Killed process" lines are printed within 0.1
> second. But sometimes it took a few seconds. Less often it took longer than a minute.
> There was one big stall which lasted for minutes. I changed loglevel to 7 and checked
> memory information. Seems that watermark was low enough to call out_of_memory().

Isn't that what your test case essentially does though? Keep the system
in OOM continually? Some stalls are to be expected I guess, the main
question is whether there is a point with no progress at all.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
