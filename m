Date: Wed, 21 Nov 2007 18:20:49 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071122014455.GH31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211812060.4858@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
 <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com>
 <20071121230041.GE31674@csn.ul.ie> <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com>
 <20071121235849.GG31674@csn.ul.ie> <Pine.LNX.4.64.0711211605010.4556@schroedinger.engr.sgi.com>
 <20071122014455.GH31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Nov 2007, Mel Gorman wrote:

> And the results were better as well. Running one instance per-CPU, the
> joined lists ignoring temperature was marginally faster than no-PCPU or
> the hotcold-PCPU up to 0.5MB which roughly corresponds to the some of L1
> caches of the CPUs. At higher sizes, it starts to look slower but even
> at 8MB files, it is by a much smaller amount. With list manuipulations,
> it is about 0.3 seconds slower. With just the lists joined, it's 0.1
> seconds and I think the patch could simplify the paths more than what we
> have currently. The full graph is at

Hmmm... This sounds like we could improve the situation by just having 
single linked lists? The update effort is then much less.

Here is a matrix of page allocator performance (2.6.24-rc2 with 
sparsemem) done with my page allocator test from 
http://git.kernel.org/?p=linux/kernel/git/christoph/slab.git;a=log;h=tests

All tests are in cycles

Single thread testing
=====================
1. Repeatedly allocate then free test
1000 times alloc_page(,0) -> 616 cycles __free_pages(,0)-> 295 cycles
1000 times alloc_page(,1) -> 576 cycles __free_pages(,1)-> 341 cycles
1000 times alloc_page(,2) -> 712 cycles __free_pages(,2)-> 380 cycles
1000 times alloc_page(,3) -> 966 cycles __free_pages(,3)-> 467 cycles
1000 times alloc_page(,4) -> 1435 cycles __free_pages(,4)-> 662 cycles
1000 times alloc_page(,5) -> 2201 cycles __free_pages(,5)-> 1044 cycles
1000 times alloc_page(,6) -> 3770 cycles __free_pages(,6)-> 2550 cycles
1000 times alloc_page(,7) -> 6781 cycles __free_pages(,7)-> 7652 cycles
1000 times alloc_page(,8) -> 13592 cycles __free_pages(,8)-> 17999 cycles
1000 times alloc_page(,9) -> 27970 cycles __free_pages(,9)-> 36335 cycles
1000 times alloc_page(,10) -> 58586 cycles __free_pages(,10)-> 72323 cycles
2. alloc/free test
1000 times alloc( ,0)/free -> 349 cycles
1000 times alloc( ,1)/free -> 531 cycles
1000 times alloc( ,2)/free -> 571 cycles
1000 times alloc( ,3)/free -> 663 cycles
1000 times alloc( ,4)/free -> 853 cycles
1000 times alloc( ,5)/free -> 1220 cycles
1000 times alloc( ,6)/free -> 2092 cycles
1000 times alloc( ,7)/free -> 3640 cycles
1000 times alloc( ,8)/free -> 6524 cycles
1000 times alloc( ,9)/free -> 12421 cycles
1000 times alloc( ,10)/free -> 30197 cycles

This shows that actually order 1 allocations that bypass the pcp lists are 
faster! We save the overhead of extracting pages from the buddy lists and 
putting them into the pcp.

The alloc free tests shows that the pcp lists are effective when 
cache hot.

Concurrent allocs
=================
Page alloc N*alloc N*free(0): 0=8266/8635 1=9667/8129 2=8501/8585 3=9485/8129 4=7870/8635 5=9761/7957 6=7687/8456 7=9749/7681 Average=8873/8276
Page alloc N*alloc N*free(1): 0=28917/22006 1=30057/26753 2=28930/23925 
3=30099/26779 4=28845/23717 5=30166/26733 6=28250/23744 7=30149/26677 
Average=29427/25042
Page alloc N*alloc N*free(2): 0=25316/23430 1=28749/26527 2=24858/22929 
3=28804/26636 4=24871/23368 5=28496/26621 6=25188/22057 7=28730/26228 
Average=26877/24725
Page alloc N*alloc N*free(3): 0=22414/23618 1=26397/27478 2=22359/24237 
3=26413/27060 4=22328/24021 5=26098/27879 6=22391/23731 7=26322/27802 
Average=24340/25728
Page alloc N*alloc N*free(4): 0=24922/26358 1=28126/30480 2=24733/26177 
3=28267/30540 4=25016/25688 5=28150/30563 6=24938/24902 7=28247/30650 
Average=26550/28170
Page alloc N*alloc N*free(5): 0=25211/27315 1=29504/32577 2=25796/27681 
3=29565/32272 4=26056/26588 5=29471/32728 6=25967/26619 7=29447/32744 
Average=27627/29816

The difference between order and 1 shows that pcp lists are effective at 
reducing zone lru lock overhead. The difference is factor 3 at 8p.

----Fastpath---
Page N*(alloc free)(0): 0=363 1=360 2=379 3=363 4=362 5=363 6=363 7=360 
Average=364
Page N*(alloc free)(1): 0=41014 1=44448 2=40416 3=44367 4=40980 5=44411 
6=40760 7=44265 Average=42583
Page N*(alloc free)(2): 0=42686 1=45588 2=42202 3=45509 4=42733 5=45561 
6=42716 7=45485 Average=44060
Page N*(alloc free)(3): 0=40567 1=43556 2=39699 3=43404 4=40435 5=43274 
6=39614 7=43545 Average=41762
Page N*(alloc free)(4): 0=43310 1=45097 2=43326 3=45405 4=43219 5=45372 
6=42492 7=45378 Average=44200
Page N*(alloc free)(5): 0=42765 1=45370 2=42029 3=44979 4=42567 5=45336 
6=42929 7=45016 Average=43874

This is just allocating and freeing the same page all the time. Here the 
pcps are orders of magnitude faster.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
