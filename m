Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A3DA6B01FE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 09:23:26 -0400 (EDT)
Message-ID: <4BBB359D.1020603@redhat.com>
Date: Tue, 06 Apr 2010 16:22:37 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <4BBB052D.8040307@redhat.com> <4BBB2134.9090301@redhat.com> <20100406131024.GA5288@laptop>
In-Reply-To: <20100406131024.GA5288@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/06/2010 04:10 PM, Nick Piggin wrote:
> On Tue, Apr 06, 2010 at 02:55:32PM +0300, Avi Kivity wrote:
>    
>> On 04/06/2010 12:55 PM, Avi Kivity wrote:
>>      
>>> Here is a microbenchmark demonstrating the hit (non-virtualized);
>>> it simulates a pointer-chasing application with a varying working
>>> set.  It is easy to see when the working set overflows the various
>>> caches, and later when the page tables overflow the caches.  For
>>> virtualization the hit will be a factor of 3 instead of 2, and
>>> will come earlier since the page tables are bigger.
>>>
>>>        
>> And here is the same thing with guest latencies as well:
>>
>> Random memory read latency, in nanoseconds, according to working
>> set and page size.
>>
>>
>>         ------- host ------  ------------- guest -----------
>>                              --- hpage=4k ---  -- hpage=2M -
>>
>>   size        4k         2M     4k/4k   2M/4k   4k/2M  2M/2M
>>     4k       4.9        4.9       5.0     4.9     4.9    4.9
>>    16k       4.9        4.9       5.0     4.9     5.0    4.9
>>    64k       7.6        7.6       7.9     7.8     7.8    7.8
>>   256k      15.1        8.1      15.9    10.3    15.4    9.0
>>     1M      28.5       23.9      29.3    37.9    29.3   24.6
>>     4M      31.8       25.3      37.5    42.6    35.5   26.0
>>    16M      94.8       79.0     110.7   107.3    92.0   77.3
>>    64M     260.9      224.2     294.2   247.8   251.5  207.2
>>   256M     269.8      248.8     313.9   253.1   260.1  230.3
>>     1G     278.1      246.3     331.8   273.0   269.9  236.7
>>     4G     330.9      252.6     545.6   346.0   341.6  256.5
>>    16G     436.3      243.8     705.2   458.3   463.9  268.8
>>    64G     486.0      253.3     767.3   532.5   516.9  274.7
>>
>>
>> It's easy to see how cache effects dominate the tlb walk.  The only
>> way hardware can reduce this is by increasing cache sizes
>> dramatically.
>>      
> Well this is the best attainable speedup in a corner case where the
> whole memory hierarchy is being actively defeated. The numbers are
> not surprising.

Of course this shows the absolute worst case and will never show up 
directly in any real workload.  The point wasn't that we expect a 3x 
speedup from large pages (far from it), but to show the problem is due 
to page tables overflowing the cache, not to any miss handler 
inefficiency.  It also shows that virtualization only increases the 
impact, but isn't the direct cause.  The real problem is large active 
working sets.

> Actual workloads are infinitely more useful. And in
> most cases, quite possibly hardware improvements like asids will
> be more useful.
>    

This already has ASIDs for the guest; and for the host they wouldn't 
help much since there's only one process running.  I don't see how 
hardware improvements can drastically change the numbers above, it's 
clear that for the 4k case the host takes a cache miss for the pte, and 
twice for the 4k/4k guest case.

> I don't really agree with how virtualization problem is characterised.
> Xen's way of doing memory virtualization maps directly to normal
> hardware page tables so there doesn't seem like a fundamental
> requirement for more memory accesses.
>    

The Xen pv case only works for modified guests (so no Windows), and 
doesn't support host memory management like swapping or ksm.  Xen hvm 
(which runs unmodified guests) has the same problems as kvm.

Note kvm can use a single layer of translation (and does on older 
hardware), so it would behave like the host, but that increases the cost 
of pte updates dramatically.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
