Date: Sun, 07 Nov 2004 20:19:32 +0900 (JST)
Message-Id: <20041107.201932.104031093.taka@valinux.co.jp>
Subject: Re: manual page migration, revisited...
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <418DADDC.1030601@sgi.com>
References: <1099695742.4507.114.camel@desktop.cunninghams>
	<20041106174857.GA23420@logos.cnet>
	<418DADDC.1030601@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@sgi.com
Cc: marcelo.tosatti@cyclades.com, ncunningham@linuxmail.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Ray,

> Marcelo Tosatti wrote:
> 
> >>You may not even need any kernel patches to accomplish this. Bernard
> >>Blackham wrote some code called cryopid: http://cryopid.berlios.de/. I
> >>haven't tried it myself, but it sounds like it might be at least part of
> >>what you're after.
> > 
> > 
> > Hi Ray, Nigel,
> > 
> > And the swsusp code itself, isnt it what its doing? Stopping all processes, 
> > saving their memory to disk, and resuming later on.

looks interesting.

> > You should just need an API to stop a specific process? 
> > 
> 
> I think that sending the process a SIGSTOP is probably good enough to stop
> it for our purposes.  But in addition to that, the reason we stopped the
> process is so we can start up another process on that node.  Now, we can
> wait for memory pressure to grow to the point that kswap will force out
> the stopped processes's pages, but, why should the VM have to go to the
> effort to figure that out?  Why not tell them VM somehow, that we don't
> want these pages in memory, and to please swap them out to make space for
> the new program that is running?

I agree stopping the target processes is enough.
I thing you want to introduce whole process swapout mechanism
which linux haven't implemented.

I feel it isn't difficult to implement it. The following steps
may work.
  1. stop the target processes with SIGSTOP signal.
  2. choose the pages, which depend on the processes.
  3. pass them to shrink_list() with proper parameters.
     shrink_list() may have to be called several times to handle
     active pages and wait for the completion of the writeback I/Os
     which the previous shrink_list() has started.

If you just want to make the pages migrated to another node,
the migration code may help you. This is called process migration
which NUMA guys may be also interested in.
  1. select the target node where the processes are going to move,
     and move them to the target runqueue.
  2. choose the pages, which depend on the processes.
  3. start memory-migration against the pages.

> Of course, one can argue that we don't know for sure that the new program
> will use enough space to force the other process out, but we worry that in
> that case, the new program could still end up with non-local memory allocation
> and that is an anathema to the HPC world where we require the good performance
> that local storage allocation provides.  We want the new process that is
> run on the node to get as good performance as it would have gotten if it had
> started on an idle node.
> -- 

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
