Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id C921E6B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 14:28:12 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id va2so17614205obc.29
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 11:28:12 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id eo3si10030758oeb.13.2014.02.17.11.28.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 11:28:11 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 17 Feb 2014 12:28:10 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1FF281FF003E
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 12:28:08 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1HJRc1C64618710
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 20:27:38 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1HJS7mv027954
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 12:28:07 -0700
Date: Mon, 17 Feb 2014 11:28:03 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140217192803.GA14586@linux.vnet.ibm.com>
References: <52F8C556.6090006@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
 <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <52FC98A6.1000701@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
 <20140214001438.GB1651@linux.vnet.ibm.com>
 <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
 <20140214043235.GA21999@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402140244330.12099@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402140244330.12099@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 14.02.2014 [02:54:06 -0800], David Rientjes wrote:
> On Thu, 13 Feb 2014, Nishanth Aravamudan wrote:
> 
> > There is an open issue on powerpc with memoryless nodes (inasmuch as we
> > can have them, but the kernel doesn't support it properly). There is a
> > separate discussion going on on linuxppc-dev about what is necessary for
> > CONFIG_HAVE_MEMORYLESS_NODES to be supported.
> > 
> 
> Yeah, and this is causing problems with the slub allocator as well.
> 
> > Apologies for hijacking the thread, my comments below were purely about
> > the memoryless node support, not about readahead specifically.
> > 
> 
> Neither you nor Raghavendra have any reason to apologize to anybody.  
> Memoryless node support on powerpc isn't working very well right now and 
> you're trying to fix it, that fix is needed both in this thread and in 
> your fixes for slub.  It's great to see both of you working hard on your 
> platform to make it work the best.
> 
> I think what you'll need to do in addition to your 
> CONFIG_HAVE_MEMORYLESS_NODE fix, which is obviously needed, is to enable 
> CONFIG_USE_PERCPU_NUMA_NODE_ID for the same NUMA configurations and then 
> use set_numa_node() or set_cpu_numa_node() to properly store the mapping 
> between cpu and node rather than numa_cpu_lookup_table.  Then you should 
> be able to do away with your own implementation of cpu_to_node().
> 
> After that, I think it should be as simple as doing
> 
> 	set_numa_node(cpu_to_node(cpu));
> 	set_numa_mem(local_memory_node(cpu_to_node(cpu)));
> 
> probably before taking vector_lock in smp_callin().  The cpu-to-node 
> mapping should be done much earlier in boot while the nodes are being 
> initialized, I don't think there should be any problem there.

vector_lock/smp_callin are ia64 specific things, I believe? I think the
equivalent is just in start_secondary() for powerpc? (which in fact is
what calls smp_callin on powerpc).

Here is what I'm running into now:

setup_arch ->
	do_init_bootmem ->
		cpu_numa_callback ->
			numa_setup_cpu ->
				map_cpu_to_node -> 
					update_numa_cpu_lookup_table

Which current updates the powerpc specific numa_cpu_lookup_table. I
would like to update that function to use set_cpu_numa_node() and
set_cpu_numa_mem(), but local_memory_node() is not yet functional
because build_all_zonelists is called later in start_kernel. Would it
make sense for first_zones_zonelist() to return NUMA_NO_NODE if we
don't have a zone?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
