Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B01EE6B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 06:47:01 -0400 (EDT)
Date: Sun, 11 Apr 2010 12:46:08 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411104608.GA12828@elte.hu>
References: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC0DE84.3090305@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/10/2010 10:47 PM, Ingo Molnar wrote:
> >* Avi Kivity<avi@redhat.com>  wrote:
> >
> >>>I think what would be needed is some non-virtualization speedup example of
> >>>a 'non-special' workload, running on the native/host kernel. 'sort' is an
> >>>interesting usecase - could it be patched to use hugepages if it has to
> >>>sort through lots of data?
> >>In fact it works well unpatched, the 6% I measured was with the system sort.
> >Yes - but you intentionally sorted something large - the question is, how big
> >is the slowdown with small sizes (if there's a slowdown), where is the
> >break-even point (if any)?
> 
> There shouldn't be a slowdown as far as I can tell. [...]

It does not hurt to double check the before/after micro-cost precisely - it 
would be nice to see a result of:

  perf stat -e instructions --repeat 100 sort /etc/passwd > /dev/null

with and without hugetlb.

Linus is right in that the patches are intrusive, and the answer to that isnt 
to insist that it isnt so (it evidently is so), the correct reply is to 
broaden the utility of the patches and to demonstrate that the feature is 
useful on a much wider spectrum of workloads.

> > Would be nice to try because there's a lot of transformations within Gimp 
> > - and Gimp can be scripted. It's also a test for negatives: if there is an 
> > across-the-board _lack_ of speedups, it shows that it's not really general 
> > purpose but more specialistic.
> 
> Right, but I don't think I can tell which transforms are likely to be sped 
> up.  Also, do people manipulate 500MB images regularly?
> 
> A 20MB image won't see a significant improvement (40KB page tables, that's 
> chickenfeed).

> > If the optimization is specialistic, then that's somewhat of an argument 
> > against automatic/transparent handling. (even though even if the 
> > beneficiaries turn out to be only special workloads then transparency 
> > still has advantages.)
> 
> Well, we know that databases, virtualization, and server-side java win from 
> this.  (Oracle won't benefit from this implementation since it wants shared, 
> not anonymous, memory, but other databases may). I'm guessing large C++ 
> compiles, and perhaps the new link-time optimization feature, will also see 
> a nice speedup.
> 
> Desktops will only benefit when they bloat to ~8GB RAM and 1-2GB firefox 
> RSS, probably not so far in the future.

1-2GB firefox RSS is reality for me.

Btw., there's another workload that could be cache sensitive, 'git grep':

 aldebaran:~/linux> perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 5 git grep arca >/dev/null

 Performance counter stats for 'git grep arca' (5 runs):

     1882712774  cycles                     ( +-   0.074% )
     1153649442  instructions             #      0.613 IPC     ( +-   0.005% )
      518815167  dTLB-loads                 ( +-   0.035% )
        3028951  dTLB-load-misses           ( +-   1.223% )

    0.597161428  seconds time elapsed   ( +-   0.065% )

At first sight, with 7 cycles per cold TLB there's about 1.12% of a speedup 
potential in that workload. With just 1 cycle it's 0.16%. The real speedup 
ought to be somewhere inbetween.

Btw., instead of throwing random numbers like '3-4%' into this thread it would 
be nice if you could send 'perf stat --repeat' numbers like i did above - they 
have an error bar, they show the TLB details, they show the cycles and 
instructions proportion and they are also far more precise than 'time' based 
results.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
