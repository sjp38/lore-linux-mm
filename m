Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46BEE6B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 12:34:41 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e204so122170wma.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 09:34:41 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id g4si4007692ede.335.2017.08.09.09.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 09:34:38 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id q189so123489wmd.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 09:34:38 -0700 (PDT)
Date: Wed, 9 Aug 2017 19:34:34 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/rmap: try_to_unmap_one() do not call mmu_notifier
 under ptl
Message-ID: <20170809163434.p356oyarqpqh52hu@node.shutemov.name>
References: <20170809161709.9278-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170809161709.9278-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 09, 2017 at 12:17:09PM -0400, jglisse@redhat.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> MMU notifiers can sleep, but in try_to_unmap_one() we call
> mmu_notifier_invalidate_page() under page table lock.
> 
> Let's instead use mmu_notifier_invalidate_range() outside
> page_vma_mapped_walk() loop.
> 
> Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()")
> ---
>  mm/rmap.c | 36 +++++++++++++++++++++---------------
>  1 file changed, 21 insertions(+), 15 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index aff607d5f7d2..d60e887f1cda 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1329,7 +1329,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	};
>  	pte_t pteval;
>  	struct page *subpage;
> -	bool ret = true;
> +	bool ret = true, invalidation_needed = false;
> +	unsigned long end = address + PAGE_SIZE;

I think it should be 'address + (1UL << compound_order(page))'.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
