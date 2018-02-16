Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC0246B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 04:30:04 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 63so1300246wrn.7
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 01:30:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 73sor762742wmj.32.2018.02.16.01.30.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 01:30:03 -0800 (PST)
Date: Fri, 16 Feb 2018 10:30:00 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v4 6/6] mm/memory_hotplug: optimize memory hotplug
Message-ID: <20180216092959.gkm6d4j2zplk724r@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-7-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180215165920.8570-7-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> During memory hotplugging we traverse struct pages three times:
> 
> 1. memset(0) in sparse_add_one_section()
> 2. loop in __add_section() to set do: set_page_node(page, nid); and
>    SetPageReserved(page);
> 3. loop in memmap_init_zone() to call __init_single_pfn()
> 
> This patch remove the first two loops, and leaves only loop 3. All struct
> pages are initialized in one place, the same as it is done during boot.

s/remove
 /removes

> The benefits:
> - We improve the memory hotplug performance because we are not evicting
>   cache several times and also reduce loop branching overheads.

s/We improve the memory hotplug performance
 /We improve memory hotplug performance

s/not evicting cache several times
 /not evicting the cache several times

s/overheads
 /overhead

> - Remove condition from hotpath in __init_single_pfn(), that was added in
>   order to fix the problem that was reported by Bharata in the above email
>   thread, thus also improve the performance during normal boot.

s/improve the performance
 /improve performance

> - Make memory hotplug more similar to boot memory initialization path
>   because we zero and initialize struct pages only in one function.

s/more similar to boot memory initialization path
 /more similar to the boot memory initialization path

> - Simplifies memory hotplug strut page initialization code, and thus
>   enables future improvements, such as multi-threading the initialization
>   of struct pages in order to improve the hotplug performance even further
>   on larger machines.

s/strut
 /struct

s/to improve the hotplug performance even further
 /to improve hotplug performance even further

> @@ -260,21 +260,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  		return ret;
>  
>  	/*
> -	 * Make all the pages reserved so that nobody will stumble over half
> -	 * initialized state.
> -	 * FIXME: We also have to associate it with a node because page_to_nid
> -	 * relies on having page with the proper node.
> +	 * The first page in every section holds node id, this is because we
> +	 * will need it in online_pages().

s/holds node id
 /holds the node id

> +#ifdef CONFIG_DEBUG_VM
> +	/*
> +	 * poison uninitialized struct pages in order to catch invalid flags
> +	 * combinations.

Please capitalize sentences properly.

> +	 */
> +	memset(memmap, PAGE_POISON_PATTERN,
> +	       sizeof(struct page) * PAGES_PER_SECTION);
> +#endif

I'd suggest writing this into a single line:

	memset(memmap, PAGE_POISON_PATTERN, sizeof(struct page)*PAGES_PER_SECTION);

(And ignore any checkpatch whinging - the line break didn't make it more 
readable.)

With those details fixed, and assuming that this patch was tested:

  Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
