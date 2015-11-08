Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B220E6B0253
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 16:29:15 -0500 (EST)
Received: by padhx2 with SMTP id hx2so168426336pad.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 13:29:15 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id sp3si17622058pbc.195.2015.11.08.13.29.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 13:29:14 -0800 (PST)
Received: by pasz6 with SMTP id z6so181687628pas.2
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 13:29:14 -0800 (PST)
Date: Sun, 8 Nov 2015 13:29:12 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/5] mm, page_owner: copy page owner info during
 migration
In-Reply-To: <1446649261-27122-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.LSU.2.11.1511081318110.12914@eggly.anvils>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz> <1446649261-27122-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, 4 Nov 2015, Vlastimil Babka wrote:

> The page_owner mechanism stores gfp_flags of an allocation and stack trace
> that lead to it. During page migration, the original information is
> essentially replaced by the allocation of free page as the migration target.
> Arguably this is less useful and might lead to all the page_owner info for
> migratable pages gradually converge towards compaction or numa balancing
> migrations. It has also lead to inaccuracies such as one fixed by commit
> e2cfc91120fa ("mm/page_owner: set correct gfp_mask on page_owner").
> 
> This patch thus introduces copying the page_owner info during migration.
> However, since the fact that the page has been migrated from its original
> place might be useful for debugging, the next patch will introduce a way to
> track that information as well.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  include/linux/page_owner.h | 10 +++++++++-
>  mm/migrate.c               |  2 ++
>  mm/page_owner.c            | 16 ++++++++++++++++
>  3 files changed, 27 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
> index 8e2eb15..6440daa 100644
> --- a/include/linux/page_owner.h
> +++ b/include/linux/page_owner.h
> @@ -11,6 +11,7 @@ extern void __reset_page_owner(struct page *page, unsigned int order);
>  extern void __set_page_owner(struct page *page,
>  			unsigned int order, gfp_t gfp_mask);
>  extern gfp_t __get_page_owner_gfp(struct page *page);
> +extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
>  
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -32,6 +33,11 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
>  	else
>  		return 0;
>  }
> +static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
> +{
> +	if (static_branch_unlikely(&page_owner_inited))
> +		__copy_page_owner(oldpage, newpage);
> +}
>  #else
>  static inline void reset_page_owner(struct page *page, unsigned int order)
>  {
> @@ -44,6 +50,8 @@ static inline gfp_t get_page_owner_gfp(struct page *page)
>  {
>  	return 0;
>  }
> -
> +static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
> +{
> +}
>  #endif /* CONFIG_PAGE_OWNER */
>  #endif /* __LINUX_PAGE_OWNER_H */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 1ae0113..9f82e03 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -38,6 +38,7 @@
>  #include <linux/balloon_compaction.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/page_idle.h>
> +#include <linux/page_owner.h>
>  
>  #include <asm/tlbflush.h>
>  
> @@ -775,6 +776,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
>  		set_page_memcg(page, NULL);
>  		if (!PageAnon(page))
>  			page->mapping = NULL;
> +		copy_page_owner(page, newpage);

Would it be possible to move that line into migrate_page_copy()?

I don't think it's wrong where you placed it, but that block is really
about resetting the old page ready for freeing, and I'd prefer to keep
all the transference of properties from old to new in migrate_page_copy()
if we can.

But check how that behaves in the migrate_misplaced_transhuge_page()
case: I haven't studied long enough, but I think you may have been missing
to copy_page_owner in that case; but beware of its "fail_putback", which
for some things nastily entails undoing what's already been done.

Hugh

>  	}
>  	return rc;
>  }
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 7664b85..7ebd3d0 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -84,6 +84,22 @@ gfp_t __get_page_owner_gfp(struct page *page)
>  	return page_ext->gfp_mask;
>  }
>  
> +void __copy_page_owner(struct page *oldpage, struct page *newpage)
> +{
> +	struct page_ext *old_ext = lookup_page_ext(oldpage);
> +	struct page_ext *new_ext = lookup_page_ext(newpage);
> +	int i;
> +
> +	new_ext->order = old_ext->order;
> +	new_ext->gfp_mask = old_ext->gfp_mask;
> +	new_ext->nr_entries = old_ext->nr_entries;
> +
> +	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
> +		new_ext->trace_entries[i] = old_ext->trace_entries[i];
> +
> +	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
> +}
> +
>  static ssize_t
>  print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  		struct page *page, struct page_ext *page_ext)
> -- 
> 2.6.2
> 
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
