Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8E26B6F21
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:28:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 33-v6so2385974plf.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:28:03 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n15-v6si23959956pgc.309.2018.09.04.12.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:28:02 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Create non-atomic version of SetPageReserved for
 init use
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183345.4416.76515.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b9344b71-3ae9-95c0-ccc2-ec3db37ccf9f@intel.com>
Date: Tue, 4 Sep 2018 12:27:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180904183345.4416.76515.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/04/2018 11:33 AM, Alexander Duyck wrote:
> +++ b/mm/page_alloc.c
> @@ -1231,7 +1231,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  			/* Avoid false-positive PageTail() */
>  			INIT_LIST_HEAD(&page->lru);
>  
> -			SetPageReserved(page);
> +			__SetPageReserved(page);
>  		}
>  	}
>  }
> @@ -5518,7 +5518,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		page = pfn_to_page(pfn);
>  		__init_single_page(page, pfn, zone, nid);
>  		if (context == MEMMAP_HOTPLUG)
> -			SetPageReserved(page);
> +			__SetPageReserved(page);

Comments needed, please.  SetPageReserved() is opaque enough by itself,
but having to discern between it and an __ variant is even less fun.
