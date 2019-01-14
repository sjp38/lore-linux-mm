Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id A065A8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 18:28:25 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id i12so1083913ita.3
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 15:28:25 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id u71si988151ita.88.2019.01.14.15.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 15:28:24 -0800 (PST)
Subject: Re: [PATCH 8/9] xen/gntdev.c: Convert to use vm_insert_range
References: <20190111151235.GA2836@jordon-HP-15-Notebook-PC>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <f6eef305-daf3-dad8-96e3-d2f93d169fd4@oracle.com>
Date: Mon, 14 Jan 2019 18:27:53 -0500
MIME-Version: 1.0
In-Reply-To: <20190111151235.GA2836@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, jgross@suse.com, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 1/11/19 10:12 AM, Souptick Joarder wrote:
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

(although it would be good to mention in the commit that you are also
replacing count with vma_pages(vma), and why)


> ---
>  drivers/xen/gntdev.c | 16 ++++++----------
>  1 file changed, 6 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index b0b02a5..ca4acee 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>  {
>  	struct gntdev_priv *priv = flip->private_data;
>  	int index = vma->vm_pgoff;
> -	int count = vma_pages(vma);
>  	struct gntdev_grant_map *map;
> -	int i, err = -EINVAL;
> +	int err = -EINVAL;
>  
>  	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
>  		return -EINVAL;
>  
>  	pr_debug("map %d+%d at %lx (pgoff %lx)\n",
> -			index, count, vma->vm_start, vma->vm_pgoff);
> +			index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
>  
>  	mutex_lock(&priv->lock);
> -	map = gntdev_find_map_index(priv, index, count);
> +	map = gntdev_find_map_index(priv, index, vma_pages(vma));
>  	if (!map)
>  		goto unlock_out;
>  	if (use_ptemod && map->vma)
> @@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>  		goto out_put_map;
>  
>  	if (!use_ptemod) {
> -		for (i = 0; i < count; i++) {
> -			err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
> -				map->pages[i]);
> -			if (err)
> -				goto out_put_map;
> -		}
> +		err = vm_insert_range(vma, map->pages, map->count);
> +		if (err)
> +			goto out_put_map;
>  	} else {
>  #ifdef CONFIG_X86
>  		/*
