Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id D2E186B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 00:47:33 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id w8so17779330qac.28
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 21:47:33 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id b4si946407qch.50.2014.02.13.21.47.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 21:47:33 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 14 Feb 2014 00:47:33 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1E604C9003E
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 00:47:28 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1E5lVe92031990
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:47:31 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1E5lUfo027891
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 00:47:30 -0500
Date: Thu, 13 Feb 2014 21:47:24 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140214054724.GA24329@linux.vnet.ibm.com>
References: <52F4B8A4.70405@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
 <52F88C16.70204@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
 <52F8C556.6090006@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
 <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <52FC98A6.1000701@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 13.02.2014 [14:41:04 -0800], David Rientjes wrote:
> On Thu, 13 Feb 2014, Raghavendra K T wrote:
> 
> > Thanks David, unfortunately even after applying that patch, I do not see
> > the improvement.
> > 
> > Interestingly numa_mem_id() seem to still return the value of a
> > memoryless node.
> > May be  per cpu _numa_mem_ values are not set properly. Need to dig out ....
> > 
> 
> I believe ppc will be relying on __build_all_zonelists() to set 
> numa_mem_id() to be the proper node, and that relies on the ordering of 
> the zonelist built for the memoryless node.  It would be very strange if 
> local_memory_node() is returning a memoryless node because it is the first 
> zone for node_zonelist(GFP_KERNEL) (why would a memoryless node be on the 
> zonelist at all?).
> 
> I think the real problem is that build_all_zonelists() is only called at 
> init when the boot cpu is online so it's only setting numa_mem_id() 
> properly for the boot cpu.  Does it return a node with memory if you 
> toggle /proc/sys/vm/numa_zonelist_order?  Do
> 
> 	echo node > /proc/sys/vm/numa_zonelist_order
> 	echo zone > /proc/sys/vm/numa_zonelist_order
> 	echo default > /proc/sys/vm/numa_zonelist_order
> 
> and check if it returns the proper value at either point.  This will force 
> build_all_zonelists() and numa_mem_id() to point to the proper node since 
> all cpus are now online.

Yep, after massaging the code to allow CONFIG_USE_PERCPU_NUMA_NODE_ID,
you're right that the memory node is wrong. The cpu node is right (they
are all on node 0), but that could be lucky. The memory node is right
for the boot cpu. I did notice that some CPUs now think the cpu node is
1, which is wrong.

> So the prerequisite for CONFIG_HAVE_MEMORYLESS_NODES is that there is an 
> arch-specific set_numa_mem() that makes this mapping correct like ia64 
> does.  If that's the case, then it's (1) completely undocumented and (2) 
> Nishanth's patch is incomplete because anything that adds 
> CONFIG_HAVE_MEMORYLESS_NODES needs to do the proper set_numa_mem() for it 
> to be any different than numa_node_id().

I'll work on getting the set_numa_mem() and set_numa_node() correct for
powerpc.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
