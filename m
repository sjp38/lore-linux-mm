Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A4B66B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 07:49:49 -0400 (EDT)
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH 07/11] vfs: Unmap underlying metadata of new data buffers only when buffer is mapped
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
	<1245088797-29533-8-git-send-email-jack@suse.cz>
Date: Thu, 18 Jun 2009 20:51:13 +0900
In-Reply-To: <1245088797-29533-8-git-send-email-jack@suse.cz> (Jan Kara's
	message of "Mon, 15 Jun 2009 19:59:54 +0200")
Message-ID: <87hbydkbf2.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Jan Kara <jack@suse.cz> writes:

> When we do delayed allocation of some buffer, we want to signal to VFS that
> the buffer is new (set buffer_new) so that it properly zeros out everything.
> But we don't have the buffer mapped yet so we cannot really unmap underlying
> metadata in this state. Make VFS avoid doing unmapping of metadata when the
> buffer is not yet mapped.

I may be missing something. However, isn't the delalloc buffer ==
(buffer_mapped() | buffer_delay())? Well, anyway, if buffer is not
buffer_mapped(), e.g. truncate() works properly?

Thanks.

> diff --git a/fs/buffer.c b/fs/buffer.c
> index 80e2630..7eb1710 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -1683,8 +1683,9 @@ static int __block_write_full_page(struct inode *inode, struct page *page,
>  			if (buffer_new(bh)) {
>  				/* blockdev mappings never come here */
>  				clear_buffer_new(bh);
> -				unmap_underlying_metadata(bh->b_bdev,
> -							bh->b_blocknr);
> +				if (buffer_mapped(bh))
> +					unmap_underlying_metadata(bh->b_bdev,
> +						bh->b_blocknr);

Is this needed for writepage?

>  			}
>  		}
>  		bh = bh->b_this_page;
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
