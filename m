Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C6368440846
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:51:03 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b207so28029811lfg.7
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:51:03 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id o4si5827707lfo.219.2017.07.11.00.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 00:51:00 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f28so13190148lfi.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 00:51:00 -0700 (PDT)
Date: Tue, 11 Jul 2017 09:50:54 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170711075054.vjmclcao4t5lzp3r@phenom.ffwll.local>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
 <201707082230.ECB51545.JtFFFVHOOSMLOQ@I-love.SAKURA.ne.jp>
 <20170710125935.GL23069@pathway.suse.cz>
 <CAKMK7uGQ9NgS3rTieqqop-2o7sWUv8QuG_DNkJn42iPyBkEeiw@mail.gmail.com>
 <20170711023150.GB4586@jagdpanzerIV.localdomain>
 <20170711045710.GC4586@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170711045710.GC4586@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, Petr Mladek <pmladek@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Michal Hocko <mhocko@kernel.org>, Pavel Machek <pavel@ucw.cz>, Steven Rostedt <rostedt@goodmis.org>, Andreas Mohr <andi@lisas.de>, Jan Kara <jack@suse.cz>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 01:57:10PM +0900, Sergey Senozhatsky wrote:
> On (07/11/17 11:31), Sergey Senozhatsky wrote:
> [..]
> > (replying to both Petr and Daniel)
> > 
> > interesting direction, gents.
> > 
> > and this is what I thought about over the weekend; it's very sketchy and
> > I didn't spend too much time on it. (I'm on a sick leave now, sorry).
> > 
> > it's quite close to what you guys have mentioned above.
> > 
> > a) keep console_sem only to protect console drivers list modification
> > b) add a semaphore/mutex to struct console
> > c) move global console_seq/etc to struct console
> > e) use a single kthread for printing, but do console_unlock() multi passes,
> >    printing unseen logbuf messages on per-console basis
> > 
> > 
> > so console_lock()/console_unlock() will simply protect console drivers
> > list from concurrent manipulation; it will not prevent us from printing.
> > now, there are places where console_lock() serves a special purpose - it
> > makes sure that no new lines are printed to the console while we scroll
> > it/flip it/etc. IOW while we do "some things" to a particular console.
> > the problem here, is that this also blocks printing to all of the registered
> > console drivers, not just the one we are touching now. therefore, what I was
> > thinking about is to disable/enable that particular console in all of the
> > places where we really want to stop printing to this console for a bit.
> > 
> > IOW, something like
> > 
> > 
> > 
> > 	console_lock()
> > 	:	down(console_sem);
> > 
> > 	console_disable(con)
> > 	:	lock(con->lock);
> > 	:	con->flags &= ~CON_ENABLED;
> > 	:	unlock(con->lock)
> > 
> > 	console_unlock()
> > 	:	for_each_console(con)
> > 	:		while (con->console_seq != log_next_seq) {
> > 	:			msg_print_text();
> > 	:			con->console_seq++;
> > 	:		
> > 	:			call_console_drivers()
> > 	:			:	if (con->flags & CON_ENABLED)
> > 	:			:		con->write()
> > 	:		}
> > 	:	up(console_sem);
> > 
> > 
> > 	// do "some things" to this console. it's disabled, so no
> > 	// ->write() callback would be called in the meantime
> > 
> > 	console_lock()
> > 	:	down(console_sem);
> > 
> > 	console_enable(con)
> > 	:	lock(con->lock);
> > 	:	con->flags |= CON_ENABLED;
> > 	:	unlock(con->lock)
> > 
> > 
> > 	// so now we enabled that console again. it's ->console_seq is
> > 	// probably behind the rest of consoles, so console_unlock()
> > 	// will ->write() all the unseen message to this console.
> > 
> > 	console_unlock()
> > 	:	for_each_console(con)
> > 	:		while (con->console_seq != log_next_seq) {
> > 	:			msg_print_text();
> > 	:			con->console_seq++;
> > 	:		
> > 	:			call_console_drivers()
> > 	:			:	if (con->flags & CON_ENABLED)
> > 	:			:		con->write()
> > 	:		}
> > 	:	up(console_sem);
> > 
> 
> ok, obviously stupid.
> 
> I meant to hold con->lock between console_disable() and console_enable().
> so no other CPU can unregister it, etc. printk->console_unlock(), thus,
> can either have a racy con->flags check (no con->lock taken) or try
> something like down_trylock(&con->lock): if it fails, continue.

I don't think you need the CON_ENABLED flag, just holding the per-console
lock should be enough (I hope). Or what exactly is the idea behind this.
I'm also not sure whether dropping the main console_lock is a good idea.

What I had in mind for the printk look is to not even hold the main
console_lock, but only grab the individual console_locks (plus the printk
buffer spinlock ofc), so

	for_each_console(con)
		if (!mutex_trylock(con->mutex))
			continue;

		/* pseudo-code, whatever we need to check to make sure
		 * this console is real and fully registered. */
		if (!(con->flags & CON_ENABLED))
			continue;

		if (con_requires_kthread(con)) {
			wake_up(con->printk_wq);

			/* this is for consoles that grab massive amounts
			 * of locks, like fbcon. We could repurpose klogd
			 * for this perhaps. */

			continue;
		}

		/* do the actual printing business */
	}

Very rough pseudo-code draft without looking at the details. The things
we'd need to do to get there:

- Audit _all_ the places that use console_lock to protect global data
  structures. Excessively sprinkle lockdep_assert_held(&console_lock_map);
  over them to make sure we don't break stuff. We'll probably want to
  stuff that lockdep assert into for_each_console (and have a
  special/open-coded one for the printk loop).

- Add con->mutex. Make sure that lock properly serializes against
  the last step in register_console and the first step in
  unregister_console. CON_ENABLED seems like the critical flag.

- Wrap all call to console callbacks in a mutex_lock(con->mutex) critical
  sections.

- Sprinkle lockdep_assert_held(con->mutex) into all the console callbacks
  of a few common console backends (fbcon + serial should be enough), to
  make sure that part is solid.

- Do the above changes in the printk loop. It also needs to be extracted
  from console_unlock so that we can replace the

	if (console_try_lock())
		console_unlock();

  pattern for pushing out the printk buffer with maybe a new
  printk_flush() function, which does _not_ try to acquire console_lock.

- console_unlock() still needs to flush out the printk buffers, to make
  sure we haven't lost any lines. Or we'll rely on klogd to ensure
  everything gets printed, when the trylock path doesn't work out.

I think this would give us a reasonable locking design, allows us to not
stall on slow consoles when trying to dump emergency output to serial, and
it would decouple printk entirely from the huge console_lock mess. And as
long as we carefully audit for global stuff (everywhere, not just in
printk.c) in the first step I think it should be a safe transition.

Cheers, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
