Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBDNFUu8006966
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 18:15:30 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBDNF2xW225910
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 18:15:02 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBDNF2OS003934
	for <linux-mm@kvack.org>; Wed, 13 Dec 2006 18:15:02 -0500
Date: Wed, 13 Dec 2006 15:17:17 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: Bug: early_pfn_in_nid() called when not early
Message-ID: <20061213231717.GC10708@monkey.ibm.com>
References: <200612131920.59270.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200612131920.59270.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andy Whitcroft <apw@shadowen.org>, Michael Kravetz <mkravetz@us.ibm.com>, hch@infradead.org, Jeremy Kerr <jk@ozlabs.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 13, 2006 at 07:20:57PM +0100, Arnd Bergmann wrote:
> After a lot of debugging in spufs, I found that a crash that we encountered
> on Cell actually was caused by a change in the memory management.
> 
> The patch that caused it is archived in http://lkml.org/lkml/2006/11/1/43,
> and this one has been discussed back and forth, but I fear that the current
> version may be broken for all setups that do memory hotplug with sparsemen
> and NUMA, at least on powerpc.

I believe you are correct.  At least the memory hotplug code for powerpc
is currently broken (caused crash!).

> - both early_pfn_{in,to}_nid and early_node_map are in the __init
>   section and may already have been freed at the time we are calling
>   memmap_init_zone().

Well that is the root of the problem for powerpc.  I believe that
__meminit attribute on memmap_init_zone() has no definition if
CONFIG_MEMORY_HOTPLUG is defined.  This is so that it can be called
after boot.  But, this also implies that memmap_init_zone() can not
call any routines in the __init section.

> The patch below is not a suggested fix that I want to get into mainline
> (checking slab_is_available is the wrong here), but it is a quick fix
> that you should apply if you want to run a recent (post-2.6.18) kernel
> on the IBM QS20 blade. I'm sorry for not having reported this earlier,
> but we were always trying to find the problem in my own code...

Thanks for the debug work!  Just curious if you really need
CONFIG_NODES_SPAN_OTHER_NODES defined for your platform?  Can you get
those types of memory layouts?  If not, an easy/immediate fix for you
might be to simply turn off the option.

> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -1962,7 +1962,8 @@ void __meminit memmap_init_zone(unsigned
>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		if (!early_pfn_valid(pfn))
>  			continue;
> -		if (!early_pfn_in_nid(pfn, nid))
> +		if (!slab_is_available() &&
> +		    !early_pfn_in_nid(pfn, nid))
>  			continue;
>  		page = pfn_to_page(pfn);
>  		set_page_links(page, zone, nid, pfn);

I know you don't recommend this as a fix, but it has the interesting
quality of doing exactly what we want for powerpc.  When
slab_is_available() we are performing a 'memory add' operation
and there is no need to do the 'pfn_in_nid' check.  We know that
the range of added pages will all be on the same (passed) nid.

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
