Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id E02FB6B0036
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 20:31:08 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id j5so5995495qga.4
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 17:31:08 -0800 (PST)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id l40si9396857qga.107.2014.02.17.17.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 17:31:08 -0800 (PST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 17 Feb 2014 20:31:08 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E464A38C8045
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 20:31:05 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I1V5Jm6029658
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 01:31:05 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I1V5PG012410
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 20:31:05 -0500
Date: Mon, 17 Feb 2014 17:31:00 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-ID: <20140218013100.GA31998@linux.vnet.ibm.com>
References: <52FC6F2A.30905@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
 <52FC98A6.1000701@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
 <20140214001438.GB1651@linux.vnet.ibm.com>
 <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
 <20140214043235.GA21999@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402140244330.12099@chino.kir.corp.google.com>
 <20140217192803.GA14586@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402171501001.25724@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402171501001.25724@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 17.02.2014 [15:14:06 -0800], David Rientjes wrote:
> On Mon, 17 Feb 2014, Nishanth Aravamudan wrote:
> 
> > Here is what I'm running into now:
> > 
> > setup_arch ->
> > 	do_init_bootmem ->
> > 		cpu_numa_callback ->
> > 			numa_setup_cpu ->
> > 				map_cpu_to_node -> 
> > 					update_numa_cpu_lookup_table
> > 
> > Which current updates the powerpc specific numa_cpu_lookup_table. I
> > would like to update that function to use set_cpu_numa_node() and
> > set_cpu_numa_mem(), but local_memory_node() is not yet functional
> > because build_all_zonelists is called later in start_kernel. Would it
> > make sense for first_zones_zonelist() to return NUMA_NO_NODE if we
> > don't have a zone?
> > 
> 
> Hmm, I don't think we'll want to modify the generic first_zones_zonelist() 
> for a special case that is only true during boot.  Instead, would it make 
> sense to modify numa_setup_cpu() to use the generic cpu_to_node() instead 
> of using a powerpc mapping and then do the set_cpu_numa_mem() after 
> paging_init() when the zonelists will have been built and zones without 
> present pages are properly excluded?

Sorry, I was unclear in my e-mail. I meant to modify
local_memory_node(), not first_zones_zonelist(). Well, it only needs the
following, I think?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3758a0..5de4337 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3650,6 +3650,8 @@ int local_memory_node(int node)
                                   gfp_zone(GFP_KERNEL),
                                   NULL,
                                   &zone);
+       if (!zone)
+               return NUMA_NO_NODE;
        return zone->node;
 }
 #endif

I think that condition should only happen during boot -- maybe even
deserving of an unlikely, but I don't think the above is considered a
hot-path. If the above isn't palatable, I can look into your suggestion
instead.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
