Date: Mon, 30 Jun 2003 20:02:37 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: What to expect with the 2.6 VM
Message-Id: <20030630200237.473d5f82.akpm@digeo.com>
In-Reply-To: <20030701022516.GL3040@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet>
	<20030701022516.GL3040@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Tue, Jul 01, 2003 at 02:39:47AM +0100, Mel Gorman wrote:
> >    Reverse Page Table Mapping
> >    ==========================
> ...
> 
> you mention only the positive things, and never the fact that's the most
> hurting piece of kernel code in terms of performance and smp scalability
> until you actually have to swapout or pageout.

It has no SMP scalability cost, and not really much CPU cost (it's less
costly than HZ=1000, for example).  Its main problem is space consumption.


> >    Non-Linear Populating of Virtual Areas
> >    ======================================
> ...
> 
> and it was used to break truncate,

Spose so.  Do we care though?  Unix standards do not specify truncate
behaviour with nonlinear mappings anyway.

Our behaviour right now is "random crap".  If there's a reason why we want
consistent semantics then yes, we'll need to do an rmap walk or something
in there.  But is there a requirement?  What is it?


One thing which clearly _should_ have sane semantics with nonlinear
mappings is mincore().  MAP_NONLINEAR broke that too.


> >    the flags are implemented in many different parts of the kernel.
> >    The
> >    NOFAIL flag requires teh VM to constantly retry an allocation until it
> 
> described this way it sounds like NOFAIL imply a deadlock condition.

NOFAIL is what 2.4 has always done, and has the deadlock opportunities
which you mention.  The other modes allow the caller to say "don't try
forever".

It's mainly a cleanup - it allowed the removal of lots of "try forever"
loops by consolidating that behaviour in the page allocator.  If all
callers are fixed up to not require NOFAIL then we don't need it any more.

> as for the per-zone lists, sure they increase scalability, but it loses
> aging information, the worst case will be reproducible on a 1.6G box,

Actually it improves aging information.  Think of a GFP_KERNEL allocation
on an 8G 2.4.x box: an average of 10 or more highmem pages get bogusly
rotated to the wrong end of the LRU for each scanned lowmem page.

That's speculation btw.  I don't have any numbers or tests which indicate
that it was a net win in this regard.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
