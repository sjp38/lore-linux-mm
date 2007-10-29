From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH resend2] rd: fix data corruption on memory pressure
Date: Tue, 30 Oct 2007 01:34:45 +1100
References: <200710291517.44332.borntraeger@de.ibm.com>
In-Reply-To: <200710291517.44332.borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710300134.45950.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 30 October 2007 01:17, Christian Borntraeger wrote:
> Nick, Eric, Andrew,
>
> we now have passed rc1. That means that Erics or Nicks rd rewrite is no
> longer an option for 2.6.24. If I followed the last thread correctly all
> alternative patches have one of the following issue
> - too big for post rc1

Yeah, I don't think the rewrites were ever intended for 2.6.24
anyway...


> - break reiserfs and maybe others
> - call into vfs while being unrelated
>
> So this is a resend of my patch, which is in my opinion the simplest fix
> for the data corruption problem.
> The patch was tested by our test department, thanks to Oliver Paukstadt and
> Thorsten Diehl.
>
> ---
>
> Subject: [PATCH] rd: fix data corruption on memory pressure
> From: Christian Borntraeger <borntraeger@de.ibm.com>
>
> We have seen ramdisk based install systems, where some pages of mapped
> libraries and programs were suddendly zeroed under memory pressure. This
> should not happen, as the ramdisk avoids freeing its pages by keeping them
> dirty all the time.
>
> It turns out that there is a case, where the VM makes a ramdisk page clean,
> without telling the ramdisk driver.
> On memory pressure shrink_zone runs and it starts to run
> shrink_active_list. There is a check for buffer_heads_over_limit, and if
> true, pagevec_strip is called. pagevec_strip calls try_to_release_page. If
> the mapping has no releasepage callback, try_to_free_buffers is called.
> try_to_free_buffers has now a special logic for some file systems to make a
> dirty page clean, if all buffers are clean. Thats what happened in our test
> case.
>
> The simplest solution is to provide a noop-releasepage callback for the
> ramdisk driver. This avoids try_to_free_buffers for ramdisk pages.

I think this is the least intrusive change that is least likely
to break rd, or any other kernel code, that we've seen. It really
should go in 2.6.24, IMO.

Acked-by: Nick Piggin <npiggin@suse.de>

> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  drivers/block/rd.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> Index: linux-2.6/drivers/block/rd.c
> ===================================================================
> --- linux-2.6.orig/drivers/block/rd.c
> +++ linux-2.6/drivers/block/rd.c
> @@ -189,6 +189,18 @@ static int ramdisk_set_page_dirty(struct
>  	return 0;
>  }
>
> +/*
> + * releasepage is called by pagevec_strip/try_to_release_page if
> + * buffers_heads_over_limit is true. Without a releasepage function
> + * try_to_free_buffers is called instead. That can unset the dirty
> + * bit of our ram disk pages, which will be eventually freed, even
> + * if the page is still in use.
> + */
> +static int ramdisk_releasepage(struct page *page, gfp_t dummy)
> +{
> +	return 0;
> +}
> +
>  static const struct address_space_operations ramdisk_aops = {
>  	.readpage	= ramdisk_readpage,
>  	.prepare_write	= ramdisk_prepare_write,
> @@ -196,6 +208,7 @@ static const struct address_space_operat
>  	.writepage	= ramdisk_writepage,
>  	.set_page_dirty	= ramdisk_set_page_dirty,
>  	.writepages	= ramdisk_writepages,
> +	.releasepage	= ramdisk_releasepage,
>  };
>
>  static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t
> sector,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
