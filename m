Message-ID: <4773CBD2.10703@hp.com>
Date: Thu, 27 Dec 2007 10:59:14 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: SLUB
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com>
In-Reply-To: <4773B50B.6060206@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mark Seger <Mark.Seger@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I now have a 'prototype' of something I think makes sense, at least from 
my collectl tool's perspective.  Keep in mind the philosophy behind 
collectl is to have a tool you can run both interactively and as a 
daemon that will give you enough information to paint a picture of 
what's happening on your system and in this case I'm focused on slabs.  
This is not intended to be a highly analytical tool but rather a 
starting point to identify areas potentially requiring a deeper dive.  
For example, with the current version that's driven off /proc/slabinfo, 
it's been possible to look at the long term changes to individual slabs 
to get picture of how memory is being allocated and when there are 
memory issues it can be useful to see which slabs (if any) are growing 
at an unexpected rate.  That said, I'm thinking of reporting something 
like the following:

                           <-------- objects --------><----- slabs 
-----><------ memory ------>
Slab Name                     Size   In Use    Avail     Size   
Number        Used       Total
:0000008                         8     2164     2560     4096        
5       17312       20480
:0000016                        16     1448     2816     4096       
11       23168       45056
:0000024                        24      460      680     4096        
4       11040       16384
:0000032                        32      384     1152     4096        
9       12288       36864
:0000040                        40      306      306     4096        
3       12240       12288

The idea here is that  for each slab in the 'objects' section one can 
see how many objects are 'in use' and how many are 'available', the 
point being one can look at the difference to see how many more objects 
are available before the system needs to allocate another slab.  Under 
the 'slabs' section you can see how big the individual slabs are and how 
many of them there are and finally under 'memory' you can see how much 
has been used by processes vs how much is still allocated as slabs.

There are all sorts of other ways to present the data such as 
percentages, differences, etc. but this is more-or-less the way I did it 
in the past and the information was useful.  One could also argue that 
the real key information here is Uses/Total and the rest is just window 
dressing and I couldn't disagree with that either, but I do think it 
helps paint a more complete picture.

-mark

Mark Seger wrote:
> Now that I've had some more time to think about this and play around 
> with the slabinfo tool I fear my problem had getting my head wrapped 
> around the terminology, but that's my problem.  Since there are 
> entries called object_size, objs_per_slab and slab_size I would have 
> thought that object_size*objects_per_slab=slab_size but that clearly 
> isn't the case.  Since slabs are allocated in pages, the actual size 
> of the slabs is always a multiple of the page_size (actually by a 
> power of 2) and that's why I see calculations in slabinfo like 
> page_size << order, but I guess I'm still not sure what the  actual 
> definition of 'order' actually is.
>
> Anyhow, when I run slabinfo and see the following entry
>
> Slabcache: skbuff_fclone_cache   Aliases:  0 Order :  0 Objects: 25
> ** Hardware cacheline aligned
>
> Sizes (bytes)     Slabs              Debug                Memory
> ------------------------------------------------------------------------
> Object :     420  Total  :       4   Sanity Checks : Off  Total:   16384
> SlabObj:     448  Full   :       0   Redzoning     : Off  Used :   10500
> SlabSiz:    4096  Partial:       0   Poisoning     : Off  Loss :    5884
> Loss   :      28  CpuSlab:       4   Tracking      : Off  Lalig:     700
> Align  :       0  Objects:       9   Tracing       : Off  Lpadd:     256
>
> according to the entries under /sys/slabs/skbuff_fclone_cache it looks 
> like the slab_size field is being reported above as 'SlabObj' and 
> objs_per_slab is being reported as 'Objects' and as I mentioned above, 
> SlabSiz is based on 'order'.
>
> Anyhow, as I understand what's going on at a very high level, memory 
> is reserved for use as slabs (which themselves are multiples of pages) 
> and processes allocate objects from within slabs as they need them.  
> Therefore the 2 high-level numbers that seem of interest from a memory 
> usage perspective are the memory allocated and the amount in use.  I 
> think these are the "Total" and "Used" fields in slabinfo.
>
> Total = page_size << order
>
> As for 'Used' that looks to be a straight calculation of objects * 
> object_size
>
> The Slabs field in /proc/meminfo is the total of the individual 
> 'Total's...
>
> Stay tuned and at some point I'll have support in collectl for 
> reporting total/allocated usage by slab in collectl, though perhaps 
> I'll post a 'proposal' first in the hopes of getting some constructive 
> feedback as I want to present useful information rather than that 
> columns of numbers.
>
> -mark
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
