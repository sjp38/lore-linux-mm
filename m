Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id B1A316B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:48:51 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z12so103218yhz.1
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:48:51 -0800 (PST)
Received: from mail-gg0-x235.google.com (mail-gg0-x235.google.com [2607:f8b0:4002:c02::235])
        by mx.google.com with ESMTPS id t26si1345342yhg.292.2014.01.14.18.48.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 18:48:50 -0800 (PST)
Received: by mail-gg0-f181.google.com with SMTP id 21so350105ggh.12
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:48:50 -0800 (PST)
Date: Tue, 14 Jan 2014 18:48:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 4/9] mm: slabs: reset page at free
In-Reply-To: <20140114180054.20A1B660@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1401141847230.32645@chino.kir.corp.google.com>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180054.20A1B660@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> diff -puN include/linux/mm.h~slub-reset-page-at-free include/linux/mm.h
> --- a/include/linux/mm.h~slub-reset-page-at-free	2014-01-14 09:57:57.099666808 -0800
> +++ b/include/linux/mm.h	2014-01-14 09:57:57.110667301 -0800
> @@ -2076,5 +2076,16 @@ static inline void set_page_pfmemalloc(s
>  	page->index = pfmemalloc;
>  }
>  
> +/*
> + * Custom allocators (like the slabs) use 'struct page' fields
> + * for all kinds of things.  This resets the page's state so that
> + * the buddy allocator will be happy with it.
> + */
> +static inline void allocator_reset_page(struct page *page)

This is ambiguous as to what "allocator" you're referring to unless we 
look at the comment.  I think it would be better to name it 
slab_reset_page() or something similar.

> +{
> +	page->mapping = NULL;
> +	page_mapcount_reset(page);
> +}
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
