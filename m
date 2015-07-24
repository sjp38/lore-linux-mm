Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA116B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 15:54:35 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so18137394pdr.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:54:35 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id hi6si21366933pac.81.2015.07.24.12.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 12:54:34 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so19023121pab.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:54:34 -0700 (PDT)
Date: Fri, 24 Jul 2015 12:54:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v2 4/4] mm: fallback for offline nodes in
 alloc_pages_node
In-Reply-To: <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org>
Message-ID: <alpine.DEB.2.10.1507241251460.5215@chino.kir.corp.google.com>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Christoph Lameter wrote:

> On Fri, 24 Jul 2015, Vlastimil Babka wrote:
> 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 531c72d..104a027 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -321,8 +321,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >  						unsigned int order)
> >  {
> >  	/* Unknown node is current (or closest) node */
> > -	if (nid == NUMA_NO_NODE)
> > +	if (nid == NUMA_NO_NODE) {
> >  		nid = numa_mem_id();
> > +	} else if (!node_online(nid)) {
> > +		VM_WARN_ON(!node_online(nid));
> > +		nid = numa_mem_id();
> > +	}
> 
> I would think you would only want this for debugging purposes. The
> overwhelming majority of hardware out there has no memory
> onlining/offlining capability after all and this adds the overhead to each
> call to alloc_pages_node.
> 
> Make this dependo n CONFIG_VM_DEBUG or some such thing?
> 

Yeah, the suggestion was for VM_WARN_ON() in the conditional, but the 
placement has changed somewhat because of the new __alloc_pages_node().  I 
think

	else if (VM_WARN_ON(!node_online(nid)))
		nid = numa_mem_id();

should be fine since it only triggers for CONFIG_DEBUG_VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
