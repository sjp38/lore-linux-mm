Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 837856B01DE
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 09:33:30 -0400 (EDT)
Date: Tue, 22 Jun 2010 21:33:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622133323.GA10335@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <1276856497.27822.1699.camel@twins>
 <20100621134238.GE3828@quack.suse.cz>
 <20100622040727.GA14340@localhost>
 <20100622132735.GC3338@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100622132735.GC3338@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hch@infradead.org" <hch@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 09:27:35PM +0800, Jan Kara wrote:
> On Tue 22-06-10 12:07:27, Wu Fengguang wrote:
> > On Mon, Jun 21, 2010 at 03:42:39PM +0200, Jan Kara wrote:
> > > On Fri 18-06-10 12:21:37, Peter Zijlstra wrote:
> > > > On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> > > > > +               if (bdi_stat(bdi, BDI_WRITTEN) >= bdi->wb_written_head)
> > > > > +                       bdi_wakeup_writers(bdi); 
> > > > 
> > > > For the paranoid amongst us you could make wb_written_head s64 and write
> > > > the above as:
> > > > 
> > > >   if (bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)
> > > > 
> > > > Which, if you assume both are monotonic and wb_written_head is always
> > > > within 2^63 of the actual bdi_stat() value, should give the same end
> > > > result and deal with wrap-around.
> > > > 
> > > > For when we manage to create a device that can write 2^64 pages in our
> > > > uptime :-)
> > >   OK, the fix is simple enough so I've changed it, although I'm not
> > > paranoic enough ;) (I actually did the math before writing that test).
> > 
> > a bit more change :)
> > 
> > type:
> > 
> > -       u64 wb_written_head
> > +       s64 wb_written_head
> > 
> > resetting:
> > 
> > -                       bdi->wb_written_head = ~(u64)0;
> > +                       bdi->wb_written_head = 0;
> > 
> > setting:
> > 
> >                 bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
> > +               bdi->wb_written_head |= 1;
> > 
> > testing:
> > 
> >         if (bdi->wb_written_head &&
> >             bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)
> > 
> > This avoids calling into bdi_wakeup_writers() pointlessly when no one
> > is being throttled (which is the normal case).
>   Actually, I've already changed wb_written_head to s64. I kept setting
> wb_written_head to s64 maximum. That also avoids calling into
> bdi_wakeup_writers() unnecessarily...

Ah OK, I forgot bdi_stat() calls percpu_counter_read_positive() which
is always in range [0, s64 max].

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
