Subject: Re: pressuring dirty pages (2.3.99-pre6)
References: <852568CC.004F0BB1.00@raylex-gh01.eo.ray.com> <20000425173012.B1406@redhat.com>
From: ebiederman@uswest.net (Eric W. Biederman)
Date: 25 Apr 2000 14:14:30 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of "Tue, 25 Apr 2000 17:30:12 +0100"
Message-ID: <m1snwadmcp.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org, riel@nl.linux.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Tue, Apr 25, 2000 at 09:27:57AM -0500, Mark_H_Johnson.RTS@raytheon.com wrote:
> 
> 
> > It would be great to have a dynamic max limit. However I can see a lot of
> > complexity in doing so. May I make a few suggestions.

Agreed all I suggest for now was implement a max limit.
The dynamic was just food for thought.

> >  - take a few moments to model the system operation under load. If the model
> > says RSS limits would help, by all means lets do it. If not, fix what we have.
> 
> > If RSS limits are what we need, then
> >  - implement the RSS limit using the current mechanism [e.g., ulimit]
> > - use a simple page removal algorithm to start with [e.g.,"oldest page first"
> 
> > or "address space order"]. The only caution I might add on this is to check
> that
> 
> > the page you are removing isn't the one w/ the instruction you are executing
> 
> We already have simple page removal algorithms.  
> 
> The reason for the dynamic RSS limit isn't to improve the throughput 
> under load.  It is to protect innocent processes from the effects of a
> large memory hog in the system.  It's easy enough to see that any pageout
> algorithm which treats all pages fairly will have trouble if you have a
> memory hog paging rapidly through all of its pages --- the hog process's
> pages will be treated the same as any other process's pages, which means
> that since the hog process is thrashing, it forces other tasks to do
> likewise.
> 
> Note that RSS upper bounds are not the only way to achieve this.  In a
> thrashing situation, giving processes a lower limit --- an RSS guarantee
> --- will also help, by allowing processes which don't need that much
> memory to continue to work without any paging pressure at all.

Right.  A RSS guarantee sounds like it would make for easier tuning.
But a hard RSS max has the advantage of hitting a memory space hog
early, before it has a chance to get all of memory dirty, and simply
penalizes the hog.  

Also under heave load a RSS garantee and a RSS hard limit are the
same.  Though the angle of a RSS garantee does open new ideas.
The biggest being if you can meet all of the RSS guarantees do
you start actually swapping processing and not paging, or do you just
go about readjusting everyones RSS guarantee lower...

Maybe for the dynamic case we should just call it ideal_rss...

If I'm lucky I'll have some time this weekend to play with it.
But no guarantees.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
