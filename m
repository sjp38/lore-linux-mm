Date: Sat, 6 Sep 2008 16:33:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080906143318.GA23621@elte.hu>
References: <20080905215452.GF11692@us.ibm.com> <20080906000154.GC18288@one.firstfloor.org> <20080906153855.7260.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080906153855.7260.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

* Yasunori Goto <y-goto@jp.fujitsu.com> wrote:

> I don't think its driver is almighty. IIRC, balloon driver can be 
> cause of fragmentation for 24-7 system.
> 
> In addition, I have heard that memory hotplug would be useful for 
> reducing of power consumption of DIMM.
> 
> I have to admit that memory hotplug has many issues, but I would like 
> to solve them step by step.

What would be nice is to insert the information both during bootup and 
in /proc/meminfo and 'free' output that hot-removable memory segments 
are not generic free memory, it's currently a limited resource that 
might or might not be sufficient to serve a given workload.

Perhaps even exclude it from 'total' memory reported by meminfo - to be 
on the safe side of user expectations. In terms of user-space memory it 
is already generic swappable memory but in terms of kernel-space 
allocations it is not.

As i said it earlier in the thread, i certainly have no objections from 
the x86 maintenance side - nothing is worse than a generic kernel 
feature only available on certain less frequently used platforms. Memory 
hotplug has been available for some time in the MM and it's not really 
causing any maintenance trouble at the moment and it is not enabled by 
default either.

Having said that, i have my doubts about its generic utility (the power 
saving aspects are likely not realizable - nobody really wants DIMMs to 
just sit there unused and the cost of dynamic migration is just 
horrendous) - but as long as it's opt-in there's no reason to limit the 
availability of an in-kernel feature artificially.

Removing those limitations of kernel-space allocations should indeed be 
done in baby steps - and whether it's worth turning such memory into 
completely generic kernel memory is an open question.

But the fact that a piece of memory is not fully generic is no reason 
not to allow users to create special, capability-limited RAM resources 
like they can already do via hugetlbfs or ramfs, as long as the the 
capability limitations are advertised clearly.

Yes, memory hotplug has limitations we all understand, but still it's an 
arguably useful feature in some circumstances. If we never give a 
feature a chance to evolve on the main Linux platform that 90%+ of our 
users use it wont ever be truly useful.

Please send the new patches against -git or -tip and we can put them 
into a separate standalone feature topic and can test it on various x86 
boxes and send them towards linux-next if Andrew agrees with that 
process too.

Btw., it would be nice if memory hotplug had a self-test that could be 
activated from the .config and would run autonomously (a bit like 
rcu-torture): it would mark say 10% of all RAM as hot-pluggable during 
bootup and would periodically hot-plug and hot-unplug that memory, every 
10 seconds or 30 seconds or so, transparently. That would also test the 
x86 architecture's pagetable init code, the page migration code, etc. 
(Disabled by default and dependent on DEBUG_KERNEL && EXPERIMENTAL.)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
