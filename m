Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD788E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:46:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so9240463edd.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:46:29 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id d8-v6si2004544ejm.81.2019.01.22.02.46.28
        for <linux-mm@kvack.org>;
        Tue, 22 Jan 2019 02:46:28 -0800 (PST)
Date: Tue, 22 Jan 2019 11:46:24 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v3] mm/hotplug: invalid PFNs from pfn_to_online_page()
Message-ID: <20190122104621.khvcpwz6vucmpthr@d104.suse.de>
References: <20190121212747.23029-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190121212747.23029-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, vbabka@suse.cz, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 21, 2019 at 04:27:47PM -0500, Qian Cai wrote:
 
> Fixes: 9f1eb38e0e11 ("mm, kmemleak: little optimization while scanning")
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Qian Cai <cai@lca.pw>

Heh, I guess that it comes in handy to have a machine with CONFIG_HOLES_IN_ZONE
enabled.
I totally missed the fact that systems with such configuration can have
uninitialized pages even if the section is online.
To be honest, I blindly thought that if a section was online, that means
that all its pages were initialized properly.

Thanks for fixing it:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
> 
> v3: change the "Fixes" line.
> v2: update the changelog; keep the bound check; use pfn_valid_within().
> 
>  include/linux/memory_hotplug.h | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 07da5c6c5ba0..cdeecd9bd87e 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -21,14 +21,15 @@ struct vmem_altmap;
>   * walkers which rely on the fully initialized page->flags and others
>   * should use this rather than pfn_valid && pfn_to_page
>   */
> -#define pfn_to_online_page(pfn)				\
> -({							\
> -	struct page *___page = NULL;			\
> -	unsigned long ___nr = pfn_to_section_nr(pfn);	\
> -							\
> -	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr))\
> -		___page = pfn_to_page(pfn);		\
> -	___page;					\
> +#define pfn_to_online_page(pfn)					   \
> +({								   \
> +	struct page *___page = NULL;				   \
> +	unsigned long ___nr = pfn_to_section_nr(pfn);		   \
> +								   \
> +	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> +	    pfn_valid_within(pfn))				   \
> +		___page = pfn_to_page(pfn);			   \
> +	___page;						   \
>  })
>  
>  /*
> -- 
> 2.17.2 (Apple Git-113)
> 

-- 
Oscar Salvador
SUSE L3
