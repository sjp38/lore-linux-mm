Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF176B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 07:40:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v190so59876083pgv.12
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 04:40:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g72si2920708pfd.25.2017.07.21.04.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 04:40:03 -0700 (PDT)
Date: Fri, 21 Jul 2017 04:39:48 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] mm/vmalloc: add a node corresponding to
 cached_hole_size
Message-ID: <20170721113948.GB18303@bombadil.infradead.org>
References: <1500631301-17444-1-git-send-email-zhaoyang.huang@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500631301-17444-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

On Fri, Jul 21, 2017 at 06:01:41PM +0800, Zhaoyang Huang wrote:
> we just record the cached_hole_size now, which will be used when
> the criteria meet both of 'free_vmap_cache == NULL' and 'size <
> cached_hole_size'. However, under above scenario, the search will
> start from the rb_root and then find the node which just in front
> of the cached hole.
> 
> free_vmap_cache miss:
>       vmap_area_root
>           /      \
>        _next     U
>         /  (T1)
>  cached_hole_node
>        /
>      ...   (T2)
>       /
>     first
> 
> vmap_area_list->first->......->cached_hole_node->cached_hole_node.list.next
>                   |-------(T3)-------| | <<< cached_hole_size >>> |
> 
> vmap_area_list->......->cached_hole_node->cached_hole_node.list.next
>                                | <<< cached_hole_size >>> |
> 
> The time cost to search the node now is T = T1 + T2 + T3.
> The commit add a cached_hole_node here to record the one just in front of
> the cached_hole_size, which can help to avoid walking the rb tree and
> the list and make the T = 0;

Yes, but does this matter in practice?  Are there any workloads where
this makes a difference?  If so, how much?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
