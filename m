Message-ID: <415F968B.8000403@colorfullife.com>
Date: Sun, 03 Oct 2004 08:04:59 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: slab fragmentation ?
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]> <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
In-Reply-To: <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:

>Yes. But the next allocations should be satisfied by filling in the
>partial slabs, instead of getting a new slab.
>
>As you can see from my tests, we are allocating and freeing few
>thousands every second. I can imagine this happening, if we allocated
>150K objects and then freed 140K of them randomly.
>
>  
>
Could you check what is the maximum number of objects that were 
allocated? Enable debugging and check /proc/slabinfo, it's listed in the 
globalstat block.

>I modified "crash" kmem command to dump all the slabs in the cache. 
>I am attaching the output.
>
>I am wondering why we are not filling up partial slabs, before
>allocating new ones ?
>  
>
It should be impossible. s_show checks that the slabs are in the correct 
list (full/partial/empty). You didn't get any errors, thus everything 
was filed correctly. And cache_alloc_refill only calls cache_grow if the 
partial and empty lists are empty.

Wait - do you use kmem_cache_alloc_node()? If you use this function then 
the fragmentation you have described can easily happen.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
