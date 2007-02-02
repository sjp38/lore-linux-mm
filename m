From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Feb 2007 17:41:33 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17858.56605.643106.476961@notabene.brown>
Subject: Re: [RFC 0/8] Cpuset aware writeback
In-Reply-To: message from Christoph Lameter on Thursday February 1
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<45C2960B.9070907@google.com>
	<Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com>
	<20070201200358.89dd2991.akpm@osdl.org>
	<Pine.LNX.4.64.0702012044090.10575@schroedinger.engr.sgi.com>
	<17858.54239.364738.88727@notabene.brown>
	<Pine.LNX.4.64.0702012213140.31640@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ethan Solomita <solo@google.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thursday February 1, clameter@sgi.com wrote:
> 
> > The network stack is of course a different (much harder) problem.
> 
> An NFS solution is possible without solving the network stack issue?

NFS is currently able to make more than max_dirty_ratio of memory
Dirty/Writeback without being effectively throttled.  So it can use up
way more than it should and put pressure in the network stack.

If NFS were throttled like other block-based filesystems (which
Peter's patch should do), then there will normally be a lot more head
room and the network stack will normally be able to cope.  There might
still be situations were you can run out of memory to the extent that
NFS cannot make forward progress, but they will be substantially less
likely (I think you need lots of TCP streams with slow consumers and
fast producers so that TCP is forced to use up it reserves).

The block layer guarantees not to run out of memory.
The network layer makes a best effort as long as nothing goes crazy.
NFS (currently) doesn't do quite enough to stop things going crazy.

At least, that is my understanding.

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
