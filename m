Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705310021380.6969@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <1180544104.5850.70.camel@localhost>
	 <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
	 <20070531061836.GL4715@minantech.com>
	 <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com>
	 <20070531064753.GA31143@minantech.com>
	 <Pine.LNX.4.64.0705302352590.6824@schroedinger.engr.sgi.com>
	 <20070531071110.GB31143@minantech.com>
	 <Pine.LNX.4.64.0705310021380.6969@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 13:07:18 -0400
Message-Id: <1180631238.5091.57.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, Gleb Natapov <glebn@voltaire.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 00:24 -0700, Christoph Lameter wrote:
> On Thu, 31 May 2007, Gleb Natapov wrote:
> 
> > > 1. A shared range has multiple tasks that can fault pages in.
> > >    The policy of which task should control how the page is allocated?
> > >    Is it the last one that set the policy?
> 
> > How is it done for shmget? For my particular case I would prefer to get an error
> > from numa_setlocal_memory() if process tries to set policy on the area
> > of the file that already has policy set. This may happen only as a
> > result of a bug in my app.
> 
> Hmmm.... Thats an idea. Lee: Do we have some way of returning an error?
> We then need to have a function that clears memory policy. Maybe the
> default policy is the clear?

For shmem, mbind() of a range of the object [that's what
numa_setlocal_memory() does] replaces any existing policy in that range.
This is what I would expect--the last one applied takes effect--just
like .  Multiple tasks attaching to a shmem, or mmap()ing the same file
shared, would, I hope, be cooperating tasks and know what they are
doing.  Typically--i.e., in the applications I'm familiar with, only one
task that sets up the shmem or file mapping for the multi-task
application would set the policy.

However, I agree that if I'm ever successful in getting policy attached
to shared file mappings, we'll need a way to delete the policy.  I'm
thinking of something like "MPOL_DELETE" that completely deletes the
policy--whether it be on a range of virtual addresses via mbind() or the
task policy, via set_mempolicy().  Of course, MPOL_DELETE would work for
shmem segments as well.

> 
> > > 2. Pagecache pages can be read and written by buffered I/O and
> > >    via mmap. Should there be different allocation semantics
> > >    depending on the way you got the page? Obviously no policy
> > >    for a memory range can be applied to a page allocated via
> > >    buffered I/O. Later it may be mapped via mmap but then
> > >    we never use policies if the page is already in memory.
> 
> > If page is already in the pagecache use it. Or return an error if strict
> > policy is in use. Or something else :) In my case I make sure that files
> > is accessed only through mmap interface.

This is the model that I've been trying to support--tasks which have, as
a portion of their address space, a shared mapping of an application
specific file that is only ever accessed via mmap().

> 
> On an mmap we cannot really return an error. If your program has just run 
> then pages may linger in memory. If you run it on another node then the 
> earlier used pages may be used.

It's true that a page of such a file [private to the application, only
accessed by mmap()] may be in the page cache in the wrong location,
either because you run later on another node, as Christoph says, or
because you've just done a backup or restored from one.  However, in
this case, if your application is the only one that mmap's the file, and
you only apply policy from the "application initialization task", then
the that task will be the only one mapping the file.  In this case, you
can use Christoph's excellent MPOL_MF_MOVE facility to ensure that the
pages follow your new policy.  If other tasks have the page mapped,
you'll need to use MPOL_MF_MOVE_ALL, which requires special privilege
[CAP_SYS_NICE].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
