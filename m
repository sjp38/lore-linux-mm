Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A52956B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:46:22 -0400 (EDT)
Message-ID: <4BC2CF8C.5090108@redhat.com>
Date: Mon, 12 Apr 2010 10:45:16 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu> <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu> <20100412060931.GP5683@laptop> <4BC2BF67.80903@redhat.com> <20100412071525.GR5683@laptop>
In-Reply-To: <20100412071525.GR5683@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 10:15 AM, Nick Piggin wrote:
>
>>> Another thing is that the problem
>>> of fragmentation breakdown is not just a one-shot event that fills
>>> memory with pinned objects. It is a slow degredation.
>>>
>>> Especially when you use something like SLUB as the memory allocator
>>> which requires higher order allocations for objects which are pinned
>>> in kernel memory.
>>>        
>> Won't the usual antifrag tactics apply?  Try to allocate those
>> objects from the same block.
>>      
> "try" is the key point.
>    

We use the "try" tactic extensively.  So long as there's a reasonable 
chance of success, and a reasonable fallback on failure, it's fine.

Do you think we won't have reasonable success rates?  Why?

>
>    
>>> Just running a few minutes of testing with a kernel compile in the
>>> background does not show the full picture. You really need a box that
>>> has been up for days running a proper workload before you are likely
>>> to see any breakdown.
>>>        
>> I'm sure we'll be able to generate worst-case scenarios.  I'm also
>> reasonably sure we'll be able to deal with them.  I hope we won't
>> need to, but it's even possible to move dentries around.
>>      
> Pinned dentries? (which are the problem) That would be insane.
>    

Why?  If you can isolate all the pointers into the dentry, allocate the 
new dentry, make the old one point into the new one, hash it, move the 
pointers, drop the old dentry.

Difficult, yes, but insane?

>>> I'm sure it's horrible for planning if the RDBMS or VM boxes gradually
>>> get slower after X days of uptime. It's better to have consistent
>>> performance really, for anything except pure benchmark setups.
>>>        
>> If that were the case we'd disable caches everywhere.  General
>>      
> No we wouldn't. You can have consistent, predictable performance with
> caches.
>    

Caches have statistical performance.  In the long run they average out.  
In the short run they can behave badly.  Same thing with large pages, 
except the runs are longer and the wins are smaller.

>> purpose computing is a best effort thing, we try to be fast on the
>> common case but we'll be slow on the uncommon case.  Access to a bit
>>      
> Sure. And the common case for production systems like VM or databse
> servers that are up for hundreds of days is when they are running with
> a lot of uptime. Common case is not a fresh reboot into a 3 hour
> benchmark setup.
>    

Database are the easiest case, they allocate memory up front and don't 
give it up.  We'll coalesce their memory immediately and they'll run 
happily ever after.

Virtualization will fragment on overcommit, but the load is all 
anonymous memory, so it's easy to defragment.  Very little dcache on the 
host.

>> Non-linear kernel mapping moves the small page problem from
>> userspace back to the kernel, a really unhappy solution.
>>      
> Not unhappy for userspace intensive workloads. And user working sets
> I'm sure are growing faster than kernel working set. Also there would
> be nothing against compacting and merging kernel memory into larger
> pages.
>    

Well, I'm not against it, but that would be a much more intrusive change 
than what this thread is about.  Also, you'd need 4K dentries etc, no?

>> Very large (object count, not object size) kernel caches can be
>> addressed by compacting them, but I hope we won't need to do that.
>>      
> You can't say that fragmentation is not a fundamental problem.  And
> adding things like indirect pointers or weird crap adding complexity
> to code that deals with KVA IMO is not acceptable. So you can't
> just assert that you can "address" the problem.
>    

Mostly we need a way of identifying pointers into a data structure, like 
rmap (after all that's what makes transparent hugepages work).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
