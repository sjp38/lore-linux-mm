Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBAE6B0005
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 20:00:01 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id fp4so162675348obb.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 17:00:01 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id wu9si7662574obb.46.2016.03.20.17.00.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Mar 2016 17:00:00 -0700 (PDT)
Date: Sun, 20 Mar 2016 16:59:58 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 70/71] mm: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160320235958.GA20915@roeck-us.net>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-71-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458499278-1516-71-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun, Mar 20, 2016 at 09:41:17PM +0300, Kirill A. Shutemov wrote:
> PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
> with promise that one day it will be possible to implement page cache with
> bigger chunks than PAGE_SIZE.
> 
> This promise never materialized. And unlikely will.
> 
> We have many places where PAGE_CACHE_SIZE assumed to be equal to
> PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
> or PAGE_* constant should be used in a particular case, especially on the
> border between fs and mm.
> 
> Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
> breakage to be doable.
> 
> Let's stop pretending that pages in page cache are special. They are not.
> 
> The changes are pretty straight-forward:
> 
>  - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;
> 
>  - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};
> 
>  - page_cache_get() -> get_page();
> 
>  - page_cache_release() -> put_page();
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---

...

>  extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
> @@ -425,7 +425,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>  		return linear_hugepage_index(vma, address);
>  	pgoff = (address - vma->vm_start) >> PAGE_SHIFT;
>  	pgoff += vma->vm_pgoff;
> -	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	return pgoff >> (PAGE_SHIFT - PAGE_SHIFT);
                        ^^^^^^^^^^^^^^^^^^^^^^^^^

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
