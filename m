Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8E62C6B00DF
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 09:41:00 -0400 (EDT)
Date: Wed, 7 Aug 2013 15:40:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Message-ID: <20130807134058.GC12843@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1375729665.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 05-08-13 12:43:58, Andy Lutomirski wrote:
> My application fallocates and mmaps (shared, writable) a lot (several
> GB) of data at startup.  Those mappings are mlocked, and they live on
> ext4.  The first write to any given page is slow because
> ext4_da_get_block_prep can block.  This means that, to get decent
> performance, I need to write something to all of these pages at
> startup.  This, in turn, causes a giant IO storm as several GB of
> zeros get pointlessly written to disk.
> 
> This series is an attempt to add madvise(..., MADV_WILLWRITE) to
> signal to the kernel that I will eventually write to the referenced
> pages.  It should cause any expensive operations that happen on the
> first write to happen immediately, but it should not result in
> dirtying the pages.
> 
> madvice(addr, len, MADV_WILLWRITE) returns the number of bytes that
> the operation succeeded on or a negative error code if there was an
> actual failure.  A return value of zero signifies that the kernel
> doesn't know how to "willwrite" the range and that userspace should
> implement a fallback.
> 
> For now, it only works on shared writable ext4 mappings.  Eventually
> it should support other filesystems as well as private pages (it
> should COW the pages but not cause swap IO) and anonymous pages (it
> should COW the zero page if applicable).
> 
> The implementation leaves much to be desired.  In particular, it
> generates dirty buffer heads on a clean page, and this scares me.
> 
> Thoughts?
  One question before I look at the patches: Why don't you use fallocate()
in your application? The functionality you require seems to be pretty
similar to it - writing to an already allocated block is usually quick.


								Honza

> Andy Lutomirski (3):
>   mm: Add MADV_WILLWRITE to indicate that a range will be written to
>   fs: Add block_willwrite
>   ext4: Implement willwrite for the delalloc case
> 
>  fs/buffer.c                            | 57 ++++++++++++++++++++++++++++++++++
>  fs/ext4/ext4.h                         |  2 ++
>  fs/ext4/file.c                         |  1 +
>  fs/ext4/inode.c                        | 22 +++++++++++++
>  include/linux/buffer_head.h            |  3 ++
>  include/linux/mm.h                     | 12 +++++++
>  include/uapi/asm-generic/mman-common.h |  3 ++
>  mm/madvise.c                           | 28 +++++++++++++++--
>  8 files changed, 126 insertions(+), 2 deletions(-)
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
