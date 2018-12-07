Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 95E348E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 09:49:04 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w12so1450895wru.20
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 06:49:04 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id j2si2251546wrb.273.2018.12.07.06.49.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 06:49:03 -0800 (PST)
Date: Fri, 7 Dec 2018 12:48:51 -0200
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: [PATCH v3 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range
Message-ID: <20181207124851.3eef28a0@coco.lan>
In-Reply-To: <20181206184438.GA31370@jordon-HP-15-Notebook-PC>
References: <20181206184438.GA31370@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Em Fri, 7 Dec 2018 00:14:38 +0530
Souptick Joarder <jrdr.linux@gmail.com> escreveu:

> Convert to use vm_insert_range to map range of kernel memory
> to user vma.
> 
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>

It probably makes sense to apply it via mm tree, together with
patch 1. So:

Acked-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

> ---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> index 015e737..898adef 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> @@ -328,28 +328,19 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
>  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>  {
>  	struct vb2_dma_sg_buf *buf = buf_priv;
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long usize = vma->vm_end - vma->vm_start;
> -	int i = 0;
> +	unsigned long page_count = vma_pages(vma);
> +	int err;
>  
>  	if (!buf) {
>  		printk(KERN_ERR "No memory to map\n");
>  		return -EINVAL;
>  	}
>  
> -	do {
> -		int ret;
> -
> -		ret = vm_insert_page(vma, uaddr, buf->pages[i++]);
> -		if (ret) {
> -			printk(KERN_ERR "Remapping memory, error: %d\n", ret);
> -			return ret;
> -		}
> -
> -		uaddr += PAGE_SIZE;
> -		usize -= PAGE_SIZE;
> -	} while (usize > 0);
> -
> +	err = vm_insert_range(vma, vma->vm_start, buf->pages, page_count);
> +	if (err) {
> +		printk(KERN_ERR "Remapping memory, error: %d\n", err);
> +		return err;
> +	}
>  
>  	/*
>  	 * Use common vm_area operations to track buffer refcount.



Thanks,
Mauro
