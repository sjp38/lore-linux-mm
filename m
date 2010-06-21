Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A0ECC6B01DE
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:10:51 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:10:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100621141027.GG3828@quack.suse.cz>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <1276856496.27822.1698.camel@twins>
 <20100621140236.GF3828@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621140236.GF3828@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Mon 21-06-10 16:02:37, Jan Kara wrote:
> On Fri 18-06-10 12:21:36, Peter Zijlstra wrote:
> > On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> > > +/* Wait until write_chunk is written or we get below dirty limits */
> > > +void bdi_wait_written(struct backing_dev_info *bdi, long write_chunk)
> > > +{
> > > +       struct bdi_written_count wc = {
> > > +                                       .list = LIST_HEAD_INIT(wc.list),
> > > +                                       .written = write_chunk,
> > > +                               };
> > > +       DECLARE_WAITQUEUE(wait, current);
> > > +       int pause = 1;
> > > +
> > > +       bdi_add_writer(bdi, &wc, &wait);
> > > +       for (;;) {
> > > +               if (signal_pending_state(TASK_KILLABLE, current))
> > > +                       break;
> > > +
> > > +               /*
> > > +                * Make the task just killable so that tasks cannot circumvent
> > > +                * throttling by sending themselves non-fatal signals...
> > > +                */
> > > +               __set_current_state(TASK_KILLABLE);
> > > +               io_schedule_timeout(pause);
> > > +
> > > +               /*
> > > +                * The following check is save without wb_written_wait.lock
> > > +                * because once bdi_remove_writer removes us from the list
> > > +                * noone will touch us and it's impossible for list_empty check
> > > +                * to trigger as false positive. The barrier is there to avoid
> > > +                * missing the wakeup when we are removed from the list.
> > > +                */
> > > +               smp_rmb();
> > > +               if (list_empty(&wc.list))
> > > +                       break;
> > > +
> > > +               if (!dirty_limits_exceeded(bdi))
> > > +                       break;
> > > +
> > > +               /*
> > > +                * Increase the delay for each loop, up to our previous
> > > +                * default of taking a 100ms nap.
> > > +                */
> > > +               pause <<= 1;
> > > +               if (pause > HZ / 10)
> > > +                       pause = HZ / 10;
> > > +       }
> > > +
> > > +       spin_lock_irq(&bdi->wb_written_wait.lock);
> > > +       __remove_wait_queue(&bdi->wb_written_wait, &wait);
> > > +       if (!list_empty(&wc.list))
> > > +               bdi_remove_writer(bdi, &wc);
> > > +       spin_unlock_irq(&bdi->wb_written_wait.lock);
> > > +} 
> > 
> > OK, so the whole pause thing is simply because we don't get a wakeup
> > when we drop below the limit, right?
>   Yes. I will write a comment about it before the loop. I was also thinking
> about sending a wakeup when we get below limits but then all threads would
> start thundering the device at the same time and likely cause a congestion
> again. This way we might get a smoother start. But I'll have to measure
> whether we aren't too unfair with this approach...
  I just got an idea - if the sleeping is too unfair (as threads at the end
of the FIFO are likely to have 'pause' smaller and thus could find out
earlier that the system is below dirty limits), we could share 'pause'
among all threads waiting for that BDI. That way threads would wake up
in a FIFO order...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
