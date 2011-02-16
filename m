Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0C58D8D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 10:53:24 -0500 (EST)
Date: Wed, 16 Feb 2011 16:53:17 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [2.6.32 ubuntu] I/O hang at start_this_handle
Message-ID: <20110216155317.GD5592@quack.suse.cz>
References: <201102080526.p185Q0mL034909@www262.sakura.ne.jp>
 <20110215151633.GG17313@quack.suse.cz>
 <201102160652.BDI60469.JOVFSFOHLQOFtM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201102160652.BDI60469.JOVFSFOHLQOFtM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: jack@suse.cz, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed 16-02-11 06:52:55, Tetsuo Handa wrote:
> Jan Kara wrote:
> >   Ext3 looks innocent here. That is a standard call path for open(..,
> > O_TRUNC). But apparently something broke in SLUB allocator. Adding proper
> > list to CC...
> 
> Thanks.
> 
> Both fs/jbd/transaction.c and fs/jbd2/transaction.c provide start_this_handle()
> and I don't know which one was called.
> 
> But
> 
> 	if (!journal->j_running_transaction) {
> 		new_transaction = kzalloc(sizeof(*new_transaction),
> 					  GFP_NOFS|__GFP_NOFAIL);
> 		if (!new_transaction) {
> 			ret = -ENOMEM;
> 			goto out;
> 		}
> 	}
> 
> does kzalloc(GFP_NOFS|__GFP_NOFAIL) causes /proc/$PID/status to show
> 
>   State:  D (disk sleep)
  It could. State D does not mean "disk sleep" but "uninterruptible sleep".
Lots of sleeps in kernel are in D state - for example waiting for all mutex
locks, waiting for IO, etc. But looking at the trace again, you're probably
right that we are actually waiting somewhere in start_this_handle() (in
fs/jbd/transaction.c) and __slab_alloc() is just some relict on stack. You
can verify this by looking at disassembly of start_this_handle() in your
kernel and finding out where offset 0x22d is in the function...

But in this case - does the process (sh) eventually resume or is it stuck
forever?

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
