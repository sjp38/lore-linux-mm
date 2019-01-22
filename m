Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B18C48E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:07:06 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m13so15576801pls.15
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:07:06 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id l59si15895576plb.154.2019.01.22.07.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:07:05 -0800 (PST)
Received: from eucas1p1.samsung.com (unknown [182.198.249.206])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20190122150701euoutp01e081687323b48f56956d13f7151e78fe~8NBF3XW0j3173231732euoutp01n
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:07:01 +0000 (GMT)
Subject: Re: [PATCH 7/9] videobuf2/videobuf2-dma-sg.c: Convert to use
 vm_insert_range_buggy
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-ID: <241810e0-2288-c59b-6c21-6d853d9fe84a@samsung.com>
Date: Tue, 22 Jan 2019 16:06:58 +0100
MIME-Version: 1.0
In-Reply-To: <20190111151154.GA2819@jordon-HP-15-Notebook-PC>
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
References: <CGME20190111150806epcas2p4ecaac58547db019e7dc779349d495f4d@epcas2p4.samsung.com>
	<20190111151154.GA2819@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-media@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Souptick,

On 2019-01-11 16:11, Souptick Joarder wrote:
> Convert to use vm_insert_range_buggy to map range of kernel memory
> to user vma.
>
> This driver has ignored vm_pgoff. We could later "fix" these drivers
> to behave according to the normal vm_pgoff offsetting simply by
> removing the _buggy suffix on the function name and if that causes
> regressions, it gives us an easy way to revert.

Just a generic note about videobuf2: videobuf2-dma-sg is ignoring vm_pgoff by design. vm_pgoff is used as a 'cookie' to select a buffer to mmap and videobuf2-core already checks that. If userspace provides an offset, which doesn't match any of the registered 'cookies' (reported to userspace via separate v4l2 ioctl), an error is returned.

I'm sorry for the late reply.

> There is an existing bug inside gem_mmap_obj(), where user passed
> length is not checked against buf->num_pages. For any value of
> length > buf->num_pages it will end up overrun buf->pages[i],
> which could lead to a potential bug.
>
> This has been addressed by passing buf->num_pages as input to
> vm_insert_range_buggy() and inside this API error condition is
> checked which will avoid overrun the page boundary.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++++++----------------
>  1 file changed, 6 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/media/common/videobuf2/videobuf2-dma-sg.c b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> index 015e737..ef046b4 100644
> --- a/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> +++ b/drivers/media/common/videobuf2/videobuf2-dma-sg.c
> @@ -328,28 +328,18 @@ static unsigned int vb2_dma_sg_num_users(void *buf_priv)
>  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>  {
>  	struct vb2_dma_sg_buf *buf = buf_priv;
> -	unsigned long uaddr = vma->vm_start;
> -	unsigned long usize = vma->vm_end - vma->vm_start;
> -	int i = 0;
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
> +	err = vm_insert_range_buggy(vma, buf->pages, buf->num_pages);
> +	if (err) {
> +		printk(KERN_ERR "Remapping memory, error: %d\n", err);
> +		return err;
> +	}
>  
>  	/*
>  	 * Use common vm_area operations to track buffer refcount.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
