Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0E48B6B025F
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 06:14:54 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id 127so14630679wmu.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 03:14:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g139si16815197wmd.7.2016.04.01.03.14.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 03:14:53 -0700 (PDT)
Subject: Re: [PATCH 2/2] UBIFS: Implement ->migratepage()
References: <1459461513-31765-1-git-send-email-richard@nod.at>
 <1459461513-31765-3-git-send-email-richard@nod.at>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE4A1B.606@suse.cz>
Date: Fri, 1 Apr 2016 12:14:51 +0200
MIME-Version: 1.0
In-Reply-To: <1459461513-31765-3-git-send-email-richard@nod.at>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net

On 03/31/2016 11:58 PM, Richard Weinberger wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> During page migrations UBIFS might get confused
> and the following assert triggers:
> UBIFS assert failed in ubifs_set_page_dirty at 1451 (pid 436)

It would be useful to have the full trace in changelog.

> UBIFS is using PagePrivate() which can have different meanings across
> filesystems. Therefore the generic page migration code cannot handle this
> case correctly.
> We have to implement our own migration function which basically does a
> plain copy but also duplicates the page private flag.
> UBIFS is not a block device filesystem and cannot use buffer_migrate_page().
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> [rw: Massaged changelog]
> Signed-off-by: Richard Weinberger <richard@nod.at>

Stable?

> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>   fs/ubifs/file.c | 20 ++++++++++++++++++++
>   1 file changed, 20 insertions(+)
>
> diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
> index 065c88f..5eea5f5 100644
> --- a/fs/ubifs/file.c
> +++ b/fs/ubifs/file.c
> @@ -52,6 +52,7 @@
>   #include "ubifs.h"
>   #include <linux/mount.h>
>   #include <linux/slab.h>
> +#include <linux/migrate.h>
>
>   static int read_block(struct inode *inode, void *addr, unsigned int block,
>   		      struct ubifs_data_node *dn)
> @@ -1452,6 +1453,24 @@ static int ubifs_set_page_dirty(struct page *page)
>   	return ret;
>   }
>
> +static int ubifs_migrate_page(struct address_space *mapping,
> +		struct page *newpage, struct page *page, enum migrate_mode mode)
> +{
> +	int rc;
> +
> +	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, mode, 0);
> +	if (rc != MIGRATEPAGE_SUCCESS)
> +		return rc;
> +
> +	if (PagePrivate(page)) {
> +		ClearPagePrivate(page);
> +		SetPagePrivate(newpage);
> +	}
> +
> +	migrate_page_copy(newpage, page);
> +	return MIGRATEPAGE_SUCCESS;
> +}
> +
>   static int ubifs_releasepage(struct page *page, gfp_t unused_gfp_flags)
>   {
>   	/*
> @@ -1591,6 +1610,7 @@ const struct address_space_operations ubifs_file_address_operations = {
>   	.write_end      = ubifs_write_end,
>   	.invalidatepage = ubifs_invalidatepage,
>   	.set_page_dirty = ubifs_set_page_dirty,
> +	.migratepage	= ubifs_migrate_page,
>   	.releasepage    = ubifs_releasepage,
>   };
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
