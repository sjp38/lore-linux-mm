Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32A546B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 03:00:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so18330892wmi.11
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 00:00:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u92si41766wrc.79.2017.07.17.00.00.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 00:00:30 -0700 (PDT)
Date: Mon, 17 Jul 2017 09:00:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmalloc: terminate searching since one node found
Message-ID: <20170717070024.GC7397@dhcp22.suse.cz>
References: <1500190107-2192-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500190107-2192-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 16-07-17 15:28:27, Zhaoyang Huang wrote:
> It is no need to find the very beginning of the area within
> alloc_vmap_area, which can be done by judging each node during the process

Please describe _why_ the patch is needed. I suspect this is an
optimization but for which workloads it matters and how much.

> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>

no need to to make your s-o-b twice. Just use the same one as the From
(author of the patch).

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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
