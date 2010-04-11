Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 05CA16B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:25:34 -0400 (EDT)
Message-ID: <4BC1BF93.60807@redhat.com>
Date: Sun, 11 Apr 2010 15:24:51 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu> <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu> <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu>
In-Reply-To: <20100411120800.GC10952@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 03:08 PM, Ingo Molnar wrote:
>
>> No one is insisting the patches aren't intrusive.  We're insisting they
>> bring a real benefit.  I think Linus' main objection was that hugetlb
>> wouldn't work due to fragmentation, and I think we've demonstrated that
>> antifrag/compaction do allow hugetlb to work even during a fragmenting
>> workload running in parallel.
>>      
> As i understood it i think Linus had three main objections:
>
>   1- the improvements were only shown in specialistic environments
>      (virtualization, servers)
>    

Servers are not specialized workloads, and neither is virtualization.  
If we have to justify everything based on the desktop experience we'd 
have no 4096 core support, fibre channel and 10GbE drivers, a zillion 
architectures etc.

>   2- complexity
>    

No arguing with that.

> The important thing to realize is that the working set of the 'desktop' is
> _not_ independent of RAM size: it just fills up RAM to the 'typical average
> RAM size'. That is around 2 GB today. In 5-10 years it will be at 16 GB.
>
> Applications will just bloat up to that natural size. They'll use finer
> default resolutions, larger internal caches, etc. etc.
>    

Well, if this happens we'll be ready.

>> 'git grep' is a pagecache workload, not anonymous memory, so it shouldn't
>> see any improvement. [...]
>>      
> Indeed, git grep is read() based.
>    

Right.

>> [...]  I imagine git will see a nice speedup if we get hugetlb for
>> pagecache, at least for read-only workloads that don't hash all the time.
>>      
> Shouldnt that already be the case today? The pagecache is in the kernel where
> we have things 2MB mapped. Git read()s it into the same [small] buffer again
> and again, so the only 'wide' address space access it does is within the
> kernel, to the 2MB mapped pagecache pages.
>    

If you 'git grep pattern $commit' instead, you'll be reading out of 
mmap()ed git packs.  Much of git memory access goes through that.  To 
get the benefit of hugetlb there, we'd need to run khugepaged on 
pagecache, and align file vmas on 2MB boundaries.

We'll also get executables and shared objects mapped via large pages 
this way, the ELF ABI is already set up to align sections on 2MB boundaries.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
