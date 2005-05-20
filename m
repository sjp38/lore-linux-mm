Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4KKK9cE084188
	for <linux-mm@kvack.org>; Fri, 20 May 2005 16:20:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4KKK9eb242272
	for <linux-mm@kvack.org>; Fri, 20 May 2005 14:20:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4KKK99f009688
	for <linux-mm@kvack.org>; Fri, 20 May 2005 14:20:09 -0600
Message-ID: <428E4671.7020207@us.ibm.com>
Date: Fri, 20 May 2005 13:20:01 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>  <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>  <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>  <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com> <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com> <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com> <428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net> <Pine.LNX.4.62.0505182105310.17811@graphe.net> <428E3497.3080406@us.ibm.com> <Pine.LNX.4.62.0505201210460.390@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505201210460.390@graphe.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 20 May 2005, Matthew Dobson wrote:
> 
> 
>>Christoph, I'm getting the following errors building rc4-mm2 w/ GCC 2.95.4:
> 
> 
> Works fine here with gcc 2.95.4.ds15-22 but that is a debian gcc 
> 2.95.4 patched up to work correctly. If you need to address the pathology in pristine 
> gcc 2.95.4 by changing the source then declare the entry field with 0 
> members.
> 
> Index: linux-2.6.12-rc4/mm/slab.c
> ===================================================================
> --- linux-2.6.12-rc4.orig/mm/slab.c	2005-05-19 21:29:45.000000000 +0000
> +++ linux-2.6.12-rc4/mm/slab.c	2005-05-20 19:18:22.000000000 +0000
> @@ -267,7 +267,7 @@
>  #ifdef CONFIG_NUMA
>  	spinlock_t lock;
>  #endif
> -	void *entry[];
> +	void *entry[0];
>  };
>  
>  /* bootstrap: The caches do not work without cpuarrays anymore,
> 
> 
> 
> gcc 2.95 can produce proper code for ppc64?

Apparently...?


>>mm/slab.c:281: field `entry' has incomplete typemm/slab.c: In function
>>'cache_alloc_refill':
> 
> 
> See patch above?

Will do.


>>mm/slab.c:2497: warning: control reaches end of non-void function
> 
> 
> That is the end of cache_alloc_debug_check right? This is a void 
> function in my source.

Nope.  It's the end of this function:
static void *cache_alloc_refill(kmem_cache_t *cachep, unsigned int __nocast
flags)

Though I'm not sure why I'm getting this warning, since the function ends
like this:
	ac->touched = 1;
	return ac->entry[--ac->avail];
} <<--  Line 2497


>>mm/slab.c: In function `kmem_cache_alloc':
>>mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
>>mm/slab.c: In function `kmem_cache_alloc_node':
>>mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
>>mm/slab.c: In function `__kmalloc':
>>mm/slab.c:2567: warning: `objp' might be used uninitialized in this function
> 
> 
> There is a branch there and the object is initialized in either branch.

I agree.  Not sure why this warning is occurring, either.

I tried to build this twice on this particular box, to no avail.  3x == charm?

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
