Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 541DB6B006C
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 23:44:39 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so16464104wgh.31
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 20:44:38 -0800 (PST)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id cu6si20036324wib.36.2014.12.15.20.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 20:44:38 -0800 (PST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so11005839wib.4
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 20:44:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <548f68d2.HLebq27pRWZsiR9S%akpm@linux-foundation.org>
References: <548f68d2.HLebq27pRWZsiR9S%akpm@linux-foundation.org>
Date: Tue, 16 Dec 2014 13:44:37 +0900
Message-ID: <CACZ9PQXmg+pu927STvW1Yt1eGU7vVW0Y2jMAVy-PD8ucO0B0mA@mail.gmail.com>
Subject: Re: [patch 6/6] fs/mpage.c: forgotten WRITE_SYNC in case of data
 integrity write
From: Roman Peniaev <r.peniaev@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>

Hello.

As I remember Tejun asked me to change the comment to this commit and
to clarify
things little bit that WRITE_SYNC is not related to integrity write at
all, the key is that
a caller waits for completion and block layer or block device should
prioritize the IO.

>From the original comment it is not evident, so I sent v2 of this
patch with the following
comment (I hope it clarifies things):
---
When data integrity operation happens (sync, fsync, fdatasync calls)
writeback control is set to WB_SYNC_ALL. In that case all write
requests are marked with WRITE_SYNC (WRITE | REQ_SYNC | REQ_NOIDLE)
indicating that caller is waiting for completion and block layer or
block device should prioritize the IO avoiding any possible delays.

But mpage writeback path ignores marking requests as WRITE_SYNC.

This patch fixes this.
---

If you are going to take this patch could you please take the v2 comment also?


--
Roman


On Tue, Dec 16, 2014 at 8:03 AM,  <akpm@linux-foundation.org> wrote:
> From: Roman Pen <r.peniaev@gmail.com>
> Subject: fs/mpage.c: forgotten WRITE_SYNC in case of data integrity write
>
> In case of wbc->sync_mode == WB_SYNC_ALL we need to do data integrity
> write, thus mark request as WRITE_SYNC.
>
> akpm: afaict this change will cause the data integrity write bios to be
> placed onto the second queue in cfq_io_cq.cfqq[], which presumably results
> in special treatment.  The documentation for REQ_SYNC is horrid.
>
> Signed-off-by: Roman Pen <r.peniaev@gmail.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Tejun Heo <tj@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  fs/mpage.c |   23 +++++++++++++++--------
>  1 file changed, 15 insertions(+), 8 deletions(-)
>
> diff -puN fs/mpage.c~fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write fs/mpage.c
> --- a/fs/mpage.c~fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write
> +++ a/fs/mpage.c
> @@ -482,6 +482,7 @@ static int __mpage_writepage(struct page
>         struct buffer_head map_bh;
>         loff_t i_size = i_size_read(inode);
>         int ret = 0;
> +       int wr = (wbc->sync_mode == WB_SYNC_ALL ?  WRITE_SYNC : WRITE);
>
>         if (page_has_buffers(page)) {
>                 struct buffer_head *head = page_buffers(page);
> @@ -590,7 +591,7 @@ page_is_mapped:
>          * This page will go to BIO.  Do we need to send this BIO off first?
>          */
>         if (bio && mpd->last_block_in_bio != blocks[0] - 1)
> -               bio = mpage_bio_submit(WRITE, bio);
> +               bio = mpage_bio_submit(wr, bio);
>
>  alloc_new:
>         if (bio == NULL) {
> @@ -614,7 +615,7 @@ alloc_new:
>          */
>         length = first_unmapped << blkbits;
>         if (bio_add_page(bio, page, length, 0) < length) {
> -               bio = mpage_bio_submit(WRITE, bio);
> +               bio = mpage_bio_submit(wr, bio);
>                 goto alloc_new;
>         }
>
> @@ -624,7 +625,7 @@ alloc_new:
>         set_page_writeback(page);
>         unlock_page(page);
>         if (boundary || (first_unmapped != blocks_per_page)) {
> -               bio = mpage_bio_submit(WRITE, bio);
> +               bio = mpage_bio_submit(wr, bio);
>                 if (boundary_block) {
>                         write_boundary_block(boundary_bdev,
>                                         boundary_block, 1 << blkbits);
> @@ -636,7 +637,7 @@ alloc_new:
>
>  confused:
>         if (bio)
> -               bio = mpage_bio_submit(WRITE, bio);
> +               bio = mpage_bio_submit(wr, bio);
>
>         if (mpd->use_writepage) {
>                 ret = mapping->a_ops->writepage(page, wbc);
> @@ -692,8 +693,11 @@ mpage_writepages(struct address_space *m
>                 };
>
>                 ret = write_cache_pages(mapping, wbc, __mpage_writepage, &mpd);
> -               if (mpd.bio)
> -                       mpage_bio_submit(WRITE, mpd.bio);
> +               if (mpd.bio) {
> +                       int wr = (wbc->sync_mode == WB_SYNC_ALL ?
> +                                 WRITE_SYNC : WRITE);
> +                       mpage_bio_submit(wr, mpd.bio);
> +               }
>         }
>         blk_finish_plug(&plug);
>         return ret;
> @@ -710,8 +714,11 @@ int mpage_writepage(struct page *page, g
>                 .use_writepage = 0,
>         };
>         int ret = __mpage_writepage(page, wbc, &mpd);
> -       if (mpd.bio)
> -               mpage_bio_submit(WRITE, mpd.bio);
> +       if (mpd.bio) {
> +               int wr = (wbc->sync_mode == WB_SYNC_ALL ?
> +                         WRITE_SYNC : WRITE);
> +               mpage_bio_submit(wr, mpd.bio);
> +       }
>         return ret;
>  }
>  EXPORT_SYMBOL(mpage_writepage);
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
