Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E6A7D6B01F1
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 05:04:01 -0400 (EDT)
Message-ID: <4BC2E1D6.9040702@redhat.com>
Date: Mon, 12 Apr 2010 12:03:18 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu> <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu> <20100412060931.GP5683@laptop> <4BC2BF67.80903@redhat.com> <20100412071525.GR5683@laptop> <4BC2CF8C.5090108@redhat.com> <20100412082844.GU5683@laptop>
In-Reply-To: <20100412082844.GU5683@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 11:28 AM, Nick Piggin wrote:
>
>> We use the "try" tactic extensively.  So long as there's a
>> reasonable chance of success, and a reasonable fallback on failure,
>> it's fine.
>>
>> Do you think we won't have reasonable success rates?  Why?
>>      
> After the memory is fragmented? It's more or less irriversable. So
> success rates (to fill a specific number of huges pages) will be fine
> up to a point. Then it will be a continual failure.
>    

So we get just a part of the win, not all of it.

> Sure, some workloads simply won't trigger fragmentation problems.
> Others will.
>    

Some workloads benefit from readahead.  Some don't.  In fact, readahead 
has a higher potential to reduce performance.

Same as with many other optimizations.

>> Why?  If you can isolate all the pointers into the dentry, allocate
>> the new dentry, make the old one point into the new one, hash it,
>> move the pointers, drop the old dentry.
>>
>> Difficult, yes, but insane?
>>      
> Yes.
>    

Well, I'll accept what you say since I'm nowhere near as familiar with 
the code.  But maybe someone insane will come along and do it.

>> Caches have statistical performance.  In the long run they average
>> out.  In the short run they can behave badly.  Same thing with large
>> pages, except the runs are longer and the wins are smaller.
>>      
> You don't understand. Caches don't suddenly or slowly stop working.
> For a particular pattern of workload, they statistically pretty much
> work the same all the time.
>    

Yet your effective cache size can be reduced by unhappy aliasing of 
physical pages in your working set.  It's unlikely but it can happen.

For a statistical mix of workloads, huge pages will also work just 
fine.  Perhaps not all of them, but most (those that don't fill _all_ of 
memory with dentries).

>> Database are the easiest case, they allocate memory up front and
>> don't give it up.  We'll coalesce their memory immediately and
>> they'll run happily ever after.
>>      
> Again, you're thinking about a benchmark setup. If you've got various
> admin things, backups, scripts running, probably web servers,
> application servers etc. Then it's not all that simple.
>    

These are all anonymous/pagecache loads, which we deal with well.

> And yes, Linux works pretty well for a multi-workload platform. You
> might be thinking too much about virtualization where you put things
> in sterile little boxes and take the performance hit.
>
>    

People do it for a reason.

>> Virtualization will fragment on overcommit, but the load is all
>> anonymous memory, so it's easy to defragment.  Very little dcache on
>> the host.
>>      
> If virtualization is the main worry (which it seems that it is
> seeing as your TLB misses cost like 6 times more cachelines),
>    

(just 2x)

> then complexity should be pushed into the hypervisor, not the
> core kernel.
>    

The whole point behind kvm is to reuse the Linux core.  If we have to 
reimplement Linux memory management and scheduling, then it's a failure.

>> Well, I'm not against it, but that would be a much more intrusive
>> change than what this thread is about.  Also, you'd need 4K dentries
>> etc, no?
>>      
> No. You'd just be defragmenting 4K worth of dentries at a time.
> Dentries (and anything that doesn't care about untranslated KVA)
> are trivial. Zero change for users of the code.
>    

I see.

> This is going off-topic though, I don't want to hijack the thread
> with talk of nonlinear kernel.
>    

Too bad, it's interesting.

>> Mostly we need a way of identifying pointers into a data structure,
>> like rmap (after all that's what makes transparent hugepages work).
>>      
> And that involves auditing and rewriting anything that allocates
> and pins kernel memory. It's not only dentries.
>    

Not everything, just the major users that can scale with the amount of 
memory in the machine.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
