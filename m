Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B89CD6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 01:46:13 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so10269523pdi.16
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 22:46:13 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id oo1si27325276pdb.214.2014.11.30.22.46.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 22:46:12 -0800 (PST)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9FED43EE1D7
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 15:46:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id BCE46AC02C3
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 15:46:08 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A2EAE08006
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 15:46:08 +0900 (JST)
Message-ID: <547C0E4E.4020605@jp.fujitsu.com>
Date: Mon, 1 Dec 2014 15:44:30 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: unmapped page migration avoid unmap+remap overhead
References: <alpine.LSU.2.11.1411302046420.5335@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1411302046420.5335@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2014/12/01 13:52), Hugh Dickins wrote:
> Page migration's __unmap_and_move(), and rmap's try_to_unmap(),
> were created for use on pages almost certainly mapped into userspace.
> But nowadays compaction often applies them to unmapped page cache pages:
> which may exacerbate contention on i_mmap_rwsem quite unnecessarily,
> since try_to_unmap_file() makes no preliminary page_mapped() check.
>
> Now check page_mapped() in __unmap_and_move(); and avoid repeating the
> same overhead in rmap_walk_file() - don't remove_migration_ptes() when
> we never inserted any.
>
> (The PageAnon(page) comment blocks now look even sillier than before,
> but clean that up on some other occasion.  And note in passing that
> try_to_unmap_one() does not use a migration entry when PageSwapCache,
> so remove_migration_ptes() will then not update that swap entry to
> newpage pte: not a big deal, but something else to clean up later.)
>
> Davidlohr remarked in "mm,fs: introduce helpers around the i_mmap_mutex"
> conversion to i_mmap_rwsem, that "The biggest winner of these changes
> is migration": a part of the reason might be all of that unnecessary
> taking of i_mmap_mutex in page migration; and it's rather a shame that
> I didn't get around to sending this patch in before his - this one is
> much less useful after Davidlohr's conversion to rwsem, but still good.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>
>   mm/migrate.c |   28 ++++++++++++++++++----------
>   1 file changed, 18 insertions(+), 10 deletions(-)
>
> --- 3.18-rc7/mm/migrate.c	2014-10-19 22:12:56.809625067 -0700
> +++ linux/mm/migrate.c	2014-11-30 20:17:51.205187663 -0800
> @@ -746,7 +746,7 @@ static int fallback_migrate_page(struct
>    *  MIGRATEPAGE_SUCCESS - success
>    */
>   static int move_to_new_page(struct page *newpage, struct page *page,
> -				int remap_swapcache, enum migrate_mode mode)
> +				int page_was_mapped, enum migrate_mode mode)
>   {
>   	struct address_space *mapping;
>   	int rc;
> @@ -784,7 +784,7 @@ static int move_to_new_page(struct page
>   		newpage->mapping = NULL;
>   	} else {
>   		mem_cgroup_migrate(page, newpage, false);
> -		if (remap_swapcache)
> +		if (page_was_mapped)
>   			remove_migration_ptes(page, newpage);
>   		page->mapping = NULL;
>   	}
> @@ -798,7 +798,7 @@ static int __unmap_and_move(struct page
>   				int force, enum migrate_mode mode)
>   {
>   	int rc = -EAGAIN;
> -	int remap_swapcache = 1;
> +	int page_was_mapped = 0;
>   	struct anon_vma *anon_vma = NULL;
>
>   	if (!trylock_page(page)) {
> @@ -870,7 +870,6 @@ static int __unmap_and_move(struct page
>   			 * migrated but are not remapped when migration
>   			 * completes
>   			 */
> -			remap_swapcache = 0;
>   		} else {
>   			goto out_unlock;
>   		}
> @@ -910,13 +909,17 @@ static int __unmap_and_move(struct page
>   	}
>
>   	/* Establish migration ptes or remove ptes */

> -	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	if (page_mapped(page)) {
> +		try_to_unmap(page,
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +		page_was_mapped = 1;
> +	}

Is there no possibility that page is swap cache? If page is swap cache,
this code changes behavior of move_to_new_page(). Is it O.K.?

Thanks,
Yasuaki Ishimatsu

>
>   skip_unmap:
>   	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
> +		rc = move_to_new_page(newpage, page, page_was_mapped, mode);
>
> -	if (rc && remap_swapcache)
> +	if (rc && page_was_mapped)
>   		remove_migration_ptes(page, page);
>
>   	/* Drop an anon_vma reference if we took one */
> @@ -1017,6 +1020,7 @@ static int unmap_and_move_huge_page(new_
>   {
>   	int rc = 0;
>   	int *result = NULL;
> +	int page_was_mapped = 0;
>   	struct page *new_hpage;
>   	struct anon_vma *anon_vma = NULL;
>
> @@ -1047,12 +1051,16 @@ static int unmap_and_move_huge_page(new_
>   	if (PageAnon(hpage))
>   		anon_vma = page_get_anon_vma(hpage);
>
> -	try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	if (page_mapped(hpage)) {
> +		try_to_unmap(hpage,
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +		page_was_mapped = 1;
> +	}
>
>   	if (!page_mapped(hpage))
> -		rc = move_to_new_page(new_hpage, hpage, 1, mode);
> +		rc = move_to_new_page(new_hpage, hpage, page_was_mapped, mode);
>
> -	if (rc != MIGRATEPAGE_SUCCESS)
> +	if (rc != MIGRATEPAGE_SUCCESS && page_was_mapped)
>   		remove_migration_ptes(hpage, hpage);
>
>   	if (anon_vma)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
