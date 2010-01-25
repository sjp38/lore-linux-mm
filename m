Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 684E86B0047
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 08:33:15 -0500 (EST)
Date: Mon, 25 Jan 2010 21:33:08 +0800
From: anfei <anfei.zhou@gmail.com>
Subject: Re: [PATCH] Flush dcache before writing into page to avoid alias
Message-ID: <20100125133308.GA26799@desktop>
References: <979dd0561001202107v4ddc1eb7xa59a7c16c452f7a2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <979dd0561001202107v4ddc1eb7xa59a7c16c452f7a2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux@arm.linux.org.uk, Jamie Lokier <jamie@shareable.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Thu, Jan 21, 2010 at 01:07:57PM +0800, anfei zhou wrote:
> The cache alias problem will happen if the changes of user shared mapping
> is not flushed before copying, then user and kernel mapping may be mapped
> into two different cache line, it is impossible to guarantee the coherence
> after iov_iter_copy_from_user_atomic.  So the right steps should be:
> 	flush_dcache_page(page);
> 	kmap_atomic(page);
> 	write to page;
> 	kunmap_atomic(page);
> 	flush_dcache_page(page);
> More precisely, we might create two new APIs flush_dcache_user_page and
> flush_dcache_kern_page to replace the two flush_dcache_page accordingly.
> 
> Here is a snippet tested on omap2430 with VIPT cache, and I think it is
> not ARM-specific:
> 	int val = 0x11111111;
> 	fd = open("abc", O_RDWR);
> 	addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> 	*(addr+0) = 0x44444444;
> 	tmp = *(addr+0);
> 	*(addr+1) = 0x77777777;
> 	write(fd, &val, sizeof(int));
> 	close(fd);
> The results are not always 0x11111111 0x77777777 at the beginning as expected.
> 
Is this a real bug or not necessary to support?

Thanks,
Anfei.

> Signed-off-by: Anfei <anfei.zhou@gmail.com>
> ---
>  fs/fuse/file.c |    3 +++
>  mm/filemap.c   |    3 +++
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index c18913a..a9f5e13 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -828,6 +828,9 @@ static ssize_t fuse_fill_write_pages(struct fuse_req *req,
>  		if (!page)
>  			break;
> 
> +		if (mapping_writably_mapped(mapping))
> +			flush_dcache_page(page);
> +
>  		pagefault_disable();
>  		tmp = iov_iter_copy_from_user_atomic(page, ii, offset, bytes);
>  		pagefault_enable();
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 96ac6b0..07056fb 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2196,6 +2196,9 @@ again:
>  		if (unlikely(status))
>  			break;
> 
> +		if (mapping_writably_mapped(mapping))
> +			flush_dcache_page(page);
> +
>  		pagefault_disable();
>  		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
>  		pagefault_enable();
> -- 
> 1.6.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
