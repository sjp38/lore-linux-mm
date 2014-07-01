Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 97B016B003C
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 14:07:57 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so10033708wes.9
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 11:07:57 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id b6si29006789wjy.38.2014.07.01.11.07.51
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 11:07:51 -0700 (PDT)
Date: Tue, 1 Jul 2014 21:07:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
Message-ID: <20140701180739.GA4985@node.dhcp.inet.fi>
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 01, 2014 at 10:46:22AM -0400, Naoya Horiguchi wrote:
> I triggered VM_BUG_ON() in vma_address() when I try to migrate an anonymous
> hugepage with mbind() in the kernel v3.16-rc3. This is because pgoff's
> calculation in rmap_walk_anon() fails to consider compound_order() only to
> have an incorrect value. So this patch fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git v3.16-rc3.orig/mm/rmap.c v3.16-rc3/mm/rmap.c
> index b7e94ebbd09e..8cc964c6bd8d 100644
> --- v3.16-rc3.orig/mm/rmap.c
> +++ v3.16-rc3/mm/rmap.c
> @@ -1639,7 +1639,7 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
>  static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
>  {
>  	struct anon_vma *anon_vma;
> -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	pgoff_t pgoff = page->index << compound_order(page);
>  	struct anon_vma_chain *avc;
>  	int ret = SWAP_AGAIN;

Hm. It will not work with THP: ->index there is in PAGE_SIZE units.

Why do we need this special case for hugetlb page ->index? Why not use
PAGE_SIZE units there too? Or I miss something?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
