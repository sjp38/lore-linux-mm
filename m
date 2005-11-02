Date: Wed, 2 Nov 2005 08:19:43 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051102071943.GA1574@elte.hu>
References: <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <43679C69.6050107@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43679C69.6050107@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

* Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> My own target is NUMA node hotplug, what NUMA node hotplug want is
> - [remove the range of memory] For this approach, admin should define
>   *core* node and removable node. Memory on removable node is removable.
>   Dividing area into removable and not-removable is needed, because
>   we cannot allocate any kernel's object on removable area.
>   Removable area should be 100% removable. Customer can know the limitation 
>   before using.

that's a perfectly fine method, and is quite similar to the 'separate 
zone' approach Nick mentioned too. It is also easily understandable for 
users/customers.

under such an approach, things become easier as well: if you have zones 
you can to restrict (no kernel pinned-down allocations, no mlock-ed 
pages, etc.), there's no need for any 'fragmentation avoidance' patches!  
Basically all of that RAM becomes instantly removable (with some small 
complications). That's the beauty of the separate-zones approach. It is 
also a limitation: no kernel allocations, so all the highmem-alike 
restrictions apply to it too.

but what is a dangerous fallacy is that we will be able to support hot 
memory unplug of generic kernel RAM in any reliable way!

you really have to look at this from the conceptual angle: 'can an 
approach ever lead to a satisfactory result'? If the answer is 'no', 
then we _must not_ add a 90% solution that we _know_ will never be a 
100% solution.

for the separate-removable-zones approach we see the end of the tunnel.  
Separate zones are well-understood.

generic unpluggable kernel RAM _will not work_.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
