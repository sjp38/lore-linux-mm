Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
	 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
	 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 May 2007 10:55:51 -0400
Message-Id: <1180104952.5730.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 14:17 -0700, Christoph Lameter wrote:
> On Thu, 24 May 2007, Lee Schermerhorn wrote:
> 
> > Same use cases for using mbind() at all.  I want to specify the
> > placement of memory backing any of my address space.  A shared mapping
> > of a regular file is, IMO, morally equivalent to a shared memory region,
> > with the added semantic that is it automatically initialized from the
> > file contents, and any changes persist after the file is closed.  [One
> > related semantic that Linux is missing is to initialize the shared
> > mapping from the file, but not writeback any changes--e.g.,
> > MAP_NOWRITEBACK.  Some "enterprise unix" support this, presumably at
> > ISV/customer request.]
> 
> I think Andi was looking for an actual problem that is solved by this 
> patchset. Any user feedback that triggered this solution?

The question usually comes up in the context of migrating customers'
applications or benchmarks from our legacy unix numa APIs to Linux.  I
don't know of the exact applications that install explicit policy on
shared mmap()ed files, but on, say, Tru64 Unix it just works.  As a
result, customers and ISVs have used it.  We try to make it easy for
customers to migrate to Linux--providing support, documentation and
such.  Having a one-for-one API replacement makes this easier.  In this
context, it's a glaring hole in Linux today, and I've had to explain to
colleagues that it's a "feature"--at which point they ask me when did I
transfer to marketing ;-).  

It's easy to fix.  The shared policy support is already there.  We just
need to generalize it for regular files.  In the process,
*page_cache_alloc() obeys "file policy", which will allow additional
features such as you mentioned:  global page cache policy as the default
"file policy".

Now, I understand the concern about any increase in size, even if it's
only ~2K, but I think this is mostly of concern to 32-bit systems, where
I expect the increase will be less than 2k.   I also understand that
there are still a few 32-bit NUMA systems out there [NUMAQ?] and that
some folks use fake NUMA and cpusets on 32-bit systems for
container-like resource management.  For those systems, we could gain
back some of the size increase by making numa_maps configurable.  A
quick test showed that for x86_64, eliminating the /proc/<pid>/numa_maps
makes the kernel with my mapped file policy patches ~1.8K smaller than
the unpatched kernel with numa_maps.  I'm NOT proposing to eliminate
numa_maps, in general, because I find it very useful.  But maybe 32-bit
fake numa systems don't need it?

By the way, I think we need the numa_maps fixes in any case because the
current implementation lies about shmem segments if you look at any task
that didn't install [all of] the policy on the segment, unless it
happens to be a child of the task that did install the policy and that
child was forked after the mbind() calls.  I really dislike all of those
"ifs" and "unlesses"--I found it humorous in the George Carlin routine,
but not in user/programming interface design.

Anyway, I posted the patches in hopes of getting some additional eyes to
look at them and maybe getting some time in -mm to see whether it breaks
anything or impacts performance adversely on systems that I don't have
access to.

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
