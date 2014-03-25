Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1C66B003C
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:10:33 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id uz6so1025596obc.27
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:10:33 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id e10si23081878oey.40.2014.03.25.11.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 11:10:32 -0700 (PDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 25 Mar 2014 12:10:32 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 665631FF0040
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:10:29 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2PG7a3w58982462
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 17:07:36 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2PIATFj008125
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:10:29 -0600
Date: Tue, 25 Mar 2014 11:10:10 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
Message-ID: <20140325181010.GB29977@linux.vnet.ibm.com>
References: <20140311210614.GB946@linux.vnet.ibm.com>
 <20140313170127.GE22247@linux.vnet.ibm.com>
 <20140324230550.GB18778@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251116490.16557@nuc>
 <20140325162303.GA29977@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251152250.16870@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1403251152250.16870@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On 25.03.2014 [11:53:48 -0500], Christoph Lameter wrote:
> On Tue, 25 Mar 2014, Nishanth Aravamudan wrote:
> 
> > On 25.03.2014 [11:17:57 -0500], Christoph Lameter wrote:
> > > On Mon, 24 Mar 2014, Nishanth Aravamudan wrote:
> > >
> > > > Anyone have any ideas here?
> > >
> > > Dont do that? Check on boot to not allow exhausting a node with huge
> > > pages?
> >
> > Gigantic hugepages are allocated by the hypervisor (not the Linux VM),
> 
> Ok so the kernel starts booting up and then suddenly the hypervisor takes
> the 2 16G pages before even the slab allocator is working?

There is nothing "sudden" about it.

On power, very early, we find the 16G pages (gpages in the powerpc arch
code) in the device-tree:

early_setup ->
	early_init_mmu ->
		htab_initialize ->
			htab_init_page_sizes ->
				htab_dt_scan_hugepage_blocks ->
					memblock_reserve
						which marks the memory
						as reserved
					add_gpage
						which saves the address
						off so future calls for
						alloc_bootmem_huge_page()

hugetlb_init ->
		hugetlb_init_hstates ->
			hugetlb_hstate_alloc_pages ->
				alloc_bootmem_huge_page

> Not sure if I understand that correctly.

Basically this is present memory that is "reserved" for the 16GB usage
per the LPAR configuration. We honor that configuration in Linux based
upon the contents of the device-tree. It just so happens in the
configuration from my original e-mail that a consequence of this is that
a NUMA node has memory (topologically), but none of that memory is free,
nor will it ever be free.

Perhaps, in this case, we could just remove that node from the N_MEMORY
mask? Memory allocations will never succeed from the node, and we can
never free these 16GB pages. It is really not any different than a
memoryless node *except* when you are using the 16GB pages.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
