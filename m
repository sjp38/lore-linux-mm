Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6D16B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 05:25:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z189so6064345wmb.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:25:21 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p124si1802437wmb.111.2016.10.12.02.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 02:25:20 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id c78so1453784wme.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:25:20 -0700 (PDT)
Date: Wed, 12 Oct 2016 11:25:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND RFC PATCH v2 1/1] mm/vmalloc.c: simplify
 /proc/vmallocinfo implementation
Message-ID: <20161012092518.GG17128@dhcp22.suse.cz>
References: <57FDF2E5.1000201@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FDF2E5.1000201@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

On Wed 12-10-16 16:23:01, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> many seq_file helpers exist for simplifying implementation of virtual files
> especially, for /proc nodes. however, the helpers for iteration over
> list_head are available but aren't adopted to implement /proc/vmallocinfo
> currently.
> 
> simplify /proc/vmallocinfo implementation by existing seq_file helpers

the simplification is nice and code duplication removal useful

> Signed-off-by: zijun_hu <zijun_hu@htc.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  Changes in v2:
>   - the redundant type cast is removed as advised by rientjes@google.com
>   - commit messages are updated
> 
>  mm/vmalloc.c | 27 +++++----------------------
>  1 file changed, 5 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f2481cb4e6b2..e73948afac70 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2574,32 +2574,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
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
> @@ -2634,9 +2615,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
>  
>  static int s_show(struct seq_file *m, void *p)
>  {
> -	struct vmap_area *va = p;
> +	struct vmap_area *va;
>  	struct vm_struct *v;
>  
> +	va = list_entry(p, struct vmap_area, list);
> +
>  	/*
>  	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
>  	 * behalf of vmap area is being tear down or vm_map_ram allocation.
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
