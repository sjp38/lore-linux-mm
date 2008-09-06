From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <9031244.1220716855172.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 7 Sep 2008 01:00:55 +0900 (JST)
Subject: Re: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
In-Reply-To: <20080906143318.GA23621@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080906143318.GA23621@elte.hu>
 <20080905215452.GF11692@us.ibm.com> <20080906000154.GC18288@one.firstfloor.org> <20080906153855.7260.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>* Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
>> I don't think its driver is almighty. IIRC, balloon driver can be 
>> cause of fragmentation for 24-7 system.
>> 
>> In addition, I have heard that memory hotplug would be useful for 
>> reducing of power consumption of DIMM.
>> 
>> I have to admit that memory hotplug has many issues, but I would like 
>> to solve them step by step.
>
>What would be nice is to insert the information both during bootup and 
>in /proc/meminfo and 'free' output that hot-removable memory segments 
>are not generic free memory, it's currently a limited resource that 
>might or might not be sufficient to serve a given workload.
>
>Perhaps even exclude it from 'total' memory reported by meminfo - to be 
>on the safe side of user expectations. In terms of user-space memory it 
>is already generic swappable memory but in terms of kernel-space 
>allocations it is not.
>
I wonder why anyone doesn't talk about ZONE_MOVABLE...When I wrote memory
hotplug, I assumed help of ZONE_MOVABLE and SPARSEMEM. It is shown in
meminfo.(I think memory hotplug is useful only when ZONE_MOVABLE is used.)

Most of problems which Goto wrote are mainly about placement of memmap and 
pgdat, zones. One example is that "when SPARSEMEM_VMEMMAP is enabled,
memmap is not removed even when memory is removed. "


>As i said it earlier in the thread, i certainly have no objections from 
>the x86 maintenance side - nothing is worse than a generic kernel 
>feature only available on certain less frequently used platforms. Memory 
>hotplug has been available for some time in the MM and it's not really 
>causing any maintenance trouble at the moment and it is not enabled by 
>default either.
>
>Having said that, i have my doubts about its generic utility (the power 
>saving aspects are likely not realizable - nobody really wants DIMMs to 
>just sit there unused and the cost of dynamic migration is just 
>horrendous) - but as long as it's opt-in there's no reason to limit the 
>availability of an in-kernel feature artificially.

Nobody ? maybe just a trade-off problem in user side. 
Even without DIMM hotplug or DIMM's power save mode, making a DIMM idle
is of no use ? I think memory consumes much power when it used.
Memory Hotplug and ZONE_MOVABLE can make some memory idle.
(I'm sorry if my thinking is wrong.)

>
>Removing those limitations of kernel-space allocations should indeed be 
>done in baby steps - and whether it's worth turning such memory into 
>completely generic kernel memory is an open question.
>
I think generic kernel space memory hotplug will never be available.

>But the fact that a piece of memory is not fully generic is no reason 
>not to allow users to create special, capability-limited RAM resources 
>like they can already do via hugetlbfs or ramfs, as long as the the 
>capability limitations are advertised clearly.
>
Hmm, adding a feature like 
 - offline some memory at boot.
 - online-memory-as-hugeltb mode
  
is useful for generic pc users ?

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
