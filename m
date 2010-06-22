Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED3BB6B01AF
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 00:07:33 -0400 (EDT)
Date: Tue, 22 Jun 2010 12:07:27 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
Message-ID: <20100622040727.GA14340@localhost>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
 <1276856497.27822.1699.camel@twins>
 <20100621134238.GE3828@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621134238.GE3828@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 21, 2010 at 03:42:39PM +0200, Jan Kara wrote:
> On Fri 18-06-10 12:21:37, Peter Zijlstra wrote:
> > On Thu, 2010-06-17 at 20:04 +0200, Jan Kara wrote:
> > > +               if (bdi_stat(bdi, BDI_WRITTEN) >= bdi->wb_written_head)
> > > +                       bdi_wakeup_writers(bdi); 
> > 
> > For the paranoid amongst us you could make wb_written_head s64 and write
> > the above as:
> > 
> >   if (bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)
> > 
> > Which, if you assume both are monotonic and wb_written_head is always
> > within 2^63 of the actual bdi_stat() value, should give the same end
> > result and deal with wrap-around.
> > 
> > For when we manage to create a device that can write 2^64 pages in our
> > uptime :-)
>   OK, the fix is simple enough so I've changed it, although I'm not
> paranoic enough ;) (I actually did the math before writing that test).

a bit more change :)

type:

-       u64 wb_written_head
+       s64 wb_written_head

resetting:

-                       bdi->wb_written_head = ~(u64)0;
+                       bdi->wb_written_head = 0;

setting:

                bdi->wb_written_head = bdi_stat(bdi, BDI_WRITTEN) + wc->written;
+               bdi->wb_written_head |= 1;

testing:

        if (bdi->wb_written_head &&
            bdi_stat(bdi, BDI_WRITTEN) - bdi->wb_written_head > 0)

This avoids calling into bdi_wakeup_writers() pointlessly when no one
is being throttled (which is the normal case).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
