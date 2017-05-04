Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3D5D6B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 01:27:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f5so2648451pff.13
        for <linux-mm@kvack.org>; Wed, 03 May 2017 22:27:05 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m22si1058110pgd.223.2017.05.03.22.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 22:27:04 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so714385pgc.0
        for <linux-mm@kvack.org>; Wed, 03 May 2017 22:27:04 -0700 (PDT)
Message-ID: <1493875615.7934.1.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 04 May 2017 15:26:55 +1000
In-Reply-To: <20170502143608.GM14593@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Tue, 2017-05-02 at 16:36 +0200, Michal Hocko wrote:
> On Wed 19-04-17 17:52:38, Balbir Singh wrote:
> > This is a request for comments on the discussed approaches
> > for coherent memory at mm-summit (some of the details are at
> > https://lwn.net/Articles/717601/). The latest posted patch
> > series is at https://lwn.net/Articles/713035/. I am reposting
> > this as RFC, Michal Hocko suggested using HMM for CDM, but
> > we believe there are stronger reasons to use the NUMA approach.
> > The earlier patches for Coherent Device memory were implemented
> > and designed by Anshuman Khandual.
> > 
> > Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
> > The patches do a great deal to enable CDM with HMM, but we
> > still believe that HMM with CDM is not a natural way to
> > represent coherent device memory and the mm will need
> > to be audited and enhanced for it to even work.
> > 
> > With HMM we'll see ZONE_DEVICE pages mapped into
> > user space and that would mean a thorough audit of all code
> > paths to make sure we are ready for such a use case and enabling
> > those use cases, like with HMM CDM patch 1, which changes
> > move_pages() and migration paths. I've done a quick
> > evaluation to check for features and found limitationd around
> > features like migration (page cache
> > migration), fault handling to the right location
> > (direct page cache allocation in the coherent memory), mlock
> > handling, RSS accounting, memcg enforcement for pages not on LRU, etc.
> 
> Are those problems not viable to solve?

Yes, except IIUC the direct page cache allocation one. The reason for calling
them out is to make aware that HMM CDM would require new mm changes/audit
to support ZONE_DEVICE pages across several parts of the mm subsystem.

> 
> [...]
> > Introduction
> > 
> > CDM device memory is cache coherent with system memory and we would like
> > this to show up as a NUMA node, however there are certain algorithms
> > that might not be currently suitable for N_COHERENT_MEMORY
> > 
> > 1. AutoNUMA balancing
> 
> OK, I can see a reason for that but theoretically the same applies to
> cpu less numa nodes in general, no?


That is correct. Christoph has shown some interest in isolating some
algorithms as well. I have some ideas that I can send out later.

> 
> > 2. kswapd reclaim
> 
> How is the memory reclaim handled then? How are users expected to handle
> OOM situation?
> 

1. The fallback node list for coherent memory includes regular memory
   nodes
2. Direct reclaim works, I've tested it

> > The reason for exposing this device memory as NUMA is to simplify
> > the programming model, where memory allocation via malloc() or
> > mmap() for example would seamlessly work across both kinds of
> > memory. Since we expect the size of device memory to be smaller
> > than system RAM, we would like to control the allocation of such
> > memory. The proposed mechanism reuses nodemasks and explicit
> > specification of the coherent node in the nodemask for allocation
> > from device memory. This implementation also allows for kernel
> > level allocation via __GFP_THISNODE and existing techniques
> > such as page migration to work.
> 
> so it basically resembles isol_cpus except for memory, right. I believe
> scheduler people are more than unhappy about this interface...
>

isol_cpus were for an era when timer/interrupts and other scheduler
infrastructure present today was not around, but I don't mean to digress.
 
> Anyway, I consider CPUless nodes a dirty hack (especially when I see
> them mostly used with poorly configured LPARs where no CPUs are left for
> a particular memory).  Now this is trying to extend this concept even
> further to a memory which is not reclaimable by the kernel and requires

Direct reclaim still works

> an explicit and cooperative memory reclaim from userspace. How is this
> going to work? The memory also has a different reliability properties
> from RAM which user space doesn't have any clue about from the NUMA
> properties exported. Or am I misunderstanding it? That all sounds quite
> scary to me.
> 
> I very much agree with the last email from Mel and I would really like
> to see how would a real application benefit from these nodes.
>

I see two use cases

1. Aware application/library - allocates from this node and uses this memory
2. Unaware application/library - allocates memory anywhere, but does not use
CDM memory by default, since it is isolated.

Both 1 and 2 can work together and an aware application can use an unaware
library and if required migrate pages between the two. Both 1 and 2
can access each others memory due to coherency, so the final application
level use case is similar to HMM. That is why HMM-CDM and NUMA-CDM are
both equivalent from an application programming model perspective,
except for the limitations mentioned above.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
