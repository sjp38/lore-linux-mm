Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B053A6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 09:23:29 -0500 (EST)
Message-ID: <51277F5A.9080807@hp.com>
Date: Fri, 22 Feb 2013 09:23:22 -0500
From: Don Morris <don.morris@hp.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC][ATTEND] Handling NUMA layout changes at runtime
References: <20130221194733.GA3778@negative>
In-Reply-To: <20130221194733.GA3778@negative>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, David Hansen <dave@linux.vnet.ibm.com>

On 02/21/2013 02:47 PM, Cody P Schafer wrote:
> Yes, this is late. Sorry.
> 
> I'd like to discuss the following topic:

I'd be interested in discussing this as well (no code at the moment,
but I at the least I could contribute experiences on how the HP-UX
memory management system handles this if invited).

Thanks,
Don Morris

> 
> --
> 
> Presently, NUMA layout is determined at boot time and never changes again.
> This setup works for real hardware, but virtual machines are more dynamic:
> they could be migrated between different hosts, and have to share the physical
> memory space with other VMs which are also being moved around or shut down
> while other new VMs are started up. As a result, the physical backing memory
> that a VM had when it started up changes at runtime.
> 
> Problems to be overcome:
> 
> 	- How should userspace be notified? Do we need new interfaces so
> 	  applications can query memory to see if it was affected?
> 
> 	- Can we make the NUMA layout initialization generic? This also
> 	  implies that all initialization of struct zone/struct
> 	  page/NODE_DATA() would be made (somewhat) generic.
> 
> 	- Some one-time allocations now will know they are on a non-optimal
> 	  node.
> 
> 	- hotpluged per node data is (in general) not being allocated optimally)
> 
> 		- NODE_DATA() for hotpluged nodes is allocated off-node (except for
> 		  ia64).
> 
> 		- SLUB's kmem_cache_node is always allocated off-node for
> 		  hotpluged nodes.
> 
> 	  [Not a new problem, but one that needs solving].
> 
> Some more generic NUMA layout/mm init things:
> 
> 	- boot-time and hotplug NUMA init don't share enough code.
> 
> 	- architectures do not share mm init code
> 
> 	- NUMA layout (from init) is kept (if it is kept at all) in only arch
> 	  specific ways. Memblock _happens_ to contain this info, while also
> 	  also tracking allocations, and every arch but powerpc discards it as
> 	  __init/__initdata)
> 
> A WIP patchset addressing initial reconfiguration of the page allocator:
> https://github.com/jmesmon/linux/tree/dnuma/v25
> 
> --
> Cody P Schafer
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
