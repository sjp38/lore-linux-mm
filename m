Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com>
	 <200706011221.33062.ak@suse.de> <1180718106.5278.28.camel@localhost>
	 <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 15:38:33 -0400
Message-Id: <1180726713.5278.80.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 11:43 -0700, Christoph Lameter wrote:
> On Fri, 1 Jun 2007, Lee Schermerhorn wrote:
> 
> > Like Gleb, I find the different behaviors for different memory regions
> > to be unnatural.  Not because of the fraction of applications or
> > deployments that might use them, but because [speaking for customers] I
> > expect and want to be able to control placement of any object mapped
> > into an application's address space, subject to permissions and
> > privileges.
> 
> Same here and I wish we had a clean memory region based implementation.
> But that is just what your patches do *not* provide. Instead they are file 
> based. They should be memory region based.
> 
> Would you please come up with such a solution?

Christoph:

I don't understand what you mean by "memory region based".

Linux does not have bona fide "memory objects" that sit between a task's
address space and the backing store--be it swap or regular files--like
some systems I've worked with.  Rather, anonymous regions are described
by the vma_struct, and pages backing those regions must be referenced by
one or more ptes or a swap cache entry, or both.  For a disk back file
mapped into a task address space, the vma points directly to the inode
+address_space structures via the file structure.  Shmem regions attach
to a task address space much like regular files--via a pseudo-fs inode
+address_space.  I don't know the rationale, but I suspect that Linux
dispenses with the extra memory object layer to conserve memory for
smaller systems.  And that's a good thing, IMO.

So, for a shared memory mapped file, the inode+address_space--i.e., the
in-memory incarnation of the file--is as close to a "memory region" as
we have.  In contains the mapping between [file/address] offset and
memory page.  It's the only object representing the file and its
in-memory pages that gets shared between multiple task address spaces.
That seems, to me, to be the natural place to hang the shared policy.
Indeed, this is where we attach shared policy to shmem/tmpfs/hugetlbfs
pseudo-files.

Even if we had a layer between the vma's and the files/inodes, I don't
see what that would buy us.  We'd still want to maintain coherency
between files accessed via file descriptor function calls and files
mapped via mmap(SHARED).  That's one of the purposes of a shared page
cache.  [I've seen unix variants where these weren't coherent.  Now
THAT's unnatural ;-)!]  So, yes any policy applied to the memory mapped
file affects the location of pages accessed via file descriptor access.
That's a good thing for the application that use shared mapped files.
The load/store access by the application that maps the file, and goes to
the trouble of specifying memory policy, takes precedence.  Load/store
is the "fast path".  File descriptor access system calls are the slow
path.  

You're usually gung-ho about locality on a NUMA platform, avoiding off
node access or page allocations, respecting the fast path, ...  Why the
resistance here?


> 
> > Then why does Christoph keep insisting that "page cache pages" must
> > always follow task policy, when shmem, tmpfs and anonymous pages don't
> > have to?
> 
> No I just said that the page cache handling is consistently following task 
> policy.

Well, not for anon, shmem, tmpfs, ... page cache pages.  All of those
are page cache based, according to Andi, and they certainly aren't
constrained to "consistently follow task policy".

Of course, I'm just being facetious [and, no doubt, annoying] to make a
point.  We're using the same words, sometimes referring to the same
concepts, but in slightly different context and "talking past each
other".  I'm trying real hard to believe that this is what's happening
in this entire exchange.  That's the most benign reason I can come up
with...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
