Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412EBD22.2090508@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
	 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
	 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
	 <412EBD22.2090508@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093583072.2984.463.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 22:04:32 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 21:48, Hiroyuki KAMEZAWA wrote:
> I testd set_bit()/__set_bit() ops, atomic and non atomic ops, on my Xeon.
> I think this test is not perfect, but shows some aspect of pefromance of atomic ops.
> 
> Program:
> the program touches memory in tight loop, using atomic and non-atomic set_bit().
> memory size is 512k, L2 cache size.
> I attaches it in this mail, but it is configured to my Xeon and looks ugly :).
...
> To Dave:
> cost of prefetch() is not here, because I found it is very sensitive to
> what is done in the loop and difficult to measure in this program.
> I found cost of calling prefetch is a bit high, I'll measure whether
> prefetch() in buddy allocator is good or bad again.
> 
> I think this result shows I should use non-atomic ops when I can.

I think we all know that locked instructions are going to be slower. 
However, what I wanted to see is how it influences a slightly more
realistic test, and actually in the context of the kernel.  Let's
actually see how much impact using the prefetch() and atomic vs
non-atomic ops has when they're used *in* the kernel on a less
contrived  less microbenchmarky test.

How about finding some kind of benchmark that will do a bunch of forking
and a bunch of page faulting to cause lots of activity in the allocator?

I'd suggest something like http://ck.kolivas.org/kernbench/ or SDET if
you can get your hands on it.  Anybody else have some suggestions?

The atomic ops, you're probably right about, but it would still be nice
to have some hard data.  As for prefetch(), we could scatter it and
unlikely() all over the kernel, but we only tend to do so when we can
either demonstrate a concrete gain, or it is a super-hot path.  With
hot-and-cold-pages around, even the allocator functions don't
necessarily count as super-hot.  

I'll run kernbench and sdet with and without the atomic ops and prefetch
on some of my hardware and see what I come up with.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
