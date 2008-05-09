Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m49BYapY114890
	for <linux-mm@kvack.org>; Fri, 9 May 2008 11:34:36 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m49BYZRZ700452
	for <linux-mm@kvack.org>; Fri, 9 May 2008 12:34:35 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m49BYZAr023999
	for <linux-mm@kvack.org>; Fri, 9 May 2008 12:34:35 +0100
Date: Fri, 9 May 2008 13:34:34 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] sparsemem vmemmap: initialize memmap.
Message-ID: <20080509113434.GG9840@osiris.boeblingen.de.ibm.com>
References: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com> <20080509103132.GB10210@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080509103132.GB10210@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Index: linux-2.6/mm/sparse-vmemmap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/sparse-vmemmap.c
> > +++ linux-2.6/mm/sparse-vmemmap.c
> > @@ -154,6 +154,6 @@ struct page * __meminit sparse_mem_map_p
> >  	int error = vmemmap_populate(map, PAGES_PER_SECTION, nid);
> >  	if (error)
> >  		return NULL;
> > -
> > +	memset(map, 0, PAGES_PER_SECTION * sizeof(struct page));
> >  	return map;
> >  }
> 
> The normal expectation is that all allocations are made using
> vmemmap_alloc_block() which allocates from the appropriate place.  Once
> the buddy is up and available it uses:
> 
> 	struct page *page = alloc_pages_node(node,
> 			GFP_KERNEL | __GFP_ZERO, get_order(size));
> 
> to get the memory so it should all be zero'd.  So I would expect all
> existing users to be covered by that?  Can you not simply use __GFP_ZERO
> for your allocations or use vmemmap_alloc_block() ?

Ah, I didn't notice the __GFP_ZERO. So it's just an s390 bug. Will
move the memset to our code instead.
Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
