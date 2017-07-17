Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 457626B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 04:29:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 80so7205978wmt.15
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 01:29:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12si12224653wrz.83.2017.07.17.01.29.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 01:29:54 -0700 (PDT)
Date: Mon, 17 Jul 2017 10:29:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/vmalloc: terminate searching since one node found
Message-ID: <20170717082945.GB12888@dhcp22.suse.cz>
References: <1500276451-10492-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500276451-10492-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-07-17 15:27:31, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com:wq>
> 
> It is no need to find the very beginning of the area within
> alloc_vmap_area, which can be done by judging each node during the process
> 
> For current approach, the worst case is that the starting node which be found
> for searching the 'vmap_area_list' is close to the 'vstart', while the final
> available one is round to the tail(especially for the left branch).
> This commit have the list searching start at the first available node, which
> will save the time of walking the rb tree'(1)' and walking the list(2).
> 
>       vmap_area_root
>           /      \
>      tmp_next     U
>         /   (1)
>       tmp
>        /
>      ...
>       /
>     first(current approach)
> 
> vmap_area_list->...->first->...->tmp->tmp_next
>                             (2)

This still doesn't answer questions posted for your previous version
http://lkml.kernel.org/r/20170717070024.GC7397@dhcp22.suse.cz

Please note that is really important to describe _why_ the patch is
needed. What has changed can be easily read in the diff...

> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  mm/vmalloc.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 34a1c3e..f833e07 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -459,9 +459,16 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  
>  		while (n) {
>  			struct vmap_area *tmp;
> +			struct vmap_area *tmp_next;
>  			tmp = rb_entry(n, struct vmap_area, rb_node);
> +			tmp_next = list_next_entry(tmp, list);
>  			if (tmp->va_end >= addr) {
>  				first = tmp;
> +				if (ALIGN(tmp->va_end, align) + size
> +						< tmp_next->va_start) {
> +					addr = ALIGN(tmp->va_end, align);
> +					goto found;
> +				}
>  				if (tmp->va_start <= addr)
>  					break;
>  				n = n->rb_left;
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
