Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8A036B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 20:06:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so144620503pfb.6
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 17:06:45 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 88si45725045pla.48.2016.12.12.17.06.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 17:06:44 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 3so2623654pgd.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 17:06:44 -0800 (PST)
Date: Tue, 13 Dec 2016 10:06:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161213010651.GB415@jagdpanzerIV.localdomain>
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
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (12/12/16 12:49), Petr Mladek wrote:
[..]
> > OK, I see. This is not a new problem though and people are trying to
> > solve it in the printk proper. CCed some people, I do not have links
> > to those threads handy. And if this is really the problem here then we
> > definitely shouldn't put hacks into the page allocator path to handle
> > it because there might be other sources of the printk flood might be
> > arbitrary.
> 
> Yup, this is exactly the type of the problem that we want to solve
> by the async printk.

yes, I think async printk will help here.

> > > The introduction of uncontrolled
> > > 
> > >   warn_alloc(gfp_mask, "page allocation stalls for %ums, order:%u", ...);
> 
> I am just curious that there would be so many messages.
> If I get it correctly, this warning is printed
> once every 10 second. Or am I wrong?
> 
> Well, you might want to consider using
> 
> 		stall_timeout *= 2;
> 
> instead of adding the constant 10 * HZ.
> 
> Of course, a better would be some global throttling of
> this message.

yeah. rate limiting is still a good thing to have.

somewhat unrelated, but somehow related. just some thoughts.

with async printk, in some cases, I suspect (and I haven't thought
of it long enought), messages rate limiting can have an even bigger,
to some extent, necessity than with the current printk. the thing
is that in current scheme CPU that does printk-s can *sometimes*
go to console_unlock() and spins there printing the messages that
it appended to the logbuf. which naturally throttles that CPU and
it can't execte more printk-s for awhile. with async printk that
CPU is detached from console_unlock() printing loop, so the CPU is
free to append new messages to the logbuf as fast as it wants to.
it should not cause any lockups or something, but we can lost some
messages.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
