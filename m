From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006212303.QAA60182@google.engr.sgi.com>
Subject: Re: Questions on pg_data_t structure
Date: Wed, 21 Jun 2000 16:03:53 -0700 (PDT)
In-Reply-To: <20000621225539Z131176-21002+39@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 05:49:11 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> Ok, I've been trying to figure this stuff out over the past two weeks, and I
> need help.
> 
> Here's what I think I know so far:
> 
> In a non-NUMA system, there is a single master pg_data_t structure called
> contig_page_data.

In a non-DISCONTIGMEM system, not in a non-NUMA system ... This stuff
is still evolving, I think NUMA may be a subset of DISCONTIGMEM.

You are best off thinking about multiple pg_data_t structures in the
system - the contig_page_data is just a degenerate case of DISCONTIGMEM
that allows just some more optimizations.

> 
> contig_page_data contains two arrays, node_zonelists and node_zones.  There are
> MAX_NR_ZONES (3) elements in node_zones, and there are 256 elements (of which
> only the first 16 in non-CONFIG_HIGHMEM kernels are supposed to be used.)
> 
> Here's where I get confused:
> 
> node_zones is an array of zone_t structures.  node_zonelists is an array of
> zonelist_t structures.  The zonelist_t structure also contains an array of
> zone_t structures.  
> 
> My question is: what is the difference between the zone_t's in node_zones and
> the zone_t's in each node_zonelists element?
> 
>

For each pg_data_t, there are MAX_NR_ZONES=3 zone_t structures. 
For each pg_data_t, there are NR_GFPINDEX=0x100 zonelist_t structures.
Each zonelist_t structure has a list of MAX_NR_ZONES+1=4 _pointers_
to zones, and all these pointers point to one of the 3 zones in the
pg_data_t. These pointers are set up in build_zonelists(), to make
searches for specific types of pages follow a deterministic order
depending on memory types present in the system.

Kanoj 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
