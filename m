Date: Sat, 5 Apr 2003 16:17:58 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-ID: <PAO-EX016nzO9OMHffN000012fd@pao-ex01.pao.digeo.com>
Message-Id: <20030405161758.1ee19bfa.akpm@digeo.com>
In-Reply-To: <69120000.1049555511@[10.10.2.4]>
References: <20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
	<20030405024414.GP16293@dualathlon.random>
	<20030404192401.03292293.akpm@digeo.com>
	<20030405040614.66511e1e.akpm@digeo.com>
	<69120000.1049555511@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: andrea@suse.de, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > It sets up N MAP_SHARED VMA's and N tasks touching them in various access
> > patterns.
> 
> Can you clarify ... are these VMAs all mapping the same address space,
> or different ones? If the same, are you mapping the whole thing each time?

It is what you'd expect.  Each process has 100 MAP_SHARED "windows" into the
same file.  Those windows have gaps between them to prevent VMA merging.

> >> I don't think we have an app that has 1000 processes mapping the whole
> >> file 1000 times per process. If we do, shooting the author seems like
> >> the best course of action to me.
> > 
> > Rik:
> >
> > Please, don't shoot akpm ;)
> 
> If mapping the *whole* address space hundreds of times, why would anyone 
> ever actually want to do that? It kills some important optimisations that 
> Dave has made, and seems to be an unrealistic test case. I don't understand
> what you're trying to simulate with that (if that's what you are doing).
> Mapping 1000 subsegments I can understand, but not the whole thing.

Each process maps 100 different parts of the file.  It happens that each
process is mapping the same 100 segments as all the others.

> > 2.5.66-mm4:
> > 2.5.66-mm4+objrmap:
> 
> So mm4 has what? No partial objrmap at all (you dropped it?)? 
> Or partial but non anon?

urgh, sorry.

"2.5.66-mm4": full pte_chains - the 2.5.66 VM
'2.5.66-mm4+objrmap": partial objrmap

> 
> Well, it also consumes the most space. How about adding a test that has
> 1000s of processes mapping one large (2GB say) VMA, and seeing what that 
> does? That's the workload of lots of database type things.

That would be:

512 tasks each of which holds a single 256MB VMA over the first 256MB of a
shared file.

	./rmap-test -r -i 1 -n 1 -s 65000 -t 512 foo

2.5.66-mm4:
	?
2.5.66-mm4+objrmap:
	?
2.4.21-pre5aa2:
	0.21s user 121.41s system 10% cpu 19:58.94 total

I don't know how long 2.5 is going to take to run this test - many hours
certainly.  And 2.4 only managed to achieve 0.02% CPU utilisation.

This is like multithreaded qsbench.  Because the 2.4 VM is unfair it allows
individual tasks to make good progress while most of the others make none at
all.  In 2.5 they all make similar progress and thrash each other to bits.

We need load control to solve this properly.

> > When it comes to the VM, there is a lot of value in sturdiness under 
> > unusual and heavy loads.
> 
> Indeed. Which includes not locking up the whole box in a solid hang
> from ZONE_NORMAL consumption though ...

There are perhaps a few things we can do about that.

It's only a problem on the kooky highmem boxes, and they need page clustering
anyway.

And this is just another instance of "lowmem pinned by highmem pages" which
could be solved by unmapping (and not necessarily reclaiming) the highmem
pages.  But that's a pretty lame thing to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
