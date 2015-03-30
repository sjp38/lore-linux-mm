Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 09E3E6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:20:49 -0400 (EDT)
Received: by patj18 with SMTP id j18so12578046pat.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:20:48 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id ch2si14985150pbb.13.2015.03.30.07.20.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 07:20:47 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 31 Mar 2015 00:20:42 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BE307357804C
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 01:20:37 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2UEKSno43581504
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 01:20:37 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2UEK2dS026685
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 01:20:03 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 19/24] thp, mm: use migration entries to freeze page counts on split
In-Reply-To: <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com> <1425486792-93161-20-git-send-email-kirill.shutemov@linux.intel.com>
Date: Mon, 30 Mar 2015 19:49:43 +0530
Message-ID: <87k2xylg8w.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> Currently, we rely on compound_lock() to get page counts stable on
> splitting page refcounting. To get it work we also take the lock on
> get_page() and put_page() which is hot path.
>
> This patch rework splitting code to setup migration entries to stabilaze
> page count/mapcount before distribute refcounts. It means we don't need
> to compound lock in get_page()/put_page().
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/migrate.h |   3 +
>  include/linux/mm.h      |   1 +
>  include/linux/pagemap.h |   9 ++-
>  mm/huge_memory.c        | 188 +++++++++++++++++++++++++++++++++++-------------
>  mm/internal.h           |  26 +++++--
>  mm/migrate.c            |  79 +++++++++++---------
>  mm/rmap.c               |  21 ------
>  7 files changed, 218 insertions(+), 109 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 78baed5f2952..b9bc86c24829 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -43,6 +43,9 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
>  		struct page *newpage, struct page *page,
>  		struct buffer_head *head, enum migrate_mode mode,
>  		int extra_count);
> +extern int __remove_migration_pte(struct page *new, struct vm_area_struct *vma,
> +		unsigned long addr, pte_t *ptep, struct page *old);
> +
>  #else
>
>  static inline void putback_movable_pages(struct list_head *l) {}
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 28aeae6e553b..43a9993f1333 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -981,6 +981,7 @@ extern struct address_space *page_mapping(struct page *page);
>  /* Neutral page->mapping pointer to address_space or anon_vma or other */
>  static inline void *page_rmapping(struct page *page)
>  {
> +	page = compound_head(page);
>  	return (void *)((unsigned long)page->mapping & ~PAGE_MAPPING_FLAGS);
>  }
>

The above hunk is related to this patch ?. Are we calling page_rmapping
on tail pages now ? If so it needs additonal comment why we handle them
differently now. Or split it to a seperate patch ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
