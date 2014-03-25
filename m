Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id F15BF6B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:25:33 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so11617735igb.1
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:25:33 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id gb2si28726815igd.22.2014.03.25.11.25.32
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 11:25:33 -0700 (PDT)
Date: Tue, 25 Mar 2014 13:25:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
In-Reply-To: <20140325181010.GB29977@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1403251323030.26744@nuc>
References: <20140311210614.GB946@linux.vnet.ibm.com> <20140313170127.GE22247@linux.vnet.ibm.com> <20140324230550.GB18778@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251116490.16557@nuc> <20140325162303.GA29977@linux.vnet.ibm.com> <alpine.DEB.2.10.1403251152250.16870@nuc>
 <20140325181010.GB29977@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On Tue, 25 Mar 2014, Nishanth Aravamudan wrote:

> On power, very early, we find the 16G pages (gpages in the powerpc arch
> code) in the device-tree:
>
> early_setup ->
> 	early_init_mmu ->
> 		htab_initialize ->
> 			htab_init_page_sizes ->
> 				htab_dt_scan_hugepage_blocks ->
> 					memblock_reserve
> 						which marks the memory
> 						as reserved
> 					add_gpage
> 						which saves the address
> 						off so future calls for
> 						alloc_bootmem_huge_page()
>
> hugetlb_init ->
> 		hugetlb_init_hstates ->
> 			hugetlb_hstate_alloc_pages ->
> 				alloc_bootmem_huge_page
>
> > Not sure if I understand that correctly.
>
> Basically this is present memory that is "reserved" for the 16GB usage
> per the LPAR configuration. We honor that configuration in Linux based
> upon the contents of the device-tree. It just so happens in the
> configuration from my original e-mail that a consequence of this is that
> a NUMA node has memory (topologically), but none of that memory is free,
> nor will it ever be free.

Well dont do that

> Perhaps, in this case, we could just remove that node from the N_MEMORY
> mask? Memory allocations will never succeed from the node, and we can
> never free these 16GB pages. It is really not any different than a
> memoryless node *except* when you are using the 16GB pages.

That looks to be the correct way to handle things. Maybe mark the node as
offline or somehow not present so that the kernel ignores it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
