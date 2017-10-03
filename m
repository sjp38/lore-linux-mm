Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 33F846B0253
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 18:55:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so9174410wmu.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 15:55:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b12si798332edm.95.2017.10.03.15.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Oct 2017 15:55:12 -0700 (PDT)
Date: Tue, 3 Oct 2017 18:55:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: tty crash due to auto-failing vmalloc
Message-ID: <20171003225504.GA966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On some of our machines, we see this warning:

	/* switch the line discipline */
	tty->ldisc = ld;
	tty_set_termios_ldisc(tty, disc);
	retval = tty_ldisc_open(tty, tty->ldisc);
	if (retval) {
->		if (!WARN_ON(disc == N_TTY)) {
			tty_ldisc_put(tty->ldisc);
			tty->ldisc = NULL;
		}
	}

where the stack is

tty_ldisc_reinit
tty_ldisc_hangup
__tty_hangup
do_exit
do_signal
syscall

This is followed by a NULL pointer deref crash in n_tty_set_termios,
presumably when it tries to deref that unallocated tty->disc_data.

The only way n_tty_open() can fail is if the vmalloc in there fails.
struct n_tty_data isn't terribly big, but ever since the following
patch it doesn't even *try* the allocation:

commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
Author: Michal Hocko <mhocko@suse.com>
Date:   Fri Feb 24 14:58:53 2017 -0800

    vmalloc: back off when the current task is killed
    
    __vmalloc_area_node() allocates pages to cover the requested vmalloc
    size.  This can be a lot of memory.  If the current task is killed by
    the OOM killer, and thus has an unlimited access to memory reserves, it
    can consume all the memory theoretically.  Fix this by checking for
    fatal_signal_pending and back off early.
    
    Link: http://lkml.kernel.org/r/20170201092706.9966-4-mhocko@kernel.org
    Signed-off-by: Michal Hocko <mhocko@suse.com>
    Reviewed-by: Christoph Hellwig <hch@lst.de>
    Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
    Cc: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

This talks about the oom killer and memory exhaustion, but most fatal
signals don't happen due to the OOM killer.

I think this patch should be reverted. If somebody is vmallocing crazy
amounts of memory in the exit path we should probably track them down
individually; the patch doesn't reference any real instances of that.
But we cannot start failing allocations that have never failed before.

That said, maybe we want Alan's N_NULL failover in the hangup path too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
