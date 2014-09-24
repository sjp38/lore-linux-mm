Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 252496B0038
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:12:40 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id em10so7009117wid.11
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:12:39 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id cy9si7048487wib.37.2014.09.24.07.12.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 07:12:38 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id q5so7360573wiv.4
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:12:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411344191-2842-4-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org> <1411344191-2842-4-git-send-email-minchan@kernel.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 24 Sep 2014 10:12:18 -0400
Message-ID: <CALZtOND9YOXPQ0vNKFVrs+yhnkbWkKg8FD78cHmqJWhLyo89Gw@mail.gmail.com>
Subject: Re: [PATCH v1 3/5] mm: VM can be aware of zram fullness
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Sun, Sep 21, 2014 at 8:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> VM uses nr_swap_pages to throttle amount of swap when it reclaims
> anonymous pages because the nr_swap_pages means freeable space
> of swap disk.
>
> However, it's a problem for zram because zram can limit memory
> usage by knob(ie, mem_limit) so that swap out can fail although
> VM can see lots of free space from zram disk but no more free
> space in zram by the limit. If it happens, VM should notice it
> and stop reclaimaing until zram can obtain more free space but
> we don't have a way to communicate between VM and zram.
>
> This patch adds new hint SWAP_FULL so that zram can say to VM
> "I'm full" from now on. Then VM cannot reclaim annoymous page
> any more. If VM notice swap is full, it can remove swap_info_struct
> from swap_avail_head and substract remained freeable space from
> nr_swap_pages so that VM can think swap is full until VM frees a
> swap and increase nr_swap_pages again.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/blkdev.h |  1 +
>  mm/swapfile.c          | 44 ++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 39 insertions(+), 6 deletions(-)
>
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index c7220409456c..39f074e0acd7 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -1611,6 +1611,7 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
>
>  enum swap_blk_hint {
>         SWAP_FREE,
> +       SWAP_FULL,
>  };
>
>  struct block_device_operations {
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 209112cf8b83..71e3df0431b6 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -493,6 +493,29 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
>         int latency_ration = LATENCY_LIMIT;
>
>         /*
> +        * If zram is full, we don't need to scan and want to stop swap.
> +        * For it, we removes si from swap_avail_head and decreases
> +        * nr_swap_pages to prevent further anonymous reclaim so that
> +        * VM can restart swap out if zram has a free space.
> +        * Look at swap_entry_free.
> +        */
> +       if (si->flags & SWP_BLKDEV) {
> +               struct gendisk *disk = si->bdev->bd_disk;
> +
> +               if (disk->fops->swap_hint && disk->fops->swap_hint(
> +                               si->bdev, SWAP_FULL, NULL)) {
> +                       spin_lock(&swap_avail_lock);
> +                       WARN_ON(plist_node_empty(&si->avail_list));
> +                       plist_del(&si->avail_list, &swap_avail_head);
> +                       spin_unlock(&swap_avail_lock);
> +                       atomic_long_sub(si->pages - si->inuse_pages,
> +                                               &nr_swap_pages);
> +                       si->full = true;
> +                       return 0;
> +               }
> +       }
> +
> +       /*
>          * We try to cluster swap pages by allocating them sequentially
>          * in swap.  Once we've allocated SWAPFILE_CLUSTER pages this
>          * way, however, we resort to first-free allocation, starting
> @@ -798,6 +821,14 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
>         /* free if no reference */
>         if (!usage) {
>                 bool was_full;
> +               struct gendisk *virt_swap = NULL;
> +
> +               /* Check virtual swap */
> +               if (p->flags & SWP_BLKDEV) {
> +                       virt_swap = p->bdev->bd_disk;
> +                       if (!virt_swap->fops->swap_hint)

not a big deal, but can't you just combine these two if's to simplify this?

> +                               virt_swap = NULL;
> +               }
>
>                 dec_cluster_info_page(p, p->cluster_info, offset);
>                 if (offset < p->lowest_bit)
> @@ -814,17 +845,18 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
>                                           &swap_avail_head);
>                         spin_unlock(&swap_avail_lock);
>                         p->full = false;
> +                       if (virt_swap)
> +                               atomic_long_add(p->pages -
> +                                               p->inuse_pages,
> +                                               &nr_swap_pages);

a comment here might be good, to clarify it relies on the check at the
top of scan_swap_map previously subtracting the same number of pages.


>                 }
>
>                 atomic_long_inc(&nr_swap_pages);
>                 p->inuse_pages--;
>                 frontswap_invalidate_page(p->type, offset);
> -               if (p->flags & SWP_BLKDEV) {
> -                       struct gendisk *disk = p->bdev->bd_disk;
> -                       if (disk->fops->swap_hint)
> -                               disk->fops->swap_hint(p->bdev,
> -                                               SWAP_FREE, (void *)offset);
> -               }
> +               if (virt_swap)
> +                       virt_swap->fops->swap_hint(p->bdev,
> +                                       SWAP_FREE, (void *)offset);
>         }
>
>         return usage;
> --
> 2.0.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
