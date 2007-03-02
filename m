Date: Thu, 1 Mar 2007 20:31:24 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302042149.GB15867@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com>
 <20070302035751.GA15867@wotan.suse.de> <Pine.LNX.4.64.0703012001260.5548@schroedinger.engr.sgi.com>
 <20070302042149.GB15867@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Nick Piggin wrote:

> > Yes, we (SGI) need exactly that: Use of higher order pages in the kernel 
> > in order to reduce overhead of managing page structs for large I/O and 
> > large memory applications. We need appropriate measures to deal with the 
> > fragmentation problem.
> 
> I don't understand why, out of any architecture, ia64 would have to hack
> around this in software :(

Ummm... We have x86_64 platforms with the 4k page problem. 4k pages are 
very useful for the large number of small files that are around. But for 
the large streams of data you would want other methods of handling these.

If I want to write 1 terabyte (2^50) to disk then the I/O subsystem has 
to handle 2^(50-12) = 2^38 = 256 million page structs! This limits I/O 
bandwiths and leads to huge scatter gather lists (and we are limited in 
terms of the numbe of items on those lists in many drivers). Our future 
platforms have up to serveral petabytes of memory. There needs to be some 
way to handle these capacities in an efficient way. We cannot wait 
an hour for the terabyte to reach the disk.
 
> > We need to reduce the real hardware zones as much as possible. Most high 
> > performance architectures have no need for additional DMA zones f.e. and
> > do not have to deal with the complexities that arise there.
> 
> And then you want to add something else on top of them?

zones are basically managing a number of MAX_ORDER chunks. The adding of 
something here is dealing with the categorization of these MAX_ORDER 
chunks in order to insure movability and thus defragmentability of
most of them. Or the upper layer may limit the number of those chunks
assigned to a certain container.

> > Yes that would mean merging nodes and zones. So "nones".
> 
> Yes, this is what Andrew just said. But you then wanted to add virtual zones
> or something on top. I just don't understand why. You agree that merging
> nodes and zones is a good idea. Did I miss the important post where some
> bright person discovered why merging zones and "virtual zones" is a bad
> idea?

Hmmm.. I usually talk about the "virtual zones" as virtual nodes. But we 
are basically at the same point there. Node level controls and APIs exist and 
can even be used from user space. A container could just be a special node 
and then the allocations to this container could be controlled via the 
existing APIs.

A virtual zone/node would be assigned a number of MAX_ORDER blocks from 
real zones/nodes. Then it may hopefully be managed like a real node. In 
the original zone/node these MAX_ORDER blocks would show up as 
unavailable. The "upper" layer therefore is the existing node/zone layer. 
The virtual zones/nodes just steal memory from the real ones.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
