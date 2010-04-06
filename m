Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 580856B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 09:58:31 -0400 (EDT)
Message-ID: <4BBB3DDB.7010101@redhat.com>
Date: Tue, 06 Apr 2010 16:57:47 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <4BBB052D.8040307@redhat.com> <4BBB2134.9090301@redhat.com> <20100406131024.GA5288@laptop> <4BBB359D.1020603@redhat.com> <20100406134539.GC5288@laptop>
In-Reply-To: <20100406134539.GC5288@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/06/2010 04:45 PM, Nick Piggin wrote:
> On Tue, Apr 06, 2010 at 04:22:37PM +0300, Avi Kivity wrote:
>    
>> On 04/06/2010 04:10 PM, Nick Piggin wrote:
>>      
>>> Actual workloads are infinitely more useful. And in
>>> most cases, quite possibly hardware improvements like asids will
>>> be more useful.
>>>        
>> This already has ASIDs for the guest; and for the host they wouldn't
>> help much since there's only one process running.
>>      
> I didn't realize these improvements were directed completely at the
> virtualized case.
>    

I've read somewhere that future x86 will get non virtualization ASIDs, 
but currently that's the case.  They've been present for the virtualized 
case for a few years now on AMD and introduced recently (with Nehalem) 
on Intel (known as VPIDs).

>>   I don't see how
>> hardware improvements can drastically change the numbers above, it's
>> clear that for the 4k case the host takes a cache miss for the pte,
>> and twice for the 4k/4k guest case.
>>      
> It's because you're missing the point. You're taking the most
> unrealistic and pessimal cases and then showing that it has fundamental
> problems.

That's just a demonstration.  Again, I don't expect 3x speedups from 
large pages.

> Speedups like Linus is talking about would refer to ways to
> speed up actual workloads, not ways to avoid fundamental limitations.
>
> Prefetching, memory parallelism, caches. It's worked for 25 years :)
>    

Prefetching and memory parallelism are defeated by pointer chasing, 
which many workloads do.  It's no accident that Java is a large 
beneficiary of large pages since Java programs are lots of small objects 
scattered around in memory.

Caches don't scale as fast as memory, and are shared with data and other 
cores anyway.

If you have 200ns of honest work per pointer dereference, then a 64GB 
working set will still see 300ns stalls with 4k pages vs 50 ns with 
large pages (both non-virtualized).  200ns is quite a bit of work per 
object.


>>> I don't really agree with how virtualization problem is characterised.
>>> Xen's way of doing memory virtualization maps directly to normal
>>> hardware page tables so there doesn't seem like a fundamental
>>> requirement for more memory accesses.
>>>        
>> The Xen pv case only works for modified guests (so no Windows), and
>> doesn't support host memory management like swapping or ksm.  Xen
>> hvm (which runs unmodified guests) has the same problems as kvm.
>>
>> Note kvm can use a single layer of translation (and does on older
>> hardware), so it would behave like the host, but that increases the
>> cost of pte updates dramatically.
>>      
> So it is fundamentally possible.
>    

The costs are much bigger than the gain, especially when scaling the 
number of vcpus.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
