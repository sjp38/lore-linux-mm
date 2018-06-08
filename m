Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA12B6B000C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 11:17:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j11-v6so12483375qtf.15
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 08:17:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j8-v6si204248qkk.100.2018.06.08.08.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 08:17:52 -0700 (PDT)
Date: Fri, 8 Jun 2018 23:17:48 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v4 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Message-ID: <20180608151748.GE16231@MiWiFi-R3L-srv>
References: <20180521101555.25610-1-bhe@redhat.com>
 <20180521101555.25610-4-bhe@redhat.com>
 <8ff7638c-d3ee-a40c-e5cf-deded8d19e93@intel.com>
 <20180608062733.GB16231@MiWiFi-R3L-srv>
 <74359df3-76a8-6dc7-51c5-27019130224f@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <74359df3-76a8-6dc7-51c5-27019130224f@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On 06/08/18 at 07:20am, Dave Hansen wrote:
> On 06/07/2018 11:27 PM, Baoquan He wrote:
> > In alloc_usemap_and_memmap(), it will call
> > sparse_early_usemaps_alloc_node() or sparse_early_mem_maps_alloc_node()
> > to allocate usemap and memmap for each node and install them into
> > usemap_map[] and map_map[]. Here we need pass in the number of present
> > sections on this node so that we can move pointer of usemap_map[] and
> > map_map[] to right position.
> > 
> > How do think about above words?
> 
> But you're now passing in the size of the data structure.  Why is that
> needed all of a sudden?

Oh, it's the size of the data structure. Because
alloc_usemap_and_memmap() is reused for both usemap and memmap
allocation, then inside alloc_usemap_and_memmap(), we need move forward
the passed in pointer which points at the starting address of usemap_map
or memmap_map, to a new position which points at the next starting
address on new node.

You can see we passed the usemap_map, map_map, and the array element
size.  

void __init sparse_init(void)
{
	...
        alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,                                                                                  
                                (void *)usemap_map,
                                sizeof(usemap_map[0]));
	...
        alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
                                (void *)map_map,
                                sizeof(map_map[0]));
	...
}

Then inside alloc_usemap_and_memmap(), For each node, we get how many
present sections on this node, call hook alloc_func(). Then we update
the pointer to point at a new position of usemap_map[] or map_map[].

Here usemap_map[] is (unsigned long *), map_map[] is (struct page*).
Even though both of them are pointer, I think it might be not good to
assume that in alloc_usemap_and_memmap() because
alloc_usemap_and_memmap() doesn't know what is stored in its 2nd
parameter, namely (void * data). So add this new parameter to tell it.

Combine with patch 4/4, it might be easier to understand.

static void __init alloc_usemap_and_memmap(void (*alloc_func)
..
{
	...
	for_each_present_section_nr(pnum_begin + 1, pnum) {
                alloc_func(data, pnum_begin, pnum,                                                                                                
                                                map_count, nodeid_begin);
		...
		data += map_count * data_unit_size; 
		...
	}
	...
}
