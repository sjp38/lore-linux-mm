Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3CD8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:31:36 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id t205so412128ywa.10
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:31:36 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p184si1104204ybp.388.2019.01.14.15.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:31:35 -0800 (PST)
Subject: Re: [PATCH 9/9] xen/privcmd-buf.c: Convert to use
 vm_insert_range_buggy
References: <20190111151326.GA2853@jordon-HP-15-Notebook-PC>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <8b0e0809-8e66-079d-1186-90b3f2df7a38@oracle.com>
Date: Mon, 14 Jan 2019 18:31:12 -0500
MIME-Version: 1.0
In-Reply-To: <20190111151326.GA2853@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, jgross@suse.com, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/11/19 10:13 AM, Souptick Joarder wrote:
> Convert to use vm_insert_range_buggy() to map range of kernel
> memory to user vma.
>
> This driver has ignored vm_pgoff. We could later "fix" these drivers
> to behave according to the normal vm_pgoff offsetting simply by
> removing the _buggy suffix on the function name and if that causes
> regressions, it gives us an easy way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> ---
>  drivers/xen/privcmd-buf.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
> index de01a6d..a9d7e97 100644
> --- a/drivers/xen/privcmd-buf.c
> +++ b/drivers/xen/privcmd-buf.c
> @@ -166,12 +166,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
>  	if (vma_priv->n_pages != count)
>  		ret = -ENOMEM;
>  	else
> -		for (i = 0; i < vma_priv->n_pages; i++) {
> -			ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
> -					     vma_priv->pages[i]);
> -			if (ret)
> -				break;
> -		}
> +		ret = vm_insert_range_buggy(vma, vma_priv->pages,
> +						vma_priv->n_pages);

This can use the non-buggy version. But since the original code was
indeed buggy in this respect I can submit this as a separate patch later.

So

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


>  
>  	if (ret)
>  		privcmd_buf_vmapriv_free(vma_priv);
