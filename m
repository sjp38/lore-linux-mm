Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED7C36B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 08:00:49 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xy5so24676224wjc.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 05:00:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v186si3296881wme.70.2016.12.12.05.00.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 05:00:48 -0800 (PST)
Date: Mon, 12 Dec 2016 14:00:47 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161212130046.GB3185@dhcp22.suse.cz>
References: <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
 <20161208132714.GA26530@dhcp22.suse.cz>
 <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
 <20161209144624.GB4334@dhcp22.suse.cz>
 <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <20161212114903.GM3506@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212114903.GM3506@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 12-12-16 12:49:03, Petr Mladek wrote:
> On Mon 2016-12-12 10:07:03, Michal Hocko wrote:
> > On Sat 10-12-16 20:24:57, Tetsuo Handa wrote:
[...]
> > > The introduction of uncontrolled
> > > 
> > >   warn_alloc(gfp_mask, "page allocation stalls for %ums, order:%u", ...);
> 
> I am just curious that there would be so many messages.
> If I get it correctly, this warning is printed
> once every 10 second. Or am I wrong?

Yes it is once per 10s per allocation context. Tetsuo's test case is
generating hundreds of such allocation paths which are hitting the
warn_alloc path. So they can meet there and generate a lot of output.
Now we have __ratelimit here which should help but most probably needs
some better tunning.

I am also considering to use a per warn_alloc lock which would also help
to make the output nicer (not interleaving for parallel callers).

> Well, you might want to consider using
> 
> 		stall_timeout *= 2;
> 
> instead of adding the constant 10 * HZ.

This wouldn't help in the above situation.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
