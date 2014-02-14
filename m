Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 900786B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 05:54:10 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so12240393pbc.28
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 02:54:10 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id tq3si5338341pab.299.2014.02.14.02.54.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 02:54:09 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so12105671pab.32
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 02:54:09 -0800 (PST)
Date: Fri, 14 Feb 2014 02:54:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <20140214043235.GA21999@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402140244330.12099@chino.kir.corp.google.com>
References: <52F88C16.70204@linux.vnet.ibm.com> <alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com> <52F8C556.6090006@linux.vnet.ibm.com> <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com> <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com> <52FC98A6.1000701@linux.vnet.ibm.com> <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com> <20140214001438.GB1651@linux.vnet.ibm.com> <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
 <20140214043235.GA21999@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 13 Feb 2014, Nishanth Aravamudan wrote:

> There is an open issue on powerpc with memoryless nodes (inasmuch as we
> can have them, but the kernel doesn't support it properly). There is a
> separate discussion going on on linuxppc-dev about what is necessary for
> CONFIG_HAVE_MEMORYLESS_NODES to be supported.
> 

Yeah, and this is causing problems with the slub allocator as well.

> Apologies for hijacking the thread, my comments below were purely about
> the memoryless node support, not about readahead specifically.
> 

Neither you nor Raghavendra have any reason to apologize to anybody.  
Memoryless node support on powerpc isn't working very well right now and 
you're trying to fix it, that fix is needed both in this thread and in 
your fixes for slub.  It's great to see both of you working hard on your 
platform to make it work the best.

I think what you'll need to do in addition to your 
CONFIG_HAVE_MEMORYLESS_NODE fix, which is obviously needed, is to enable 
CONFIG_USE_PERCPU_NUMA_NODE_ID for the same NUMA configurations and then 
use set_numa_node() or set_cpu_numa_node() to properly store the mapping 
between cpu and node rather than numa_cpu_lookup_table.  Then you should 
be able to do away with your own implementation of cpu_to_node().

After that, I think it should be as simple as doing

	set_numa_node(cpu_to_node(cpu));
	set_numa_mem(local_memory_node(cpu_to_node(cpu)));

probably before taking vector_lock in smp_callin().  The cpu-to-node 
mapping should be done much earlier in boot while the nodes are being 
initialized, I don't think there should be any problem there.

While you're at it, I think you'll also want to add a comment that
setting up the cpu sibling mask must be done before the smp_wmb() before 
notify_cpu_starting(cpu), it's crucial to have before the cpu is brought 
online and why we need the store memory barrier.

But, again, please don't apologize for developing your architecture and 
attacking bugs as they arise, it's very admirable and I'm happy to help in 
any way that I can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
