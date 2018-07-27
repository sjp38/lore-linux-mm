Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51A316B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:56:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n22-v6so2672077wmc.6
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 04:56:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor1602716wro.4.2018.07.27.04.56.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 04:56:47 -0700 (PDT)
Date: Fri, 27 Jul 2018 13:56:45 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 2/3] mm: calculate deferred pages after skipping
 mirrored memory
Message-ID: <20180727115645.GA13637@techadventures.net>
References: <20180726193509.3326-1-pasha.tatashin@oracle.com>
 <20180726193509.3326-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726193509.3326-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu, Jul 26, 2018 at 03:35:08PM -0400, Pavel Tatashin wrote:
> update_defer_init() should be called only when struct page is about to be
> initialized. Because it counts number of initialized struct pages, but
> there we may skip struct pages if there is some mirrored memory.
> 
> So move, update_defer_init() after checking for mirrored memory.
> 
> Also, rename update_defer_init() to defer_init() and reverse the return
> boolean to emphasize that this is a boolean function, that tells that the
> reset of memmap initialization should be deferred.
> 
> Make this function self-contained: do not pass number of already
> initialized pages in this zone by using static counters.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  mm/page_alloc.c | 45 +++++++++++++++++++++++++--------------------
>  1 file changed, 25 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6796dacd46ac..4946c73e549b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -306,24 +306,33 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
>  }
>  
>  /*
> - * Returns false when the remaining initialisation should be deferred until
> + * Returns true when the remaining initialisation should be deferred until
>   * later in the boot cycle when it can be parallelised.
>   */
> -static inline bool update_defer_init(pg_data_t *pgdat,
> -				unsigned long pfn, unsigned long zone_end,
> -				unsigned long *nr_initialised)
> +static bool __meminit
> +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)

Hi Pavel,

maybe I do not understand properly the __init/__meminit macros, but should not
"defer_init" be __init instead of __meminit?
I think that functions marked as __meminit are not freed up, right?

Besides that, this looks good to me:

Reviewed-by: Oscar Salvador <osalvador@suse.de>
-- 
Oscar Salvador
SUSE L3
