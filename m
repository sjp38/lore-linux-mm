Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 73A2082F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 19:07:13 -0400 (EDT)
Received: by pabws5 with SMTP id ws5so2477141pab.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:07:13 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id si2si32413661pac.230.2015.10.16.16.07.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 16:07:12 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so132561044pab.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:07:12 -0700 (PDT)
Date: Fri, 16 Oct 2015 16:07:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] mm: use unsigned int for page order fix 2
In-Reply-To: <20151016160050.621082b8b1080c28487e764f@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1510161603420.31270@eggly.anvils>
References: <alpine.LSU.2.11.1510161546430.31102@eggly.anvils> <20151016160050.621082b8b1080c28487e764f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 16 Oct 2015, Andrew Morton wrote:
> On Fri, 16 Oct 2015 15:51:34 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> 
> > Some configs now end up with MAX_ORDER and pageblock_order having
> > different types: silence compiler warning in __free_one_page().
> > 
> > ...
> >
> > @@ -679,7 +679,7 @@ static inline void __free_one_page(struc
> >  		 * pageblock. Without this, pageblock isolation
> >  		 * could cause incorrect freepage accounting.
> >  		 */
> > -		max_order = min(MAX_ORDER, pageblock_order + 1);
> > +		max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
> >  	} else {
> >  		__mod_zone_freepage_state(zone, 1 << order, migratetype);
> >  	}
> 
> Well.  If we're ordaining that "page order has type uint" then can we
> do that more consistently?  Something like

Yes, if we are going this way, then it is better to be thorough than
patch around it as I did.  (But personally I think the exercise is a
waste of time, so I just took the quickest way out, sorry.)

Hugh

> 
> --- a/include/linux/mmzone.h~a
> +++ a/include/linux/mmzone.h
> @@ -21,9 +21,9 @@
>  
>  /* Free memory management - zoned buddy allocator.  */
>  #ifndef CONFIG_FORCE_MAX_ZONEORDER
> -#define MAX_ORDER 11
> +#define MAX_ORDER 11U
>  #else
> -#define MAX_ORDER CONFIG_FORCE_MAX_ZONEORDER
> +#define MAX_ORDER ((unsigned int)CONFIG_FORCE_MAX_ZONEORDER)
>  #endif
>  #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
>  
> diff -puN include/linux/pageblock-flags.h~a include/linux/pageblock-flags.h
> --- a/include/linux/pageblock-flags.h~a
> +++ a/include/linux/pageblock-flags.h
> @@ -49,7 +49,7 @@ extern unsigned int pageblock_order;
>  #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>  
>  /* Huge pages are a constant size */
> -#define pageblock_order		HUGETLB_PAGE_ORDER
> +#define pageblock_order		((unsigned int)HUGETLB_PAGE_ORDER)
>  
>  #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>  
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
