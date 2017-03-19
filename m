Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B59CA6B0038
	for <linux-mm@kvack.org>; Sun, 19 Mar 2017 10:30:18 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n11so11970443wma.5
        for <linux-mm@kvack.org>; Sun, 19 Mar 2017 07:30:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si19161028wrb.21.2017.03.19.07.30.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 19 Mar 2017 07:30:17 -0700 (PDT)
Date: Sun, 19 Mar 2017 10:30:13 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: use BITS_PER_LONG to unify the definition in
 page->flags
Message-ID: <20170319143012.GB12414@dhcp22.suse.cz>
References: <20170318003914.24839-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170318003914.24839-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 18-03-17 08:39:14, Wei Yang wrote:
> The field page->flags is defined as unsigned long and is divided into
> several parts to store different information of the page, like section,
> node, zone. Which means all parts must sit in the one "unsigned
> long".
> 
> BITS_PER_LONG is used in several places to ensure this applies.
> 
>     #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > BITS_PER_LONG - NR_PAGEFLAGS
>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
>     #if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
> 
> While we use "sizeof(unsigned long) * 8" in the definition of
> SECTIONS_PGOFF
> 
>     #define SECTIONS_PGOFF         ((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> 
> This may not be that obvious for audience to catch the point.
> 
> This patch replaces the "sizeof(unsigned long) * 8" with BITS_PER_LONG to
> make all this consistent.

I am not really sure this is an improvement. page::flags is unsigned
long nad the current code reflects that type.

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/mm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b84615b0f64c..a5d80de089ff 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -684,7 +684,7 @@ int finish_mkwrite_fault(struct vm_fault *vmf);
>   */
>  
>  /* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPUPID] | ... | FLAGS | */
> -#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> +#define SECTIONS_PGOFF		(BITS_PER_LONG - SECTIONS_WIDTH)
>  #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
>  #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
>  #define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
> -- 
> 2.11.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
