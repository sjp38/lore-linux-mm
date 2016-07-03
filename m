Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 181246B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 01:59:21 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id b13so286448191pat.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 22:59:21 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id b188si2217924pfa.90.2016.07.02.22.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jul 2016 22:59:20 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i123so13533830pfg.3
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 22:59:20 -0700 (PDT)
Date: Sun, 3 Jul 2016 14:59:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] mm/page_owner: track page free call chain
Message-ID: <20160703055924.GA513@swordfish>
References: <20160702161656.14071-1-sergey.senozhatsky@gmail.com>
 <20160702161656.14071-4-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160702161656.14071-4-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (07/03/16 01:16), Sergey Senozhatsky wrote:
[..]
> +#ifdef CONFIG_PAGE_OWNER_TRACK_FREE
> +void __page_owner_free_pages(struct page *page, unsigned int order)
> +{
> +	int i;
> +	depot_stack_handle_t handle;
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +
> +	if (unlikely(!page_ext))
> +		return;
> +
> +	handle = save_stack(0);
> +	page_ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
> +	__set_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags);
> +
> +	for (i = 1; i < (1 << order); i++) {
> +		struct page_ext *ext = lookup_page_ext(page + 1);
> +
> +		if (unlikely(!ext))
> +			continue;
> +		ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
> +		__set_bit(PAGE_EXT_OWNER_FREE, &ext->flags);
> +	}
> +}

I think this one is missing __clear_bit(PAGE_EXT_OWNER_ALLOC).

---
 mm/page_owner.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 5a108d6..699922c 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -154,6 +154,7 @@ void __page_owner_free_pages(struct page *page, unsigned int order)
 	handle = save_stack(0);
 	page_ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
 	__set_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags);
+	__clear_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
 
 	for (i = 1; i < (1 << order); i++) {
 		struct page_ext *ext = lookup_page_ext(page + 1);
@@ -162,6 +163,7 @@ void __page_owner_free_pages(struct page *page, unsigned int order)
 			continue;
 		ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
 		__set_bit(PAGE_EXT_OWNER_FREE, &ext->flags);
+		__clear_bit(PAGE_EXT_OWNER_ALLOC, &ext->flags);
 	}
 }
 #else
-- 
2.9.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
