Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 69C2D6B006A
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 22:27:46 -0500 (EST)
Date: Tue, 5 Jan 2010 19:27:07 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl> <20100104182813.753545361@chello.nl> <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com> <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com> <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain> <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com> <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain> <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
>
> My host boots successfully. Here is the result.

Hey, looks good. It does have that 3% trylock overhead:

      3.17%  multi-fault-all  [kernel]                  [k] down_read_trylock

but that doesn't seem excessive.

Of course, your other load with MADV_DONTNEED seems to be horrible, and 
has some nasty spinlock issues, but that looks like a separate deal (I 
assume that load is just very hard on the pgtable lock).

That said, profiles are hard to compare performance with - the main thing 
that matters for performance is not how the profile looks, but how it 
actually performs. So:

> Then, the result is much improved by XADD rwsem.
> 
> In above profile, rwsem is still there.
> But page-fault/sec is good. I hope some "big" machine users join to the test.

That "page-fault/sec" number is ultimately the only thing that matters. 

> Here is peformance counter result of DONTNEED test. Counting the number of page
> faults in 60 sec. So, bigger number of page fault is better.
> 
> [XADD rwsem]
> [root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8
> 
>  Performance counter stats for './multi-fault-all 8' (5 runs):
> 
>        41950863  page-faults                ( +-   1.355% )
>       502983592  cache-misses               ( +-   0.628% )
> 
>    60.002682206  seconds time elapsed   ( +-   0.000% )
> 
> [my patch]
> [root@bluextal memory]#  /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all 8
> 
>  Performance counter stats for './multi-fault-all 8' (5 runs):
> 
>        35835485  page-faults                ( +-   0.257% )
>       511445661  cache-misses               ( +-   0.770% )
> 
>    60.004243198  seconds time elapsed   ( +-   0.002% )
> 
> Ah....xadd-rwsem seems to be faster than my patch ;)

Hey, that sounds great. NOTE! My patch really could be improved. In 
particular, I suspect that on x86-64, we should take advantage of the 
64-bit counter, and use a different RW_BIAS. That way we're not limited to 
32k readers, which _could_ otherwise be a problem.

So consider my rwsem patch to be purely preliminary. Now that you've 
tested it, I feel a lot better about it being basically correct, but it 
has room for improvement.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
