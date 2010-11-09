Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B57576B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:39:13 -0500 (EST)
Date: Tue, 9 Nov 2010 21:38:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01 of 66] disable lumpy when compaction is enabled
Message-ID: <20101109213855.GM32723@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <ca2fea6527833aad8adc.1288798056@v2.random> <20101109121318.BC51.A69D9226@jp.fujitsu.com> <20101109213049.GC6809@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101109213049.GC6809@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 10:30:49PM +0100, Andrea Arcangeli wrote:
> On Tue, Nov 09, 2010 at 12:18:49PM +0900, KOSAKI Motohiro wrote:
> > I'm talking very personal thing now. I'm usually testing both feature.
> > Then, runtime switching makes my happy :-)
> > However I don't know what are you and Mel talking and agree about this.
> > So, If many developer prefer this approach, I don't oppose anymore.
> 
> Mel seem to still prefer I allow lumpy for hugetlbfs with a
> __GFP_LUMPY specified only for hugetlbfs. But he measured compaction
> is more reliable than lumpy at creating hugepages so he seems to be ok
> with this too.
> 

Specifically, I measured that lumpy in combination with compaction is
more reliable and lower latency but that's not the same as deleting it.

That said, lumpy does hurt the system a lot.  I'm prototyping a series at the
moment that pushes lumpy reclaim to the side and for the majority of cases
replaces it with "lumpy compaction". I'd hoping this will be sufficient for
THP and alleviate the need to delete it entirely - at least until we are 100%
sure that compaction can replace it in all cases.

Unfortunately, in the process of testing it today I also found out that
2.6.37-rc1 had regressed severely in terms of huge page allocations so I'm
side-tracked trying to chase that down. My initial theories for the regression
have shown up nothing so I'm currently preparing to do a bisection. This
will take a long time though because the test is very slow :(

I can still post the series as an RFC if you like to show what direction
I'm thinking of but at the moment, I'm unable to test it until I pin the
regression down.

> > But, I bet almost all distro choose CONFIG_COMPACTION=y. then, lumpy code
> > will become nearly dead code. So, I like just kill than dead code. however
> > it is also only my preference. ;)
> 
> Killing dead code is my preference too indeed. But then it's fine with
> me to delete it only later. In short this is least intrusive
> modification I could make to the VM that wouldn't than hang the system
> when THP is selected because all pte young bits are ignored for >50%
> of page reclaim invocations like lumpy requires.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
