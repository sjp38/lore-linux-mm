Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6B1586B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 21:06:04 -0500 (EST)
Received: by ghrr18 with SMTP id r18so3352889ghr.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 18:06:03 -0800 (PST)
Date: Sun, 18 Dec 2011 11:05:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 08/11] mm: compaction: Introduce sync-light migration for
 use by compaction
Message-ID: <20111218020552.GB13069@barrios-laptop.redhat.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-9-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323877293-15401-9-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 14, 2011 at 03:41:30PM +0000, Mel Gorman wrote:
> This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
> mode that avoids writing back pages to backing storage. Async
> compaction maps to MIGRATE_ASYNC while sync compaction maps to
> MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
> hotplug, MIGRATE_SYNC is used.
> 
> This avoids sync compaction stalling for an excessive length of time,
> particularly when copying files to a USB stick where there might be
> a large number of dirty pages backed by a filesystem that does not
> support ->writepages.
> 
> [aarcange@redhat.com: This patch is heavily based on Andrea's work]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  fs/btrfs/disk-io.c      |    3 +-
>  fs/hugetlbfs/inode.c    |    2 +-
>  fs/nfs/internal.h       |    2 +-
>  fs/nfs/write.c          |    2 +-
>  include/linux/fs.h      |    6 ++-
>  include/linux/migrate.h |   23 +++++++++++---
>  mm/compaction.c         |    2 +-
>  mm/memory-failure.c     |    2 +-
>  mm/memory_hotplug.c     |    2 +-
>  mm/mempolicy.c          |    2 +-
>  mm/migrate.c            |   78 ++++++++++++++++++++++++++---------------------
>  11 files changed, 74 insertions(+), 50 deletions(-)
> 
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 896b87a..dbe9518 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -872,7 +872,8 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
>  
>  #ifdef CONFIG_MIGRATION
>  static int btree_migratepage(struct address_space *mapping,
> -			struct page *newpage, struct page *page, bool sync)
> +			struct page *newpage, struct page *page,
> +			enum migrate_mode sync)
>  {
>  	/*
>  	 * we can't safely write a btree page from here,
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 10b9883..6b80537 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -577,7 +577,7 @@ static int hugetlbfs_set_page_dirty(struct page *page)
>  
>  static int hugetlbfs_migrate_page(struct address_space *mapping,
>  				struct page *newpage, struct page *page,
> -				bool sync)
> +				enum migrate_mode mode)

Nitpick, except this one, we use enum migrate_mode sync.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
