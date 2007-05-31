Date: Thu, 31 May 2007 10:11:10 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531071110.GB31143@minantech.com>
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com> <1180544104.5850.70.camel@localhost> <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com> <20070531061836.GL4715@minantech.com> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com> <20070531064753.GA31143@minantech.com> <Pine.LNX.4.64.0705302352590.6824@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705302352590.6824@schroedinger.engr.sgi.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2007 at 11:56:34PM -0700, Christoph Lameter wrote:
> On Thu, 31 May 2007, Gleb Natapov wrote:
> 
> > > The faulted page will use the memory policy of the task that faulted it 
> > > in. If that process has numa_set_localalloc() set then the page will be 
> > > located as closely as possible to the allocating thread.
> > 
> > Thanks. But I have to say this feels very unnatural. So to have
> > desirable effect I have to create shared memory with shmget?
> 
> Right. From a user perspective: How would you solve the problem that
> 
> 1. A shared range has multiple tasks that can fault pages in.
>    The policy of which task should control how the page is allocated?
>    Is it the last one that set the policy?
How is it done for shmget? For my particular case I would prefer to get an error
from numa_setlocal_memory() if process tries to set policy on the area
of the file that already has policy set. This may happen only as a
result of a bug in my app.

> 
> 2. Pagecache pages can be read and written by buffered I/O and
>    via mmap. Should there be different allocation semantics
>    depending on the way you got the page? Obviously no policy
>    for a memory range can be applied to a page allocated via
>    buffered I/O. Later it may be mapped via mmap but then
>    we never use policies if the page is already in memory.
If page is already in the pagecache use it. Or return an error if strict
policy is in use. Or something else :) In my case I make sure that files
is accessed only through mmap interface.

I agree that from kernel point of view the current behaviour seems more
logical/easy to implement. After all memory policy is a property of a
memory space and not a file. But as a user I expect to be able to use mmap to
create shared space between processes and set memory policy on this
space.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
