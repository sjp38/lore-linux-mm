Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 834516B04DE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:57:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s70so134108252pfs.5
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 21:57:02 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id l74si9276504pfb.386.2017.07.10.21.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 21:57:01 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id u62so60230992pgb.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 21:57:01 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:57:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170711045710.GC4586@jagdpanzerIV.localdomain>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
 <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
 <20170710125935.GL23069@pathway.suse.cz>
 <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
 <20170711023150.GB4586@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711023150.GB4586@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On (07/11/17 11:31), Sergey Senozhatsky wrote:
[..]
> (replying to both Petr and Daniel)
> 
> interesting direction, gents.
> 
> and this is what I thought about over the weekend; it's very sketchy and
> I didn't spend too much time on it. (I'm on a sick leave now, sorry).
> 
> it's quite close to what you guys have mentioned above.
> 
> a) keep console_sem only to protect console drivers list modification
> b) add a semaphore/mutex to struct console
> c) move global console_seq/etc to struct console
> e) use a single kthread for printing, but do console_unlock() multi passes,
>    printing unseen logbuf messages on per-console basis
> 
> 
> so console_lock()/console_unlock() will simply protect console drivers
> list from concurrent manipulation; it will not prevent us from printing.
> now, there are places where console_lock() serves a special purpose - it
> makes sure that no new lines are printed to the console while we scroll
> it/flip it/etc. IOW while we do "some things" to a particular console.
> the problem here, is that this also blocks printing to all of the registered
> console drivers, not just the one we are touching now. therefore, what I was
> thinking about is to disable/enable that particular console in all of the
> places where we really want to stop printing to this console for a bit.
> 
> IOW, something like
> 
> 
> 
> 	console_lock()
> 	:	down(console_sem);
> 
> 	console_disable(con)
> 	:	lock(con->lock);
> 	:	con->flags &= ~CON_ENABLED;
> 	:	unlock(con->lock)
> 
> 	console_unlock()
> 	:	for_each_console(con)
> 	:		while (con->console_seq != log_next_seq) {
> 	:			msg_print_text();
> 	:			con->console_seq++;
> 	:		
> 	:			call_console_drivers()
> 	:			:	if (con->flags & CON_ENABLED)
> 	:			:		con->write()
> 	:		}
> 	:	up(console_sem);
> 
> 
> 	// do "some things" to this console. it's disabled, so no
> 	// ->write() callback would be called in the meantime
> 
> 	console_lock()
> 	:	down(console_sem);
> 
> 	console_enable(con)
> 	:	lock(con->lock);
> 	:	con->flags |= CON_ENABLED;
> 	:	unlock(con->lock)
> 
> 
> 	// so now we enabled that console again. it's ->console_seq is
> 	// probably behind the rest of consoles, so console_unlock()
> 	// will ->write() all the unseen message to this console.
> 
> 	console_unlock()
> 	:	for_each_console(con)
> 	:		while (con->console_seq != log_next_seq) {
> 	:			msg_print_text();
> 	:			con->console_seq++;
> 	:		
> 	:			call_console_drivers()
> 	:			:	if (con->flags & CON_ENABLED)
> 	:			:		con->write()
> 	:		}
> 	:	up(console_sem);
> 

ok, obviously stupid.

I meant to hold con->lock between console_disable() and console_enable().
so no other CPU can unregister it, etc. printk->console_unlock(), thus,
can either have a racy con->flags check (no con->lock taken) or try
something like down_trylock(&con->lock): if it fails, continue.

but need to look more.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
