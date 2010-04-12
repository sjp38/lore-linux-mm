Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78A7B6B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:47:19 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:45:57 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412074557.GA18485@elte.hu>
References: <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com>
 <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
 <4BC1F31E.2050009@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1F31E.2050009@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/11/2010 06:52 PM, Linus Torvalds wrote:
> >
> >On Sun, 11 Apr 2010, Avi Kivity wrote:
> >>
> >> And yet Oracle and java have options to use large pages, and we know 
> >> google and HPC like 'em.  Maybe they just haven't noticed the fundamental 
> >> brokenness yet.

( Add Firefox to the mix too - it too allocates in 1MB/2MB chunks. Perhaps 
  Xorg as well. )

> > The thing is, what you are advocating is what traditional UNIX did. 
> > Prioritizing the special cases rather than the generic workloads.
> >
> > And I'm telling you, it's wrong. Traditional Unix is dead, and it's dead 
> > exactly _because_ it prioritized those kinds of loads.
> 
> This is not a specialized workload.  Plenty of sites are running java, 
> plenty of sites are running Oracle (though that won't benefit from anonymous 
> hugepages), and plenty of sites are running virtualization.  Not everyone 
> does two kernel builds before breakfast.

Java/virtualization/DBs, and, to a certain sense Firefox have basically become 
meta-kernels: they offer their own intermediate APIs to their own style of 
apps - and those apps generally have no direct access to the native Linux 
kernel.

And just like the native kernel has been enjoying the benefits of 2MB pages 
for more than a decade, do these other entities want to enjoy similar benefits 
as well. Fair is fair.

Like it or not, combined end-user attention/work spent in these meta-kernels 
is rising steadily, while apps written in raw C are becoming the exception.

So IMHO we really have roughly three logical choices:

 1) either we accept that the situation is the fault of our technology and 
    subsequently we reform and modernize the Linux syscall ABIs to be more 
    friendly to apps (offer built-in GC and perhaps JIT concepts, perhaps 
    offer a compiler, offer a wider range of libraries with better 
    integration, etc.)

 2) or we accept the fact that the application space is shifting to the
    meta-kernels - and then we should agressively optimize Linux for those
    meta-kernels and not pretend that they are 'specialized'. They literally
    represent tens of thousands of applications apiece.

 3) or we should continue to muddle through somewhere in the middle, hoping 
    that the 'pure C apps' win in the end (despite 10 years of a decline) and
    pretend that the meta-kernels are just 'specialized' workloads.

Right now we are doing 3) and i think it's delusive and a mistake. I think we 
should be doing 1) - but failing that we have to be honest and do 2).

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
