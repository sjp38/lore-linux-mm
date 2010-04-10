Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCE16B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 15:48:15 -0400 (EDT)
Date: Sat, 10 Apr 2010 21:47:51 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410194751.GA23751@elte.hu>
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC0CFF4.5000207@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> > I think what would be needed is some non-virtualization speedup example of 
> > a 'non-special' workload, running on the native/host kernel. 'sort' is an 
> > interesting usecase - could it be patched to use hugepages if it has to 
> > sort through lots of data?
> 
> In fact it works well unpatched, the 6% I measured was with the system sort.

Yes - but you intentionally sorted something large - the question is, how big 
is the slowdown with small sizes (if there's a slowdown), where is the 
break-even point (if any)?

> > [...]
> >
> > Something like GIMP calculations would be a lot more representative of the 
> > speedup potential. Is it possible to run the GIMP with transparent 
> > hugepages enabled for it?
> 
> I thought of it, but raster work is too regular so speculative execution 
> should hide the tlb fill latency.  It's also easy to code in a way which 
> hides cache effects (no idea if it is actually coded that way).  Sort showed 
> a speedup since it defeats branch prediction and thus the processor cannot 
> pipeline the loop.

Would be nice to try because there's a lot of transformations within Gimp - 
and Gimp can be scripted. It's also a test for negatives: if there is an 
across-the-board _lack_ of speedups, it shows that it's not really general 
purpose but more specialistic.

If the optimization is specialistic, then that's somewhat of an argument 
against automatic/transparent handling. (even though even if the beneficiaries 
turn out to be only special workloads then transparency still has advantages.)

> I thought ray tracers with large scenes should show a nice speedup, but 
> setting this up is beyond my capabilities.

Oh, this tickled some memories: x264 compressed encoding can be very cache and 
TLB intense. Something like the encoding of a 350 MB video file:

  wget http://media.xiph.org/video/derf/y4m/soccer_4cif.y4m       # NOTE: 350 MB!
  x264 --crf 20 --quiet soccer_4cif.y4m -o /dev/null --threads 4

would be another thing worth trying with transparent-hugetlb enabled.

(i've Cc:-ed x264 benchmarking experts - in case i missed something)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
