Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A0BBA6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:08:18 -0400 (EDT)
Date: Sun, 11 Apr 2010 14:08:00 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411120800.GC10952@elte.hu>
References: <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1B2CA.8050208@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/11/2010 01:46 PM, Ingo Molnar wrote:
> >
> >>There shouldn't be a slowdown as far as I can tell. [...]
> >It does not hurt to double check the before/after micro-cost precisely - it
> >would be nice to see a result of:
> >
> >   perf stat -e instructions --repeat 100 sort /etc/passwd>  /dev/null
> >
> >with and without hugetlb.
> 
> With:
> 
>         1036752  instructions             #      0.000 IPC     ( +-
> 0.092% )
> 
> Without:
> 
>         1036844  instructions             #      0.000 IPC     ( +-
> 0.100% )
> 
> > Linus is right in that the patches are intrusive, and the answer to that 
> > isnt to insist that it isnt so (it evidently is so),
> 
> No one is insisting the patches aren't intrusive.  We're insisting they 
> bring a real benefit.  I think Linus' main objection was that hugetlb 
> wouldn't work due to fragmentation, and I think we've demonstrated that 
> antifrag/compaction do allow hugetlb to work even during a fragmenting 
> workload running in parallel.

As i understood it i think Linus had three main objections:

 1- the improvements were only shown in specialistic environments
    (virtualization, servers)

 2- complexity

 3- futility: defrag is hard and theoretically impossible

1) numbers were too specialistic

I think if some more numbers are gathered and if hugetlb/nohugetlb is made a 
bit more configurable (on a per workload basis) then this concern is fairly 
addressed.

2) complexity

There's probably not much to be done about this. It's a cost/benefit tradeoff 
decision, i.e. depends on the other two factors.

3) futility

I think Andrea and Mel and you demonstrated that while defrag is futile in 
theory (we can always fill up all of RAM with dentries and there's no 2MB 
allocation possible), it seems rather usable in practice.

> > the correct reply is to broaden the utility of the patches and to 
> > demonstrate that the feature is useful on a much wider spectrum of 
> > workloads.
> 
> That's probably not the case.  I don't expect a significant improvement in 
> desktop experience.  The benefit will be for workloads with large working 
> sets and random access to memory.

See my previous mail about the 'RAM gap' - i think it matters more than you 
think.

The important thing to realize is that the working set of the 'desktop' is 
_not_ independent of RAM size: it just fills up RAM to the 'typical average 
RAM size'. That is around 2 GB today. In 5-10 years it will be at 16 GB.

Applications will just bloat up to that natural size. They'll use finer 
default resolutions, larger internal caches, etc. etc.

So IMO it all matters to the desktop too and is not just a server feature. We 
saw this again and again: today's server scalability limitation is tomorrow's 
desktop scalability limitation.

> Mine usually crashes sooner...  interestingly, its vmas are heavily
> fragmented:
> 
> 00007f97f1500000   2048K rw---    [ anon ]
> 00007f97f1800000   1024K rw---    [ anon ]
> 00007f97f1a00000   1024K rw---    [ anon ]
> 00007f97f1c00000   2048K rw---    [ anon ]
> 00007f97f1f00000   1024K rw---    [ anon ]
> 00007f97f2100000   1024K rw---    [ anon ]
> 00007f97f2300000   1024K rw---    [ anon ]
> 00007f97f2500000   1024K rw---    [ anon ]
> 00007f97f2700000   1024K rw---    [ anon ]
> 00007f97f2900000   1024K rw---    [ anon ]
> 00007f97f2b00000   2048K rw---    [ anon ]
> 00007f97f2e00000   2048K rw---    [ anon ]
> 00007f97f3100000   1024K rw---    [ anon ]
> 00007f97f3300000   1024K rw---    [ anon ]
> 00007f97f3500000   1024K rw---    [ anon ]
> 00007f97f3700000   1024K rw---    [ anon ]
> 00007f97f3900000   2048K rw---    [ anon ]
> 00007f97f3c00000   2048K rw---    [ anon ]
> 00007f97f3f00000   1024K rw---    [ anon ]
> 
> So hugetlb won't work out-of-the-box on firefox.

Hm, seems to have 1MB holes between them.

Half of them are 2MB in size, but half of them are not properly aligned. So 
about 33% of firefox's anon memory is hugepage-able straight away - still 
nonzero.

(Plus maybe if this comes from glibc then it could be handled by patching 
glibc.)

> 'git grep' is a pagecache workload, not anonymous memory, so it shouldn't 
> see any improvement. [...]

Indeed, git grep is read() based.

> [...]  I imagine git will see a nice speedup if we get hugetlb for 
> pagecache, at least for read-only workloads that don't hash all the time.

Shouldnt that already be the case today? The pagecache is in the kernel where 
we have things 2MB mapped. Git read()s it into the same [small] buffer again 
and again, so the only 'wide' address space access it does is within the 
kernel, to the 2MB mapped pagecache pages.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
