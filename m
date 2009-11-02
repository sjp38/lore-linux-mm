Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C0CA96B009C
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 15:47:29 -0500 (EST)
Date: Mon, 2 Nov 2009 13:47:26 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: [patch -mm] mm: slab allocate memory section nodemask for
	large systems
Message-ID: <20091102204726.GG5525@ldl.fc.hp.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com> <20091028083137.GA24140@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com> <20091028183905.GF22743@ldl.fc.hp.com> <alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

* David Rientjes <rientjes@google.com>:
> On Wed, 28 Oct 2009, Alex Chiang wrote:
> 
> > Am I not understanding the code? It looks like we do this
> > already...
> > 
> > /* unregister memory section under all nodes that it spans */
> > int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> > {
> > 	nodemask_t unlinked_nodes;
> > 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> > 
> > 	if (!mem_blk)
> > 		return -EFAULT;
> > 	nodes_clear(unlinked_nodes);
> > 	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> > 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> > 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> > 		int nid;
> > 
> > 		nid = get_nid_for_pfn(pfn);
> > 		if (nid < 0)
> > 			continue;
> > 		if (!node_online(nid))
> > 			continue;
> > 		if (node_test_and_set(nid, unlinked_nodes))
> > 			continue;
> > 		sysfs_remove_link(&node_devices[nid].sysdev.kobj,
> > 			 kobject_name(&mem_blk->sysdev.kobj));
> > 		sysfs_remove_link(&mem_blk->sysdev.kobj,
> > 			 kobject_name(&node_devices[nid].sysdev.kobj));
> > 	}
> > 	return 0;
> > }
> > 
> 
> That shound be sufficient with the exception that allocating nodemask_t 
> on the stack is usually dangerous because it can be extremely large; we 
> typically use NODEMASK_ALLOC() for such code.  It's had some changes in 
> -mm, but since this patchset will likely be going through that tree anyway 
> we can fix it now with the patch below.
> 
> Otherwise, it looks like the iteration is already there and will remove 
> links for memory sections bound to multiple nodes if they exist through 
> hotplug.

Any comments on this patch series?

Turns out that Kame-san's fear about a memory section spanning
several nodes on certain architectures (S390) isn't really
applicable and even if it were, we have code to handle situation
anyway.

Kame-san was generally supportive of these convenience symlinks
although he did not give a formal ACK.

David has given an ACK on the two patches that do real work, as
well as supplied the below patch.

I can respin this series once more, including David's Acked-by:
and adding his patch if that makes life easier for you.

Thanks,
/ac


> mm: slab allocate memory section nodemask for large systems
> 
> Nodemasks should not be allocated on the stack for large systems (when it
> is larger than 256 bytes) since there is a threat of overflow.
> 
> This patch causes the unregister_mem_sect_under_nodes() nodemask to be
> allocated on the stack for smaller systems and be allocated by slab for
> larger systems.
> 
> GFP_KERNEL is used since remove_memory_block() can block.
> 
> Cc: Gary Hade <garyhade@us.ibm.com>
> Cc: Badari Pulavarty <pbadari@us.ibm.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Depends on NODEMASK_ALLOC() changes currently present only in -mm.
> 
>  drivers/base/node.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -363,12 +363,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  /* unregister memory section under all nodes that it spans */
>  int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
>  {
> -	nodemask_t unlinked_nodes;
> +	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>  
> -	if (!mem_blk)
> +	if (!mem_blk) {
> +		NODEMASK_FREE(unlinked_nodes);
>  		return -EFAULT;
> -	nodes_clear(unlinked_nodes);
> +	}
> +	nodes_clear(*unlinked_nodes);
>  	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> @@ -379,13 +381,14 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
>  			continue;
>  		if (!node_online(nid))
>  			continue;
> -		if (node_test_and_set(nid, unlinked_nodes))
> +		if (node_test_and_set(nid, *unlinked_nodes))
>  			continue;
>  		sysfs_remove_link(&node_devices[nid].sysdev.kobj,
>  			 kobject_name(&mem_blk->sysdev.kobj));
>  		sysfs_remove_link(&mem_blk->sysdev.kobj,
>  			 kobject_name(&node_devices[nid].sysdev.kobj));
>  	}
> +	NODEMASK_FREE(unlinked_nodes);
>  	return 0;
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
