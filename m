Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4206B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:47:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a186so13692968wmh.9
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 04:47:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k12si3731836wmc.229.2017.08.14.04.47.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 04:47:57 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:47:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 05/15] mm: don't accessed uninitialized struct pages
Message-ID: <20170814114755.GI19063@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-6-git-send-email-pasha.tatashin@oracle.com>
 <20170811093746.GF30811@dhcp22.suse.cz>
 <8444cb2b-b134-e9fc-a458-1ba7b22a8df1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8444cb2b-b134-e9fc-a458-1ba7b22a8df1@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

On Fri 11-08-17 11:55:39, Pasha Tatashin wrote:
> On 08/11/2017 05:37 AM, Michal Hocko wrote:
> >On Mon 07-08-17 16:38:39, Pavel Tatashin wrote:
> >>In deferred_init_memmap() where all deferred struct pages are initialized
> >>we have a check like this:
> >>
> >>     if (page->flags) {
> >>             VM_BUG_ON(page_zone(page) != zone);
> >>             goto free_range;
> >>     }
> >>
> >>This way we are checking if the current deferred page has already been
> >>initialized. It works, because memory for struct pages has been zeroed, and
> >>the only way flags are not zero if it went through __init_single_page()
> >>before.  But, once we change the current behavior and won't zero the memory
> >>in memblock allocator, we cannot trust anything inside "struct page"es
> >>until they are initialized. This patch fixes this.
> >>
> >>This patch defines a new accessor memblock_get_reserved_pfn_range()
> >>which returns successive ranges of reserved PFNs.  deferred_init_memmap()
> >>calls it to determine if a PFN and its struct page has already been
> >>initialized.
> >
> >Why don't we simply check the pfn against pgdat->first_deferred_pfn?
> 
> Because we are initializing deferred pages, and all of them have pfn greater
> than pgdat->first_deferred_pfn. However, some of deferred pages were already
> initialized if they were reserved, in this path:
> 
> mem_init()
>  free_all_bootmem()
>   free_low_memory_core_early()
>    for_each_reserved_mem_region()
>     reserve_bootmem_region()
>      init_reserved_page() <- if this is deferred reserved page
>       __init_single_pfn()
>        __init_single_page()
> 
> So, currently, we are using the value of page->flags to figure out if this
> page has been initialized while being part of deferred page, but this is not
> going to work for this project, as we do not zero the memory that is backing
> the struct pages, and size the value of page->flags can be anything.

True, this is the initialization part I've missed in one of the previous
patches already. Would it be possible to only iterate over !reserved
memory blocks instead? Now that we discard all the metadata later it
should be quite easy to do for_each_memblock_type, no?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
