Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CD1868D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:23:07 -0400 (EDT)
Date: Wed, 16 Mar 2011 16:22:52 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
Message-ID: <20110316202252.GF13562@redhat.com>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <1299623475-5512-4-git-send-email-jack@suse.cz>
 <20110316165331.GA15183@redhat.com>
 <20110316191021.GB4456@quack.suse.cz>
 <20110316193144.GE13562@redhat.com>
 <20110316195844.GD4456@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110316195844.GD4456@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>

On Wed, Mar 16, 2011 at 08:58:44PM +0100, Jan Kara wrote:

[..]
> > > > Had a query.
> > > > 
> > > > - What makes sure that flusher thread will not stop writing back till all
> > > >   the waiters on the bdi have been woken up. IIUC, flusher thread will 
> > > >   stop once global background ratio is with-in limit. Is it possible that
> > > >   there are still some waiter on some bdi waiting for more pages to finish
> > > >   writeback and that might not happen for sometime. 
> > >   Yes, this can possibly happen but once distribute_page_completions()
> > > gets called (after a given time), it will notice that we are below limits
> > > and wake all waiters.
> > > Under normal circumstances, we should have a decent
> > > estimate when distribute_page_completions() needs to be called and that
> > > should be long before flusher thread finishes it's work. But in cases when
> > > a bdi has only a small share of global dirty limit, what you describe can
> > > possibly happen.
> > 
> > So if a bdi share is small then it can happen that global background
> > threshold is fine but per bdi threshold is not. That means
> > task_bdi_threshold is also above limit and IIUC, distribute_page_completion()
> > will not wake up the waiter until bdi_task_limit_exceeded() is in control.
>   It will wake them. What you miss is the check right at the beginning of
> distribute_page_completions():
>       dirty_exceeded = check_dirty_limits(bdi, &st);
>       if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
>                /* Wakeup everybody */
> ...
> 
>   When we are globally below (background+limit)/2, dirty_exceeded is set to
> DIRTY_OK or DIRTY_BACKGROUND and thus we just wake all the waiters.

Ok, thanks. Now I see it. 

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
