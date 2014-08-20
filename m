Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1156B0038
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 19:32:31 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id j5so5296095qga.13
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 16:32:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gb9si36355141qcb.37.2014.08.20.16.32.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Aug 2014 16:32:30 -0700 (PDT)
Date: Wed, 20 Aug 2014 20:32:21 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 1/7] mm/balloon_compaction: ignore anonymous pages
Message-ID: <20140820233221.GB3457@optiplex.redhat.com>
References: <20140820150435.4194.28003.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140820150435.4194.28003.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-kernel@vger.kernel.org

On Wed, Aug 20, 2014 at 07:04:35PM +0400, Konstantin Khlebnikov wrote:
> Sasha Levin reported KASAN splash inside isolate_migratepages_range().
> Problem is in function __is_movable_balloon_page() which tests AS_BALLOON_MAP
> in page->mapping->flags. This function has no protection against anonymous
> pages. As result it tried to check address space flags in inside anon-vma.
> 
> Signed-off-by: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Link: http://lkml.kernel.org/p/53E6CEAA.9020105@oracle.com
> Cc: stable <stable@vger.kernel.org> # v3.8
> ---
>  include/linux/balloon_compaction.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 089743a..53d482e 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -128,7 +128,7 @@ static inline bool page_flags_cleared(struct page *page)
>  static inline bool __is_movable_balloon_page(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
> -	return mapping_balloon(mapping);
> +	return !PageAnon(page) && mapping_balloon(mapping);
>  }
>  
>  /*
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
