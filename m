Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F33026B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 12:46:34 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:40:54 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: hugepages will matter more in the future
In-Reply-To: <4BC34837.7020108@redhat.com>
Message-ID: <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org>
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com> <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org> <4BC34837.7020108@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>



On Mon, 12 Apr 2010, Rik van Riel wrote:

> On 04/11/2010 11:52 AM, Linus Torvalds wrote:
> 
> > So here's the deal: make the code cleaner, and it's fine. And stop trying
> > to sell it with _crap_.
> 
> Since none of the hugepages proponents in this thread seem to have
> asked this question:
> 
> What would you like the code to look like, in order for hugepages
> code to be acceptable to you?

So as I already commented to Andrew, the code has no comments about the 
"big picture", and the largest comment I found was about a totally 
_trivial_ issue about replacing the hugepage by first clearing the entry, 
then flushing the tlb, and then filling it.

That needs hardly any comment at all, since that's what we do for _normal_ 
page table entries too when we change anything non-trivial about them. 
That's the anti-thesis of rocket science. Yet that was apparently 
considered the most important thing in the whole core patch to talk about!

And quite frankly, I've been irritated by the "timings" used to sell this 
thing from the start. The changelog for the entry makes a big deal out of 
the fact that there's just a single page fault per 2MB, and that the page 
timing for clearing a huge region is faster the first time because you 
don't take a lot of page faults.

That's a "Duh!" moment too, but it never even talks about the issue of 
"oh, well, we did allocate all those 2M chunks, not knowing whether they 
were going to be used or not".

Sure, it's going to help programs that actually use all of it. Nobody is 
surprised. What I still care about, what what makes _all_ the timings I've 
seen in this whole insane thread pretty much totally useless, is the fact 
that we used to know that what _really_ speeds up a machine is caching. 
Keeping _relevant_ data around so that you don't do IO. And the mantra 
from pretty much day one has been "free memory is wasted memory".

Yet now, the possibility of _truly_ wasting memory isn't apparently even a 
blip on anybody's radar. People blithely talk about changing glibc default 
behavior as if there are absolutely no issues, and 2MB chunks are pocket 
change.

I can pretty much guarantee that every single developer on this list has a 
machine with excessive amounts of memory compared to what the machine is 
actually required to do. And I just do not think that is true in general.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
