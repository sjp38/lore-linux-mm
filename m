Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1C66B18A9
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 06:46:32 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v65-v6so14374867qka.23
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 03:46:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v18-v6si8758222qta.297.2018.08.20.03.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 03:46:31 -0700 (PDT)
Subject: Re: [PATCH v1 5/5] mm/memory_hotplug: print only with DEBUG_VM in
 online/offline_pages()
References: <20180816100628.26428-1-david@redhat.com>
 <20180816100628.26428-6-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7892e949-6c2c-9659-a595-177037d0e203@redhat.com>
Date: Mon, 20 Aug 2018 12:46:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180816100628.26428-6-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 16.08.2018 12:06, David Hildenbrand wrote:
> Let's try to minimze the noise.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  mm/memory_hotplug.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index bbbd16f9d877..6fec2dc6a73d 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -966,9 +966,11 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>  	return 0;
>  
>  failed_addition:
> +#ifdef CONFIG_DEBUG_VM
>  	pr_debug("online_pages [mem %#010llx-%#010llx] failed\n",
>  		 (unsigned long long) pfn << PAGE_SHIFT,
>  		 (((unsigned long long) pfn + nr_pages) << PAGE_SHIFT) - 1);
> +#endif
>  	memory_notify(MEM_CANCEL_ONLINE, &arg);
>  	return ret;
>  }
> @@ -1660,7 +1662,9 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>  	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
>  	if (offlined_pages < 0)
>  		goto repeat;
> +#ifdef CONFIG_DEBUG_VM
>  	pr_info("Offlined Pages %ld\n", offlined_pages);
> +#endif
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	offline_isolated_pages(start_pfn, end_pfn);
> @@ -1695,9 +1699,11 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
>  	return 0;
>  
>  failed_removal:
> +#ifdef CONFIG_DEBUG_VM
>  	pr_debug("memory offlining [mem %#010llx-%#010llx] failed\n",
>  		 (unsigned long long) start_pfn << PAGE_SHIFT,
>  		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
> +#endif
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  	/* pushback to free area */
>  	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> 

I'll drop this patch for now, maybe the error messages are actually
useful when debugging a crashdump of a system without CONFIG_DEBUG_VM.

-- 

Thanks,

David / dhildenb
