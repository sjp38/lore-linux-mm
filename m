Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50AF128024B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:16:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so126137115pfb.0
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:16:05 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id bu6si36063599pad.96.2016.09.21.14.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:16:04 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id wk8so21925622pab.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:16:04 -0700 (PDT)
Date: Wed, 21 Sep 2016 14:16:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] mm/vmalloc.c: simplify /proc/vmallocinfo
 implementation
In-Reply-To: <57E20BE0.6040104@zoho.com>
Message-ID: <alpine.DEB.2.10.1609211414200.20971@chino.kir.corp.google.com>
References: <57E20BE0.6040104@zoho.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On Wed, 21 Sep 2016, zijun_hu wrote:

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index cc6ecd6..a125ae8 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2576,32 +2576,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
>  static void *s_start(struct seq_file *m, loff_t *pos)
>  	__acquires(&vmap_area_lock)
>  {
> -	loff_t n = *pos;
> -	struct vmap_area *va;
> -
>  	spin_lock(&vmap_area_lock);
> -	va = list_first_entry(&vmap_area_list, typeof(*va), list);
> -	while (n > 0 && &va->list != &vmap_area_list) {
> -		n--;
> -		va = list_next_entry(va, list);
> -	}
> -	if (!n && &va->list != &vmap_area_list)
> -		return va;
> -
> -	return NULL;
> -
> +	return seq_list_start(&vmap_area_list, *pos);
>  }
>  
>  static void *s_next(struct seq_file *m, void *p, loff_t *pos)
>  {
> -	struct vmap_area *va = p, *next;
> -
> -	++*pos;
> -	next = list_next_entry(va, list);
> -	if (&next->list != &vmap_area_list)
> -		return next;
> -
> -	return NULL;
> +	return seq_list_next(p, &vmap_area_list, pos);
>  }
>  
>  static void s_stop(struct seq_file *m, void *p)
> @@ -2636,9 +2617,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
>  
>  static int s_show(struct seq_file *m, void *p)
>  {
> -	struct vmap_area *va = p;
> +	struct vmap_area *va;
>  	struct vm_struct *v;
>  
> +	va = list_entry((struct list_head *)p, struct vmap_area, list);

Looks good other than no cast is neccessary above.

The patches in this series seem to be unrelated to each other, they 
shouldn't be numbered in order since there's no dependence.  Just 
individual patches are fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
