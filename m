Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B10876B02C3
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 05:25:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id r74so1081788oie.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 02:25:59 -0700 (PDT)
Received: from sender-pp-092.zoho.com (sender-pp-092.zoho.com. [135.84.80.237])
        by mx.google.com with ESMTPS id n130si1295680oih.7.2017.07.18.02.25.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 02:25:58 -0700 (PDT)
Subject: Re: [PATCH v3] mm/vmalloc: terminate searching since one node found
References: <1500366424-5882-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <f1b03267c7ac48c08270406dd3d9bf54@SHMBX03.spreadtrum.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <596DD399.3030906@zoho.com>
Date: Tue, 18 Jul 2017 17:23:37 +0800
MIME-Version: 1.0
In-Reply-To: <f1b03267c7ac48c08270406dd3d9bf54@SHMBX03.spreadtrum.com>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?Wmhhb3lhbmcgSHVhbmcgKOm7hOacnemYsyk=?= <Zhaoyang.Huang@spreadtrum.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>linux-mm@kvack.orglinux-kernel@vger.kernel.org

On 07/18/2017 04:31 PM, Zhaoyang Huang (>>AE3?No) wrote:
> 
> It is no need to find the very beginning of the area within
> alloc_vmap_area, which can be done by judging each node during the process
> 
it seems the original code is wrote to achieve the following two purposes :
A, the result vamp_area has the lowest available address in the required range [vstart, vend)
B, it maybe update the cached vamp_area node info which can speedup other relative allocations
it look redundant but conventional and necessary
this approach maybe destroy the original purposes
> For current approach, the worst case is that the starting node which be found
> for searching the 'vmap_area_list' is close to the 'vstart', while the final
> available one is round to the tail(especially for the left branch).
> This commit have the list searching start at the first available node, which
> will save the time of walking the rb tree'(1)' and walking the list'(2)'.
> 
>       vmap_area_root
>           /      \
>      tmp_next     U
>         /
>       tmp
>        /
>      ...  (1)
>       /
>     first(current approach)
>
 @tmp_next is the next node of @tmp in the ordered list_head, not in the rbtree

> vmap_area_list->...->first->...->tmp->tmp_next
>                             (2)
> 
> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
> ---
>  mm/vmalloc.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 34a1c3e..9a5c177 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -459,9 +459,18 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
> 
>                 while (n) {
>                         struct vmap_area *tmp;
> +                       struct vmap_area *tmp_next;
>                         tmp = rb_entry(n, struct vmap_area, rb_node);
> +                       tmp_next = list_next_entry(tmp, list);
>                         if (tmp->va_end >= addr) {
>                                 first = tmp;
> +                               if (ALIGN(tmp->va_end, align) + size
> +                                               < tmp_next->va_start) {
if @tmp node don't locate in the required rang [vstart, vend), but the right of the range it maybe
satisfy this condition, even if it locate it locate within the range, it maybe don't have the lowest free address.
if @tmp don't have the next node, tmp_next->va_start will cause NULL dereference
> +                                       addr = ALIGN(tmp->va_end, align);
> +                                       if (cached_hole_size >= size)
> +                                               cached_hole_size = 0;
it seems a little rough to reset the @cached_hole_size by this way,  it will caused the cached info is updated in the next
allocation regardless the allocation arguments.
> +                                       goto found;
> +                               }
>                                 if (tmp->va_start <= addr)
>                                         break;
>                                 n = n->rb_left;
> --
> 1.9.1
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
