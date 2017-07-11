Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82ECA44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 22:31:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t187so9342225oie.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:31:42 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id a7si9751430oih.255.2017.07.10.19.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 19:31:41 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id k14so58889908pgr.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:31:41 -0700 (PDT)
Date: Tue, 11 Jul 2017 11:31:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170711023150.GB4586@jagdpanzerIV.localdomain>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
 <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
 <20170710125935.GL23069@pathway.suse.cz>
 <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

Hello,

On (07/10/17 20:07), Daniel Vetter wrote:
[..]
> > Would it be acceptable to remove "console=tty0" parameter and push
> > the messages only to the serial console?
> >
> > Also there is the patchset from Peter Zijlstra that allows to
> > use early console all the time, see
> > https://lkml.kernel.org/r/20161018170830.405990950@infradead.org
> >
> >
> > The current code flushes each line to all enabled consoles one
> > by one. If there is a deadlock in one console, everything
> > gets blocked.
> >
> > We are trying to make printk() more robust. But it is much more
> > complicated than we anticipated. Many changes open another can
> > of worms. It seems to be a job for years.
> >
> >
> >> Hmm... should we consider addressing console_sem problem before
> >> introducing printing kernel thread and offloading to that kernel thread?
> >
> > As Sergey said, the console rework seems to be much bigger task
> > than introducing the kthread.
> >
> > Also if we would want to handle each console separately (as a
> > fallback) it would be helpful to have separate kthread for each
> > enabled console or for the less reliable consoles at least.
> 
> Since the console-loggin-in-kthread comes up routinely, and equally
> often people say "but I dont want to make my serial console delayed":
> Should we make kthread-based printk a per-console opt-in? fbcon and
> other horror shows with deep nesting of entire subsystems and their
> locking hierarchy would do that. Truly simple console drivers like
> serial or maybe logging to some firmware/platform service for recovery
> after rebooting would not.
> 
> Of course we'd also need one kthread per console, and we'd need to
> have at least some per-console locking (plus an overall console lock
> on top for both registering/unregistering consoles and all the legacy
> users like fbdev that need much more work to untangle). We could even
> restrict the per-console locking (i.e. those which can go ahead while
> someone else is holding the main or other console_locks) just for
> those console drivers which do not use a kthread, to cut down the
> audit burden to something manageable.
> 
> Just my 2 cents, thrown in from the sideline.

(replying to both Petr and Daniel)

interesting direction, gents.

and this is what I thought about over the weekend; it's very sketchy and
I didn't spend too much time on it. (I'm on a sick leave now, sorry).

it's quite close to what you guys have mentioned above.

a) keep console_sem only to protect console drivers list modification
b) add a semaphore/mutex to struct console
c) move global console_seq/etc to struct console
e) use a single kthread for printing, but do console_unlock() multi passes,
   printing unseen logbuf messages on per-console basis


so console_lock()/console_unlock() will simply protect console drivers
list from concurrent manipulation; it will not prevent us from printing.
now, there are places where console_lock() serves a special purpose - it
makes sure that no new lines are printed to the console while we scroll
it/flip it/etc. IOW while we do "some things" to a particular console.
the problem here, is that this also blocks printing to all of the registered
console drivers, not just the one we are touching now. therefore, what I was
thinking about is to disable/enable that particular console in all of the
places where we really want to stop printing to this console for a bit.

IOW, something like



	console_lock()
	:	down(console_sem);

	console_disable(con)
	:	lock(con->lock);
	:	con->flags &= ~CON_ENABLED;
	:	unlock(con->lock)

	console_unlock()
	:	for_each_console(con)
	:		while (con->console_seq != log_next_seq) {
	:			msg_print_text();
	:			con->console_seq++;
	:		
	:			call_console_drivers()
	:			:	if (con->flags & CON_ENABLED)
	:			:		con->write()
	:		}
	:	up(console_sem);


	// do "some things" to this console. it's disabled, so no
	// ->write() callback would be called in the meantime

	console_lock()
	:	down(console_sem);

	console_enable(con)
	:	lock(con->lock);
	:	con->flags |= CON_ENABLED;
	:	unlock(con->lock)


	// so now we enabled that console again. it's ->console_seq is
	// probably behind the rest of consoles, so console_unlock()
	// will ->write() all the unseen message to this console.

	console_unlock()
	:	for_each_console(con)
	:		while (con->console_seq != log_next_seq) {
	:			msg_print_text();
	:			con->console_seq++;
	:		
	:			call_console_drivers()
	:			:	if (con->flags & CON_ENABLED)
	:			:		con->write()
	:		}
	:	up(console_sem);


so this does change the behavior. may be even a lot. consoles now will not
look the same, in some cases: some consoles can be ahead, some can be behind
(as long as CON_ENABLED bit is cleared for the "do some things" part).

and this requires a number of changes in fb/tty/etc code. not just
shuffling of console_lock()/console_unlock() calls, but also
console_disable()/console_enable() calls... and we need to pass struct
console to console_disable()/console_enable()...


another thing is, ideally, only !CON_ENABLED consoles will now see
"dropped messages". if some particular console is !CON_ENABLED for long
time, then well, just like it happens now, logbuf may run out of space
and we will drop potentially unseen messages. but with this change, we
will drop messages only on !CON_ENABLED consoles. if there are CON_ENABLED
console(-s), we will print logbuf messages to those consoles. so may be
we have more chances saving the kernel logs now.

just a sketch...

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
