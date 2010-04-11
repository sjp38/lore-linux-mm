Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C6EDD6B01EF
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 07:31:34 -0400 (EDT)
Message-ID: <4BC1B2CA.8050208@redhat.com>
Date: Sun, 11 Apr 2010 14:30:18 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu>
In-Reply-To: <20100411104608.GA12828@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 01:46 PM, Ingo Molnar wrote:
>
>> There shouldn't be a slowdown as far as I can tell. [...]
>>      
> It does not hurt to double check the before/after micro-cost precisely - it
> would be nice to see a result of:
>
>    perf stat -e instructions --repeat 100 sort /etc/passwd>  /dev/null
>
> with and without hugetlb.
>    

With:

         1036752  instructions             #      0.000 IPC     ( +-   
0.092% )

Without:

         1036844  instructions             #      0.000 IPC     ( +-   
0.100% )

> Linus is right in that the patches are intrusive, and the answer to that isnt
> to insist that it isnt so (it evidently is so),

No one is insisting the patches aren't intrusive.  We're insisting they 
bring a real benefit.  I think Linus' main objection was that hugetlb 
wouldn't work due to fragmentation, and I think we've demonstrated that 
antifrag/compaction do allow hugetlb to work even during a fragmenting 
workload running in parallel.

> the correct reply is to
> broaden the utility of the patches and to demonstrate that the feature is
> useful on a much wider spectrum of workloads.
>    

That's probably not the case.  I don't expect a significant improvement 
in desktop experience.  The benefit will be for workloads with large 
working sets and random access to memory.

>> Well, we know that databases, virtualization, and server-side java win from
>> this.  (Oracle won't benefit from this implementation since it wants shared,
>> not anonymous, memory, but other databases may). I'm guessing large C++
>> compiles, and perhaps the new link-time optimization feature, will also see
>> a nice speedup.
>>
>> Desktops will only benefit when they bloat to ~8GB RAM and 1-2GB firefox
>> RSS, probably not so far in the future.
>>      
> 1-2GB firefox RSS is reality for me.
>    

Mine usually crashes sooner...  interestingly, its vmas are heavily 
fragmented:

00007f97f1500000   2048K rw---    [ anon ]
00007f97f1800000   1024K rw---    [ anon ]
00007f97f1a00000   1024K rw---    [ anon ]
00007f97f1c00000   2048K rw---    [ anon ]
00007f97f1f00000   1024K rw---    [ anon ]
00007f97f2100000   1024K rw---    [ anon ]
00007f97f2300000   1024K rw---    [ anon ]
00007f97f2500000   1024K rw---    [ anon ]
00007f97f2700000   1024K rw---    [ anon ]
00007f97f2900000   1024K rw---    [ anon ]
00007f97f2b00000   2048K rw---    [ anon ]
00007f97f2e00000   2048K rw---    [ anon ]
00007f97f3100000   1024K rw---    [ anon ]
00007f97f3300000   1024K rw---    [ anon ]
00007f97f3500000   1024K rw---    [ anon ]
00007f97f3700000   1024K rw---    [ anon ]
00007f97f3900000   2048K rw---    [ anon ]
00007f97f3c00000   2048K rw---    [ anon ]
00007f97f3f00000   1024K rw---    [ anon ]

So hugetlb won't work out-of-the-box on firefox.

> Btw., there's another workload that could be cache sensitive, 'git grep':
>
>   aldebaran:~/linux>  perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 5 git grep arca>/dev/null
>
>   Performance counter stats for 'git grep arca' (5 runs):
>
>       1882712774  cycles                     ( +-   0.074% )
>       1153649442  instructions             #      0.613 IPC     ( +-   0.005% )
>        518815167  dTLB-loads                 ( +-   0.035% )
>          3028951  dTLB-load-misses           ( +-   1.223% )
>
>      0.597161428  seconds time elapsed   ( +-   0.065% )
>
> At first sight, with 7 cycles per cold TLB there's about 1.12% of a speedup
> potential in that workload. With just 1 cycle it's 0.16%. The real speedup
> ought to be somewhere inbetween.
>    

'git grep' is a pagecache workload, not anonymous memory, so it 
shouldn't see any improvement.  I imagine git will see a nice speedup if 
we get hugetlb for pagecache, at least for read-only workloads that 
don't hash all the time.

> Btw., instead of throwing random numbers like '3-4%' into this thread it would
> be nice if you could send 'perf stat --repeat' numbers like i did above - they
> have an error bar, they show the TLB details, they show the cycles and
> instructions proportion and they are also far more precise than 'time' based
> results.
>    

Sure.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
