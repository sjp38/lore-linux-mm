Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7AC6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 21:54:31 -0500 (EST)
Received: by qgea14 with SMTP id a14so64851629qge.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:54:30 -0800 (PST)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com. [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id s19si9291128qki.89.2015.11.19.18.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 18:54:22 -0800 (PST)
Received: by qgea14 with SMTP id a14so64850228qge.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 18:54:22 -0800 (PST)
Date: Thu, 19 Nov 2015 21:54:13 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 6/8] userfaultfd: hook userfault handler to write
 protection fault
Message-ID: <20151120025403.GA3093@gmail.com>
References: <cover.1447964595.git.shli@fb.com>
 <8b39e7027b26de92477a83d8145e22eb5f3b6989.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8b39e7027b26de92477a83d8145e22eb5f3b6989.1447964595.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 19, 2015 at 02:33:51PM -0800, Shaohua Li wrote:
> There are several cases write protection fault happens. It could be a write
> to zero page, swaped page or userfault write protected page. When the
> fault happens, there is no way to know if userfault write protect the
> page before. Here we just blindly issue a userfault notification for vma
> with VM_UFFD_WP regardless if app write protects it yet. Application
> should be ready to handle such wp fault.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  mm/memory.c | 66 +++++++++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 49 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index deb679c..5d16a31 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1994,10 +1994,11 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>  			struct vm_area_struct *vma, unsigned long address,
>  			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
>  			struct page *page, int page_mkwrite,
> -			int dirty_shared)
> +			int dirty_shared, unsigned int flags)
>  	__releases(ptl)
>  {
>  	pte_t entry;
> +	bool do_uffd = false;
>  	/*
>  	 * Clear the pages cpupid information as the existing
>  	 * information potentially belongs to a now completely
> @@ -2008,10 +2009,16 @@ static inline int wp_page_reuse(struct mm_struct *mm,
>  
>  	flush_cache_page(vma, address, pte_pfn(orig_pte));
>  	entry = pte_mkyoung(orig_pte);
> -	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	if (userfaultfd_wp(vma) && page) {
> +		entry = pte_mkdirty(entry);


Why do you pte_mkdirty() it makes no sense to me unless i am missing something.
In fact, IIRC, userfaultd is only concerning private anonymous vma so you should
only need to modify 3 places. do_anonymous_page(), do_swap_page() and do_wp_page()

You also want to hook in wp_huge_pmd() and __do_huge_pmd_anonymous_page() to
properly cover THP.

So i think you need to simplify this patch and make sure you handle THP properly.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
