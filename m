Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 76A8E6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 04:14:38 -0400 (EDT)
Date: Mon, 12 Apr 2010 18:14:31 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412081431.GT5683@laptop>
References: <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com>
 <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
 <4BC1F31E.2050009@redhat.com>
 <20100412074557.GA18485@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412074557.GA18485@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 09:45:57AM +0200, Ingo Molnar wrote:
> 
> * Avi Kivity <avi@redhat.com> wrote:
> 
> > On 04/11/2010 06:52 PM, Linus Torvalds wrote:
> > >
> > >On Sun, 11 Apr 2010, Avi Kivity wrote:
> > >>
> > >> And yet Oracle and java have options to use large pages, and we know 
> > >> google and HPC like 'em.  Maybe they just haven't noticed the fundamental 
> > >> brokenness yet.
> 
> ( Add Firefox to the mix too - it too allocates in 1MB/2MB chunks. Perhaps 
>   Xorg as well. )
> 
> > > The thing is, what you are advocating is what traditional UNIX did. 
> > > Prioritizing the special cases rather than the generic workloads.
> > >
> > > And I'm telling you, it's wrong. Traditional Unix is dead, and it's dead 
> > > exactly _because_ it prioritized those kinds of loads.
> > 
> > This is not a specialized workload.  Plenty of sites are running java, 
> > plenty of sites are running Oracle (though that won't benefit from anonymous 
> > hugepages), and plenty of sites are running virtualization.  Not everyone 
> > does two kernel builds before breakfast.
> 
> Java/virtualization/DBs, and, to a certain sense Firefox have basically become 
> meta-kernels: they offer their own intermediate APIs to their own style of 
> apps - and those apps generally have no direct access to the native Linux 
> kernel.
> 
> And just like the native kernel has been enjoying the benefits of 2MB pages 
> for more than a decade, do these other entities want to enjoy similar benefits 
> as well. Fair is fair.
> 
> Like it or not, combined end-user attention/work spent in these meta-kernels 
> is rising steadily, while apps written in raw C are becoming the exception.
> 
> So IMHO we really have roughly three logical choices:

I don't see how these are the logical choices. I don't really see how
they are even logical in some ways. Let's say that Andrea's patches
offer 5% improvement in best-cases (that are not stupid microbenchmarks)
and 0% in worst cases, and X% "on average" (whatever that means). Then
it is simply a set of things to weigh against the added complexity (both
in terms of code and performance characteristics of the system) that it
is introduced.

I don't really see how it is fundamentally different to any other patch
that speeds things up.

 
>  1) either we accept that the situation is the fault of our technology and 
>     subsequently we reform and modernize the Linux syscall ABIs to be more 
>     friendly to apps (offer built-in GC and perhaps JIT concepts, perhaps 
>     offer a compiler, offer a wider range of libraries with better 
>     integration, etc.)

I don't see how this would bring transparent hugepages to userspace. We
may offload some services to the kernel, but the *memory mappings* that
get used by userspace obviously still go through TLBs.

 
>  2) or we accept the fact that the application space is shifting to the
>     meta-kernels - and then we should agressively optimize Linux for those
>     meta-kernels and not pretend that they are 'specialized'. They literally
>     represent tens of thousands of applications apiece.

And if meta-kernels (or whatever you want to call a common or important
workload) see some speedup that is deemed to be worth the cost of the
patch, then it will probably get merged. Same as anything else.

 
>  3) or we should continue to muddle through somewhere in the middle, hoping 
>     that the 'pure C apps' win in the end (despite 10 years of a decline) and
>     pretend that the meta-kernels are just 'specialized' workloads.

'pure C apps' (I don't know what you mean by this, but just non-GC
memory?) can still see benefits from using hugepages.

And I wouldn't say we're muddling through. Linux has been one of the
if not the most successful OS kernel of the last 10 years not because
of muddling. IMO in large part it is because we haven't been forced to
tick boxes for marketing idiots or be pressured by special interests
to the detriment of the common cases.


> Right now we are doing 3) and i think it's delusive and a mistake. I think we 
> should be doing 1) - but failing that we have to be honest and do 2).

Nothing wrong with carefully evaluating a performance improvement, but
there is nothing urgent or huge fundamental reason we need to lose our
heads and be irrational about it. If the world was coming to an end
without hugepages, then we'd see more than 5% improvement I would have
thought.

Fact is that computing is based on locality of reference, and
performance has continued to scale long past the big bad "memory wall"
because real working set sizes (on the scale of CPU instructions, not on
the scale of page reclaim) have not grown linearly with RAM sizes.
Probably logarithmically or something. Sure there are some pointer
chasing apps that will always (and ~have always) suck. We are also
irriversibly getting into explicit parallelism (like multi core and
multi threading) to work around all sorts of fundamental limits to
single thread performance, not just TLB filling.

So let's not be melodramatic about this :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
