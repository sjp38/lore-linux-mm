Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3995D6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 07:00:35 -0400 (EDT)
Message-ID: <4BC2FCFA.5080004@redhat.com>
Date: Mon, 12 Apr 2010 13:59:06 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu> <20100412060931.GP5683@laptop> <4BC2BF67.80903@redhat.com> <20100412071525.GR5683@laptop> <4BC2CF8C.5090108@redhat.com> <20100412082844.GU5683@laptop> <4BC2E1D6.9040702@redhat.com> <20100412092615.GY5683@laptop> <4BC2EFBA.5080404@redhat.com> <20100412103701.GZ5683@laptop>
In-Reply-To: <20100412103701.GZ5683@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 01:37 PM, Nick Piggin wrote:
>
>> I don't see why it will degrade.  Antifrag will prefer to allocate
>> dcache near existing dcache.
>>
>> The only scenario I can see where it degrades is that you have a
>> dcache load that spills over to all of memory, then falls back
>> leaving a pinned page in every huge frame.  It can happen, but I
>> don't see it as a likely scenario.  But maybe I'm missing something.
>>      
> No, it doesn't need to make all hugepages unavailable in order to
> start degrading. The moment that fewer huge pages are available than
> can be used, due to fragmentation, is when you could start seeing
> fragmentation.
>    

Graceful degradation is fine.  We're degrading to the current situation 
here, not something worse.

> If you're using higher order allocations in the kernel, like SLUB
> will especially (and SLAB will for some things) then the requirement
> for fragmentation basically gets smaller by I think about the same
> factor as the page size. So order-2 slabs only need to fill 1/4 of
> memory in order to be able to fragment entire memory. But fragmenting
> entire memory is not the start of the degredation, it is the end.
>    

Those order-2 slabs should be allocated in the same page frame.  If 
they're allocated randomly, sure, you need 1 allocation per huge page 
frame.  If you're filling up huge page frames, things look a lot better.

>
>    
>>>>> Sure, some workloads simply won't trigger fragmentation problems.
>>>>> Others will.
>>>>>            
>>>> Some workloads benefit from readahead.  Some don't.  In fact,
>>>> readahead has a higher potential to reduce performance.
>>>>
>>>> Same as with many other optimizations.
>>>>          
>>> Do you see any difference with your examples and this issue?
>>>        
>> Memory layout is more persistent.  Well, disk layout is even more
>> persistent.  Still we do extents, and if our disk is fragmented, we
>> take the hit.
>>      
> Sure, and that's not a good thing either.
>    

And yet we live with it for decades; and we use more or less the same 
techniques to avoid it.


>> inodes come with dcache, yes.  I thought buffer heads are now a much
>> smaller load.  vmas usually don't scale up with memory.  If you have
>> a lot of radix tree nodes, then you also have a lot of pagecache, so
>> the radix tree nodes can be contained.  Open files also don't scale
>> with memory.
>>      
> See above; we don't need to fill all memory, especially with higher
> order allocations.
>    

Not if you allocate carefully.

> Definitely some workloads that never use much kernel memory will
> probably not see fragmentation problems.
>
>    

Right; and on a 16-64GB machine you'll have a hard time filling kernel 
memory with objects.

>>> Like I said, you don't need to fill all memory with dentries, you
>>> just need to be allocating higher order kernel memory and end up
>>> fragmenting your reclaimable pools.
>>>        
>> Allocate those higher order pages from the same huge frame.
>>      
> We don't keep different pools of different frame sizes around
> to allocate different object sizes in. That would get even weirder
> than the existing anti-frag stuff with overflow and fallback rules.
>    

Maybe we should, once we start to use a lot of such objects.

Once you have 10MB worth of inodes, you don't lose anything by 
allocating their slabs from 2MB units.

>> A few thousand sockets and open files is chickenfeed for a server.
>> They'll kill a few huge frames but won't significantly affect the
>> rest of memory.
>>      
> Lots of small files is very common for a web server for example.
>    

10k files? 100k files?  how many open at once?

Even 1M files is ~1GB, not touching our 64GB server.

Most content is dynamic these days anyway.

>> Containers are wonderful but still a future thing, and even when
>> fully implemented they still don't offer the same isolation as
>> virtualization.  For example, the owner of workload A might want to
>> upgrade the kernel to fix a bug he's hitting, while the owner of
>> workload B needs three months to test it.
>>      
> But better for performance in general.
>
>    

True.  But virtualization has the advantage of actually being there.

Note that kvm is also benefiting from containers to improve resource 
isolation.

>> Everything has to be evaluated on the basis of its generality, the
>> benefit, the importance of the subsystem that needs it, and impact
>> on the code.  Huge pages are already used in server loads so they're
>> not specific to kvm.  The benefit, 5-15%, is significant.  You and
>> Linus might not be interested in virtualization, but a significant
>> and growing fraction of hosts are virtualized, it's up to us if they
>> run Linux or something else.  And I trust Andrea and the reviewers
>> here to keep the code impact sane.
>>      
> I'm being realistic. I know sure it is just to be evaluated based
> on gains, complexity, alternatives, etc.
>
> When I hear arguments like we must do this because memory to cache
> ratio has got 100 times worse and ergo we're on the brink of
> catastrophe, that's when things get silly.
>    

That wasn't me.  It's 5-15%, not earth shattering, but significant.  
Especially when we hear things like 1% performance regression per kernel 
release on average.

And it's true that the gain will grow as machines grow.

>>> But if it is possible for KVM to use libhugetlb with just a bit of
>>> support from the kernel, then it goes some way to reducing the
>>> need for transparent hugepages.
>>>        
>> kvm already works with hugetlbfs.  But it's brittle, it means we
>> have to choose between performance and overcommit.
>>      
> Overcommit because it doesn't work with swapping? Or something more?
>    

kvm overcommit uses ballooning, page merging, and swapping.  None of 
these work well with large pages (well, ballooning might).

>> pages are passed around everywhere as well.  When something is
>> locked or its reference count doesn't match the reachable pointer
>> count, you give up.  Only a small number of objects are in active
>> use at any one time.
>>      
> Easier said than done, I suspect.
>    

No doubt it's very tricky code.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
