Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E5A956B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 17:34:31 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4398651pbb.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 14:34:31 -0700 (PDT)
Date: Thu, 28 Jun 2012 14:34:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
In-Reply-To: <20120628061658.GA27958@shangw>
Message-ID: <alpine.DEB.2.00.1206281431510.1652@chino.kir.corp.google.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com> <alpine.DEB.2.00.1206271501240.22985@chino.kir.corp.google.com> <20120628061658.GA27958@shangw>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Thu, 28 Jun 2012, Gavin Shan wrote:

> >> +{
> >> +	unsigned long size = SECTIONS_PER_ROOT *
> >> +			     sizeof(struct mem_section);
> >> +
> >> +	if (!section)
> >> +		return;
> >> +
> >> +	if (slab_is_available())
> >> +		kfree(section);
> >> +	else
> >> +		free_bootmem_node(NODE_DATA(nid),
> >> +			virt_to_phys(section), size);
> >
> >Did you check what happens here if !node_state(nid, N_HIGH_MEMORY)?
> >
> 
> I'm sorry that I'm not catching your point. Please explain for more
> if necessary.
> 

I'm asking specifically about the free_bootmem_node(NODE_DATA(nid), ...).

If this section was allocated in sparse_index_alloc() before 
slab_is_available() with alloc_bootmem_node() and nid is not in 
N_HIGH_MEMORY, will alloc_bootmem_node() fallback to any node or return 
NULL?

If it falls back to any node, is it safe to try to free that section by 
passing NODE_DATA(nid) here when it wasn't allocated on that nid?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
