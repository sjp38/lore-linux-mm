Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90AB96B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 05:16:55 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so8994516wme.5
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 02:16:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qp9si1320035wjc.142.2016.12.15.02.16.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 02:16:54 -0800 (PST)
Date: Thu, 15 Dec 2016 11:16:52 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161215101652.GL16064@pathway.suse.cz>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161213170628.GC18362@dhcp22.suse.cz>
 <20161215011142.GA485@jagdpanzerIV.localdomain>
 <20161215063550.GA29290@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161215063550.GA29290@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On Thu 2016-12-15 07:35:52, Michal Hocko wrote:
> On Thu 15-12-16 10:11:42, Sergey Senozhatsky wrote:
> > On (12/13/16 18:06), Michal Hocko wrote:
> > [..]
> > > What if we lower the loglevel as much as possible to only see KERN_ERR
> > > should be sufficient to see few oom killer messages while suppressing
> > > most of the other noise. Unfortunatelly, even messages with level >
> > > loglevel get stored into the ringbuffer (as I've just learned) so
> > > console_unlock() has to crawl through them just to drop them (Meh) but
> > > at least it doesn't have to go to the serial console drivers and spend
> > > even more time there. An alternative would be to tweak printk to not
> > > even store those messaes. Something like the below
> > > 
> > > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > > index f7a55e9ff2f7..197f2b9fb703 100644
> > > --- a/kernel/printk/printk.c
> > > +++ b/kernel/printk/printk.c
> > > @@ -1865,6 +1865,15 @@ asmlinkage int vprintk_emit(int facility, int level,
> > >  				lflags |= LOG_CONT;
> > >  			}
> > >  
> > > +			if (suppress_message_printing(kern_level)) {
> > 
> > aren't we supposed to check level here:
> > 				suppress_message_printing(level)?
> > 
> > kern_level is '0' away from actual level:
> > 
> > 	kern_level = printk_get_level(text)
> > 	switch (kern_level)
> > 	case '0' ... '7':
> > 		level = kern_level - '0';
> 
> Yes you are right. The patch would be broken for KERN_CONT so I think it
> doesn't make much sense to pursue it for testing.

It should help to do the check later when "level" variable has
the final value:

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index b3c454b733da..97f2737c3380 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1774,6 +1774,14 @@ asmlinkage int vprintk_emit(int facility, int level,
 	if (level == LOGLEVEL_DEFAULT)
 		level = default_message_loglevel;
 
+	if (suppress_message_printing(level)) {
+		logbuf_cpu = UINT_MAX;
+		raw_spin_unlock(&logbuf_lock);
+		lockdep_on();
+		local_irq_restore(flags);
+		return 0;
+	}
+
 	if (dict)
 		lflags |= LOG_PREFIX|LOG_NEWLINE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
