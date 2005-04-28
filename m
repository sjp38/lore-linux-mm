Subject: Re: [PATCH] drop_buffers() shouldn't de-ref page->mapping if its NULL
References: <1114645113.26913.662.camel@dyn318077bld.beaverton.ibm.com>
	<1114646015.26913.668.camel@dyn318077bld.beaverton.ibm.com>
From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date: Thu, 28 Apr 2005 12:46:33 +0900
In-Reply-To: <1114646015.26913.668.camel@dyn318077bld.beaverton.ibm.com> (Badari Pulavarty's message of "27 Apr 2005 16:53:38 -0700")
Message-ID: <87k6mn5zs6.fsf@devron.myhome.or.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, skodati@in.ibm.com
List-ID: <linux-mm.kvack.org>

Badari Pulavarty <pbadari@us.ibm.com> writes:

> Hi,
>
> I answered my own question. It looks like we could have pages
> with buffers without page->mapping. In such cases, we shouldn't
> de-ref page->mapping in drop_buffers(). Here is the trivial
> patch to fix it.
>
> Thanks,
> Badari

[...]

>
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> --- linux-2.6.12-rc2.org/fs/buffer.c	2005-04-27 07:19:44.000000000 -0700
> +++ linux-2.6.12-rc2/fs/buffer.c	2005-04-27 07:20:34.000000000 -0700
> @@ -2917,7 +2917,7 @@ drop_buffers(struct page *page, struct b
>  
>  	bh = head;
>  	do {
> -		if (buffer_write_io_error(bh))
> +		if (buffer_write_io_error(bh) && page->mapping)
>  			set_bit(AS_EIO, &page->mapping->flags);
>  		if (buffer_busy(bh))
>  			goto failed;

On my experience, this happened the bh leak case only.

If you are not sure whether this is valid state or not, I worry this
patch hides real bug.  How about adding the warning, not just remove
de-ref?

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
