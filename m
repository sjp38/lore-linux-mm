Date: Sun, 17 Sep 2006 06:19:22 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917061922.45695dcb.pj@sgi.com>
In-Reply-To: <450D434B.4080702@yahoo.com.au>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915012810.81d9b0e3.akpm@osdl.org>
	<20060915203816.fd260a0b.pj@sgi.com>
	<20060915214822.1c15c2cb.akpm@osdl.org>
	<20060916043036.72d47c90.pj@sgi.com>
	<20060916081846.e77c0f89.akpm@osdl.org>
	<20060917022834.9d56468a.pj@sgi.com>
	<450D1A94.7020100@yahoo.com.au>
	<20060917041525.4ddbd6fa.pj@sgi.com>
	<450D434B.4080702@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Oh no, I'm quite aware (and agree) that you'll _also_ need to cache
> your zonelist. So I agree with you up to there.

Ah - good.  Sorry for my misreading.


> The part of your suggestion that I think is too complex to worry about
> initially, is worrying about full/low/high watermarks and skipping over
> full zones in your cache.

Now I'm confused again.  I wasn't aware of giving the slightest
consideration to full/low/high watermarks in this design.

Could you quote the portion of my design in which you found this
consideration of watermarks?

I apparently did a lousy job of explaining something, and I'm not
even sure what part of my design I so messed up.


> So: just cache the *first* zone that the cpuset allows. If that is
> full and we have to search subsequent zones, so be it. I hope it would
> work reasonably well in the common case, though.

Well, hoping that I'm not misreading again, this seems like it won't
help.  In the case that Andrew and David present, the cpuset was
allowing pretty much every node (60 of 64, IIRC).  The performance
problem came in skipping over the nodes that David's test filled up
with a memory hog, to get to a node that still had memory it could
provide to the task running the kernel build.

So I don't think that it's finding the first node allowed by the
cpuset that is the painful part here.  I think it is finding the
first node that still has any free memory pages.

So I'm pretty sure that I have to cache the first node that isn't
full.  And I'm pretty sure that's what Andrew has been asking for
consistently.

Either I'm misreading your suggest to "Just cache the *first* zone
that the cpuset allows", or else the two of us have come away with
a very different understanding of this thread so far.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
