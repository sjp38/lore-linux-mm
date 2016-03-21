Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id C392A6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:45:24 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l68so108503678wml.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:45:24 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id w8si30914917wjz.7.2016.03.21.05.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 05:45:23 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id l68so21630511wml.3
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:45:23 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:45:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, fs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160321124522.GC23066@dhcp22.suse.cz>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon 21-03-16 15:06:36, Kirill A. Shutemov wrote:
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
>  - <foo> >> (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;
> 
>  - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};
> 
>  - page_cache_get() -> get_page();
> 
>  - page_cache_release() -> put_page();
> 
> This patch contains automated changes generated with coccinelle using
> script below. For some reason, coccinelle doesn't patch header files.
> I've called spatch for them manually.
> 
> The only adjustment after coccinelle is revert of changes to
> PAGE_CAHCE_ALIGN definition: we are going to drop it later.
> 
> There are few places in the code where coccinelle didn't reach.
> I'll fix them manually in a separate patch. Comments and documentation
> also will be addressed with the separate patch.
> 
> virtual patch
> 
> @@
> expression E;
> @@
> - E << (PAGE_CACHE_SHIFT - PAGE_SHIFT)
> + E
> 
> @@
> expression E;
> @@
> - E >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)
> + E
> 
> @@
> @@
> - PAGE_CACHE_SHIFT
> + PAGE_SHIFT
> 
> @@
> @@
> - PAGE_CACHE_SIZE
> + PAGE_SIZE
> 
> @@
> @@
> - PAGE_CACHE_MASK
> + PAGE_MASK
> 
> @@
> expression E;
> @@
> - PAGE_CACHE_ALIGN(E)
> + PAGE_ALIGN(E)
> 
> @@
> expression E;
> @@
> - page_cache_get(E)
> + get_page(E)
> 
> @@
> expression E;
> @@
> - page_cache_release(E)
> + put_page(E)
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

It is great to see PAGE_CACHE_* going away finally.
It is even better that a large part of the removal could be automated.
The semantic patch makes sense to me.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
