Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDDF6B029E
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:15:03 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z16-v6so4039452wrs.22
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 05:15:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 15-v6sor1150954wmr.64.2018.07.25.05.15.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 05:15:01 -0700 (PDT)
Date: Wed, 25 Jul 2018 14:14:59 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/3] mm: calculate deferred pages after skipping mirrored
 memory
Message-ID: <20180725121459.GA16987@techadventures.net>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724235520.10200-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 07:55:19PM -0400, Pavel Tatashin wrote:
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
>  mm/page_alloc.c | 40 ++++++++++++++++++++--------------------
>  1 file changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cea749b26394..86c678cec6bd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -306,24 +306,28 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
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
> +static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
>  {
> +	static unsigned long prev_end_pfn, nr_initialised;
> +
> +	if (prev_end_pfn != end_pfn) {
> +		prev_end_pfn = end_pfn;
> +		nr_initialised = 0;
> +	}
Hi Pavel,

What about a comment explaining that "if".
I am not the brightest one, so it took me a bit to figure out that we got that "if" there
because now that the variables are static, we need to somehow track whenever we change to
another zone.

Thanks
-- 
Oscar Salvador
SUSE L3
