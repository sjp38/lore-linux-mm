Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705311130010.11008@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <1180544104.5850.70.camel@localhost>
	 <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
	 <1180636096.5091.125.camel@localhost>
	 <Pine.LNX.4.64.0705311130010.11008@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 15:29:04 -0400
Message-Id: <1180639745.5091.186.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 11:35 -0700, Christoph Lameter wrote:
> On Thu, 31 May 2007, Lee Schermerhorn wrote:
> 
> > > It seems that you are creating some artificial problems here.
> > 
> > Christoph:  Let me assume you, I'm not persisting in this exchange
> > because I'm enjoying it.  Quite the opposite, actually.  However, like
> > you, my employer asks me to address our customers' requirements.  I'm
> > trying to understand and play within the rules of the community.  I
> > attempted this documentation patch to address what I saw as missing
> > documentation and to provide context for further discussion of my patch
> > set.  
> 
> Could you explain to us what kind of user scenario you are addressing? We 
> have repeatedly asked you for that information. I am happy to hear that 
> there is an actual customer requirement.

And I've tried to explain without "naming names".  Let me try it this
way:  An multi-task application that mmap()s a large file--think O(1TB)
or larger--shared.   You can think of it as an in-memory data base, but
the size of the file could exceed physical memory. Various tasks of the
application will access various portions of the memory area in different
ways/with different frequencies, ... [sort of like Gleb described].  The
memory region is large enough and cache locality poor enough that
"locality matters".

Why not just use shmem and read the file in at startup?  In those cases
where it would fit, it takes quite a while to read a file of this size
in, and processing can't start until it's all in.  Perhaps one could
modify the application to carefully sequence the load so other tasks
could get started before it's all in.  And, it only works if the access
pattern is known a priori.  And, if the file is larger than memory,
you'll need swap space to back it.

You want persistence across runs of the application--e.g., so that you
could suspend it and continue later.  You could just write the entire
shmem out at the end, but again, that takes a long time.  The
application could keep track of which regions of memory have been
modified and write them out incrementally, but with a mapped file, the
kernel does this automatically [I won't say "for free" ;-)] with an
occasional msync() or if reclaim becomes necessary. 

Granted, these last 2 paragraphs describe how a number of large
enterprise data bases work.  So, it's not impossible.  It IS a lot of
work if you don't need the type of guarantees that those systems
provide.

Why not just use task policy to place the pages?  Task policy affects
all task allocations, including stack, heap, ...  Better to let those
default to local.  Well, why not place the pages, lock them down and
then change the task policy back to default/local?  File might not fit;
even if it did, might not want to commit that much memory, ...  And,
yes, it seems unnatural to have to jump through these hoops--at least
for customers bringing applications from envrionments where they didn't
have to.  [I know, I know.  Functional parity with other systems... Not
a valid reason... Yada yada.  ;-)]

> 
> > My point was that the description of MPOL_DEFAULT made reference to the
> > zonelists built at boot time, to distinguish them from the custom
> > zonelists built for an MPOL_BIND.  Since the zonelist reorder patch
> > hasn't made it out of Andrew's tree yet, I didn't want to refer to it
> > this round of the doc.  If it makes it into the tree, I had planned say
> > something like:  "at boot time or on request".  I should probably add
> > "or on memory hotplug".
> 
> Hmmm... The zonelists for MPOL_BIND are never rebuilt by Kame-san's 
> patches. That  is a concern.

Yes.  And as we noted earlier, even the initial ones don't consider
distance.  The latter should be relatively easy to fix, as we have code
that does it for the node zonelists.  Would require some generalization.

Rebuilding policy zonelists would require finding them all somehow.
Either an expensive system [cpuset] wide scan or a system-wide/per
cpuset list of [MPOL-BIND] policies.  A per cpuset list might reduce the
scope of the rebuild, but you'd have to scan tasks and reparent their
policies when move them between cpusets.  Not pretty either way.

> 
> > But, after I see what gets accepted into the man pages that I've agreed
> > to update, I'll consider dropping this section altogether.  Maybe the
> > entire document.
> 
> I'd be very thankful if you could upgrade the manpages. Andi has some 
> patches from me against numactl pending that include manpage 
> updatess. I can forward that too you.
> 
> > > page cache pages are subject to a tasks memory policy regardless of how we 
> > > get to the page cache page. I think that is pretty consistent.
> > 
> > Oh, it's consistent, alright.  Just not pretty [;-)] when it's not what
> > the application wants.
> 
> I sure hope that we can at some point figure out what your applications is 
> doing. Its been a hard road to that information so far.
> 

I thought I'd explained before.  I guess just too abstractly.  Maybe the
description above is a too abstract as well.   However, Gleb's
application has similar requirements--he wants to control the location
of pages in a shared, mmap'ed file using explicit policies.  He's even
willing to issue the identical policy calls from each task--something I
don't think he should need to do--to accomplish it.  But, it still won't
work for him...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
