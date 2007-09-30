Date: Sun, 30 Sep 2007 14:07:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070930120701.GC7697@wotan.suse.de>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org> <20070928193017.GC11717@kernel.dk> <alpine.LFD.0.999.0709281247490.3579@woody.linux-foundation.org> <20070929131043.GC14159@wotan.suse.de> <20070930064646.GF11717@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070930064646.GF11717@kernel.dk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 30, 2007 at 08:46:46AM +0200, Jens Axboe wrote:
> On Sat, Sep 29 2007, Nick Piggin wrote:
> > On Fri, Sep 28, 2007 at 01:02:50PM -0700, Linus Torvalds wrote:
> > > 
> > > 
> > > On Fri, 28 Sep 2007, Jens Axboe wrote:
> > > > 
> > > > Hmm, part of me doesn't like this patch, since we now end up beating on
> > > > mmap_sem for each part of the vec. It's fine for a stable patch, but how
> > > > about
> > > > 
> > > > - prefaulting the iovec
> > > > - using __get_user()
> > > > - only dropping/regrabbing the lock if we have to fault
> > > 
> > > "__get_user()" doesn't help any. But we should do the same thing we do for 
> > > generic_file_write(), or whatever - probe it while in an atomic region.
> > > 
> > > So something like the appended might work. Untested.
> > 
> > I got an idea for getting rid of mmap_sem from here completely. Which
> > is why I was looking at these callers in the first place.
> > 
> > It would be really convenient and help me play with the idea if mmap_sem
> > is wrapped closely around get_user_pages where possible...
> 
> Well, move it back there in your first patch? Not a big deal, surely :-)
> 
> > If you're really worried about mmap_sem batching here, can you just
> > avoid this complexity and do all the get_user()s up-front, before taking
> > mmap_sem at all? You only have to save PIPE_BUFFERS number of
> > them.
> 
> Sure, that is easily doable at the cost of some stack. I have other
> patches that grow PIPE_BUFFERS dynamically in the pipeline, so I'd
> prefer not to since that'll then turn into a dynamic allocation.

You already have much more PIPE_BUFFERS stuff on the stack. If it
gets much bigger, you should dynamically allocate all this anyway, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
