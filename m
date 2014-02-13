Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A91F66B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 17:41:07 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so2415194pdb.23
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:41:07 -0800 (PST)
Received: from mail-pb0-x22b.google.com (mail-pb0-x22b.google.com [2607:f8b0:400e:c01::22b])
        by mx.google.com with ESMTPS id r7si3482175pbk.57.2014.02.13.14.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 14:41:06 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id md12so11465728pbc.30
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 14:41:06 -0800 (PST)
Date: Thu, 13 Feb 2014 14:41:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <52FC98A6.1000701@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140206145105.27dec37b16f24e4ac5fd90ce@linux-foundation.org> <alpine.DEB.2.02.1402061456290.31828@chino.kir.corp.google.com> <20140206152219.45c2039e5092c8ea1c31fd38@linux-foundation.org>
 <alpine.DEB.2.02.1402061537180.3441@chino.kir.corp.google.com> <alpine.DEB.2.02.1402061557210.5061@chino.kir.corp.google.com> <52F4B8A4.70405@linux.vnet.ibm.com> <alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com> <52F88C16.70204@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com> <52F8C556.6090006@linux.vnet.ibm.com> <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com> <52FC6F2A.30905@linux.vnet.ibm.com> <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <52FC98A6.1000701@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 13 Feb 2014, Raghavendra K T wrote:

> Thanks David, unfortunately even after applying that patch, I do not see
> the improvement.
> 
> Interestingly numa_mem_id() seem to still return the value of a
> memoryless node.
> May be  per cpu _numa_mem_ values are not set properly. Need to dig out ....
> 

I believe ppc will be relying on __build_all_zonelists() to set 
numa_mem_id() to be the proper node, and that relies on the ordering of 
the zonelist built for the memoryless node.  It would be very strange if 
local_memory_node() is returning a memoryless node because it is the first 
zone for node_zonelist(GFP_KERNEL) (why would a memoryless node be on the 
zonelist at all?).

I think the real problem is that build_all_zonelists() is only called at 
init when the boot cpu is online so it's only setting numa_mem_id() 
properly for the boot cpu.  Does it return a node with memory if you 
toggle /proc/sys/vm/numa_zonelist_order?  Do

	echo node > /proc/sys/vm/numa_zonelist_order
	echo zone > /proc/sys/vm/numa_zonelist_order
	echo default > /proc/sys/vm/numa_zonelist_order

and check if it returns the proper value at either point.  This will force 
build_all_zonelists() and numa_mem_id() to point to the proper node since 
all cpus are now online.

So the prerequisite for CONFIG_HAVE_MEMORYLESS_NODES is that there is an 
arch-specific set_numa_mem() that makes this mapping correct like ia64 
does.  If that's the case, then it's (1) completely undocumented and (2) 
Nishanth's patch is incomplete because anything that adds 
CONFIG_HAVE_MEMORYLESS_NODES needs to do the proper set_numa_mem() for it 
to be any different than numa_node_id().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
