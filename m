Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F00CD6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 19:06:10 -0400 (EDT)
Received: by padck2 with SMTP id ck2so20901768pad.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:06:10 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id or4si10829053pdb.2.2015.07.24.16.06.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 16:06:10 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so19937197pdb.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 16:06:09 -0700 (PDT)
Date: Fri, 24 Jul 2015 16:06:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 4/4] mm: fallback for offline nodes in
 alloc_pages_node
In-Reply-To: <55B2A292.7080503@suse.cz>
Message-ID: <alpine.DEB.2.10.1507241559181.12744@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org> <alpine.DEB.2.10.1507241251460.5215@chino.kir.corp.google.com> <55B2A292.7080503@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> >>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> >>> index 531c72d..104a027 100644
> >>> --- a/include/linux/gfp.h
> >>> +++ b/include/linux/gfp.h
> >>> @@ -321,8 +321,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >>>  						unsigned int order)
> >>>  {
> >>>  	/* Unknown node is current (or closest) node */
> >>> -	if (nid == NUMA_NO_NODE)
> >>> +	if (nid == NUMA_NO_NODE) {
> >>>  		nid = numa_mem_id();
> >>> +	} else if (!node_online(nid)) {
> >>> +		VM_WARN_ON(!node_online(nid));
> >>> +		nid = numa_mem_id();
> >>> +	}
> >>
> >> I would think you would only want this for debugging purposes. The
> >> overwhelming majority of hardware out there has no memory
> >> onlining/offlining capability after all and this adds the overhead to each
> >> call to alloc_pages_node.
> >>
> >> Make this dependo n CONFIG_VM_DEBUG or some such thing?
> >>
> > 
> > Yeah, the suggestion was for VM_WARN_ON() in the conditional, but the 
> > placement has changed somewhat because of the new __alloc_pages_node().  I 
> > think
> > 
> > 	else if (VM_WARN_ON(!node_online(nid)))
> > 		nid = numa_mem_id();
> > 
> > should be fine since it only triggers for CONFIG_DEBUG_VM.
> 
> Um, so on your original suggestion I thought that you assumed that the condition
> inside VM_WARN_ON is evaluated regardless of CONFIG_DEBUG_VM, it just will or
> will not generate a warning. Which is how BUG_ON works, but VM_WARN_ON (and
> VM_BUG_ON) doesn't. IIUC VM_WARN_ON() with !CONFIG_DEBUG_VM will always be false.

Right, that's what Christoph is also suggesting.  VM_WARN_ON without 
CONFIG_DEBUG_VM should permit the compiler to check the expression but not 
generate any code and we don't want to check node_online() here for every 
allocation, it's only a debugging measure.

> Because I didn't think you would suggest the "nid = numa_mem_id()" for
> !node_online(nid) fixup would happen only for CONFIG_DEBUG_VM kernels. But it
> seems that you do suggest that? I would understand if the fixup (correcting an
> offline node to some that's online) was done regardless of DEBUG_VM, and
> DEBUG_VM just switched between silent and noisy fixup. But having a debug option
> alter the outcome seems wrong?

Hmm, not sure why this is surprising, I don't expect people to deploy 
production kernels with CONFIG_DEBUG_VM enabled, it's far too expensive.  
I was expecting they would enable it for, well... debug :)

In that case, if nid is a valid node but offline, then the nid = 
numa_mem_id() fixup seems fine to allow the kernel to continue debugging.

When a node is offlined as a result of memory hotplug, the pgdat doesn't 
get freed so it can be onlined later.  Thus, alloc_pages_node() with an 
offline node and !CONFIG_DEBUG_VM may not panic.  If it does, this can 
probably be removed because we're covered.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
