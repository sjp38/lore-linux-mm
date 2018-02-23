Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7266B0028
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:38:56 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q7so5632923qtl.0
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:38:56 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u29si1527403qta.323.2018.02.22.18.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 18:38:55 -0800 (PST)
Date: Fri, 23 Feb 2018 10:38:49 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v2 3/3] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180223023849.GE693@localhost.localdomain>
References: <20180222091130.32165-1-bhe@redhat.com>
 <20180222091130.32165-4-bhe@redhat.com>
 <34593e3f-879b-cdf9-9dc4-a114e4bfab52@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <34593e3f-879b-cdf9-9dc4-a114e4bfab52@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de

On 02/22/18 at 02:22pm, Dave Hansen wrote:
> First of all, this is a much-improved changelog.  Thanks for that!
> 
> On 02/22/2018 01:11 AM, Baoquan He wrote:
> > In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> > are allocated with the size of NR_MEM_SECTIONS. They are used to store
> > each memory section's usemap and mem map if marked as present. With
> > the help of these two arrays, continuous memory chunk is allocated for
> > usemap and memmap for memory sections on one node. This avoids too many
> > memory fragmentations. Like below diagram, '1' indicates the present
> > memory section, '0' means absent one. The number 'n' could be much
> > smaller than NR_MEM_SECTIONS on most of systems.
> > 
> > |1|1|1|1|0|0|0|0|1|1|0|0|...|1|0||1|0|...|1||0|1|...|0|
> > -------------------------------------------------------
> >  0 1 2 3         4 5         i   i+1     n-1   n
> > 
> > If fail to populate the page tables to map one section's memmap, its
> > ->section_mem_map will be cleared finally to indicate that it's not present.
> > After use, these two arrays will be released at the end of sparse_init().
> 

Thanks, Dave.

> Let me see if I understand this.  tl;dr version of this changelog:
> 
> Today, we allocate usemap and mem_map for all sections up front and then
> free them later if they are not needed.  With 5-level paging, this eats
> all memory and we fall over before we can free them.  Fix it by only
> allocating what we _need_ (nr_present_sections).

Might no quite right, we allocate pointer array usemap_map and map_map
for all sections, then we allocate usemap and memmap for present sections,
and use usemap_map to point at the allocated usemap, map_map to point at
allocated memmap. At last, we set them into mem_section[]'s member,
please see sparse_init_one_section() calling in sparse_init(). And
pointer array usemap_map and map_map are not needed any more, they are
freed totally.

And yes, with 5-level paging, this eats too much memory. We fall over
because we can't allocate so much memory on system with few memory, e.g
in kdump kernel with 256M memory usually.

Here, pointer array usemap_map and map_map are auxiliary data
structures. Without them, we have to allocate usemap and memmap for 
section one by one, and we tend to allocate each node's data on that
node itself. This will cause too many memory fragmentations.

In this patch, only allocate those temporary pointer arrays usemap_map
and map_map with 'nr_present_sections'. You can see, in sections loop,
there are two variables increasing with different steps. 'pnum' steps up
from 0 to NR_MEM_SECTIONS, while 'i' steps up only if section is
present.

> 
> 
> > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > index 640e68f8324b..f83723a49e47 100644
> > --- a/mm/sparse-vmemmap.c
> > +++ b/mm/sparse-vmemmap.c
> > @@ -281,6 +281,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  	unsigned long pnum;
> >  	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> >  	void *vmemmap_buf_start;
> > +	int i = 0;
> 
> 'i' is a criminally negligent variable name for how it is used here.

Hmm, I considered this. However, it's mainly used to index map, I can't
think of a good name to represent the present section, and also do not
want to make the array indexing line too long. I would like to hear any
suggestion about a better naming.

> 
> >  	size = ALIGN(size, PMD_SIZE);
> >  	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
> > @@ -291,14 +292,15 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  		vmemmap_buf_end = vmemmap_buf_start + size * map_count;
> >  	}
> >  
> > -	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> > +	for (pnum = pnum_begin; pnum < pnum_end && i < map_count; pnum++) {
> >  		struct mem_section *ms;
> >  
> >  		if (!present_section_nr(pnum))
> >  			continue;
> >  
> > -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
> > -		if (map_map[pnum])
> > +		i++;
> > +		map_map[i-1] = sparse_mem_map_populate(pnum, nodeid, NULL);
> > +		if (map_map[i-1])
> >  			continue;
> 
> The i-1 stuff here looks pretty funky.  Isn't this much more readable?


Below code needs another 'i++;' if map_map[i] == 0, it might look not good.
That is why I used trick to avoid it.

	map_map[i] = sparse_mem_map_populate(pnum, nodeid, NULL);
	if (map_map[i]) {
	        i++;
	        continue;
	}
	ms = __nr_to_section(pnum);
	pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
		__func__);
	i++;


Pankaj's suggestion looks better, I plan to take his if no objection.

        map_map[i] = sparse_mem_map_populate(pnum, nodeid, NULL);
        if (map_map[i++])                                                                                                                 
                continue;
        ms = __nr_to_section(pnum);
> 
> 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index e9311b44e28a..aafb6d838872 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -405,6 +405,7 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
> >  	unsigned long pnum;
> >  	unsigned long **usemap_map = (unsigned long **)data;
> >  	int size = usemap_size();
> > +	int i = 0;
> 
> Ditto on the naming.  Shouldn't it be nr_consumed_maps or something?

Before I hesitated on this because it would make the code line too long.

		usemap_map[nr_consumed_maps] = usemap;

I am fine with nr_consumed_maps, or is it OK to replace 'i' with
'nr_present' in all places?

> 
> >  	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
> >  							  size * usemap_count);
> > @@ -413,12 +414,13 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
> >  		return;
> >  	}
> >  
> > -	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> > +	for (pnum = pnum_begin; pnum < pnum_end && i < usemap_count; pnum++) {
> >  		if (!present_section_nr(pnum))
> >  			continue;
> > -		usemap_map[pnum] = usemap;
> > +		usemap_map[i] = usemap;
> >  		usemap += size;
> > -		check_usemap_section_nr(nodeid, usemap_map[pnum]);
> > +		check_usemap_section_nr(nodeid, usemap_map[i]);
> > +		i++;
> >  	}
> >  }
> 
> How would 'i' ever exceed usemap_count?

'i' should not exceed usemap_count, just it's a limit, I had worry. Will
remove the 'i < usemap_count' checking.

> 
> Also, are there any other side-effects from changing map_map[] to be
> indexed by something other than the section number?

>From code, it won't bring side-effect. As I said above, we just write
into map_map[] by indexing with 'i', and fetch with 'i' too from
map_map[]. And agree we need be very careful since this is core code,
need more eyes to help review. 

Thanks
Baoquan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
