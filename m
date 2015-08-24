Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E25F96B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:42:05 -0400 (EDT)
Received: by labgv11 with SMTP id gv11so8702201lab.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:42:05 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id jj4si13009258lbc.66.2015.08.24.05.42.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 05:42:03 -0700 (PDT)
Message-ID: <55DB1116.2090900@yandex-team.ru>
Date: Mon, 24 Aug 2015 15:41:58 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: use only per-device readahead limit
References: <CA+55aFy8kOomnL-C5GwSpHTn+g5R7dY78C9=h-J_Rb_u=iASpg@mail.gmail.com> <1440417438-12578-1-git-send-email-klamm@yandex-team.ru>
In-Reply-To: <1440417438-12578-1-git-send-email-klamm@yandex-team.ru>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 24.08.2015 14:57, Roman Gushchin wrote:
> Maximal readahead size is limited now by two values:
> 1) by global 2Mb constant (MAX_READAHEAD in max_sane_readahead())
> 2) by configurable per-device value* (bdi->ra_pages)
>
> There are devices, which require custom readahead limit.
> For instance, for RAIDs it's calculated as number of devices
> multiplied by chunk size times 2.
>
> Readahead size can never be larger than bdi->ra_pages * 2 value
> (POSIX_FADV_SEQUNTIAL doubles readahead size).
>
> If so, why do we need two limits?
> I suggest to completely remove this max_sane_readahead() stuff and
> use per-device readahead limit everywhere.
>
> Also, using right readahead size for RAID disks can significantly
> increase i/o performance:
>
> before:
> dd if=/dev/md2 of=/dev/null bs=100M count=100
> 100+0 records in
> 100+0 records out
> 10485760000 bytes (10 GB) copied, 12.9741 s, 808 MB/s
>
> after:
> $ dd if=/dev/md2 of=/dev/null bs=100M count=100
> 100+0 records in
> 100+0 records out
> 10485760000 bytes (10 GB) copied, 8.91317 s, 1.2 GB/s
>
> (It's an 8-disks RAID5 storage).
>
> This patch doesn't change sys_readahead and madvise(MADV_WILLNEED)
> behavior introduced by commit
> 6d2be915e589b58cb11418cbe1f22ff90732b6ac ("mm/readahead.c: fix
> readahead failure for memoryless NUMA nodes and limit readahead pages").
>
> V2:
> Konstantin Khlebnikov noticed, that if readahead is completely
> disabled, force_page_cache_readahead() will not read anything.
> This function is used for sync reads (if FMODE_RANDOM flag is set).
> So, to guarantee read progress it's necessary to read at least 1 page.

After second thought: this isn't important. V1 is fine.

page_cache_sync_readahead checks "if (!ra->ra_pages)" before and
never calls force_page_cache_readahead if readahead is disabled.

Anyway, this function doesn't return references to pages. All
users must be ready to handle non-present or non-uptodate pages.
But this probably never happened before so all callsites should
be reviewed: for example splice always re-lookups pages after
->readpage() (I guess page can be truncated here) while some
other users use the same page reference.

>
> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>   include/linux/mm.h |  2 --
>   mm/filemap.c       |  8 +++-----
>   mm/readahead.c     | 18 ++++++------------
>   3 files changed, 9 insertions(+), 19 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2e872f9..a62abdd 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1942,8 +1942,6 @@ void page_cache_async_readahead(struct address_space *mapping,
>   				pgoff_t offset,
>   				unsigned long size);
>
> -unsigned long max_sane_readahead(unsigned long nr);
> -
>   /* Generic expand stack which grows the stack according to GROWS{UP,DOWN} */
>   extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1283fc8..0e1ebef 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1807,7 +1807,6 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>   				   struct file *file,
>   				   pgoff_t offset)
>   {
> -	unsigned long ra_pages;
>   	struct address_space *mapping = file->f_mapping;
>
>   	/* If we don't want any read-ahead, don't bother */
> @@ -1836,10 +1835,9 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>   	/*
>   	 * mmap read-around
>   	 */
> -	ra_pages = max_sane_readahead(ra->ra_pages);
> -	ra->start = max_t(long, 0, offset - ra_pages / 2);
> -	ra->size = ra_pages;
> -	ra->async_size = ra_pages / 4;
> +	ra->start = max_t(long, 0, offset - ra->ra_pages / 2);
> +	ra->size = ra->ra_pages;
> +	ra->async_size = ra->ra_pages / 4;
>   	ra_submit(ra, mapping, file);
>   }
>
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 60cd846..7eb844c 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -213,7 +213,11 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>   	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
>   		return -EINVAL;
>
> -	nr_to_read = max_sane_readahead(nr_to_read);
> +	/*
> +	 * Read at least 1 page, even if readahead is completely disabled.
> +	 */
> +	nr_to_read = min(nr_to_read, max(inode_to_bdi(mapping->host)->ra_pages,
> +					 1ul));
>   	while (nr_to_read) {
>   		int err;
>
> @@ -232,16 +236,6 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>   	return 0;
>   }
>
> -#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
> -/*
> - * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> - * sensible upper limit.
> - */
> -unsigned long max_sane_readahead(unsigned long nr)
> -{
> -	return min(nr, MAX_READAHEAD);
> -}
> -
>   /*
>    * Set the initial window size, round to next power of 2 and square
>    * for small size, x 4 for medium, and x 2 for large
> @@ -380,7 +374,7 @@ ondemand_readahead(struct address_space *mapping,
>   		   bool hit_readahead_marker, pgoff_t offset,
>   		   unsigned long req_size)
>   {
> -	unsigned long max = max_sane_readahead(ra->ra_pages);
> +	unsigned long max = ra->ra_pages;
>   	pgoff_t prev_offset;
>
>   	/*
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
