Message-ID: <4162ECAD.8090403@colorfullife.com>
Date: Tue, 05 Oct 2004 20:49:17 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: slab fragmentation ?
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>	 <415F968B.8000403@colorfullife.com>	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>	 <41617567.9010507@colorfullife.com>	 <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>	 <4162E0AF.4000704@colorfullife.com> <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>
In-Reply-To: <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:

>>The fix would be simple: kmem_cache_alloc_node must walk through the 
>>list of partial slabs and check if it finds a slab from the correct 
>>node. If it does, then just use that slab instead of allocating a new 
>>one. And statistics must be added to kmem_cache_alloc_node - I forgot 
>>that when I wrote the function.
>>    
>>
>
>I will add more debug to find out if this is happening or not.
>
>What stats you want me to update in kmem_cache_alloc_node() ?
>
>  
>
I would just add a printk to confirm our suspicion. 
"kmem_cache_alloc_node called" + dump_stack(). I always use that 
approach, thus I forgot to add proper statistics.

For the final fix:
Add a field to struct kmem_cache_s. Something like "unsigned long 
alloc_node" or so. Add a STATS_INC_ALLOC_NODE macro and use it. Export 
the field value in the globalstat block (see s_show() near the end of 
slab.c) and increase the version number to 2.1 (in s_start()).

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
