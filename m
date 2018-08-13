Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 258146B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 02:05:57 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z3-v6so10370189plb.16
        for <linux-mm@kvack.org>; Sun, 12 Aug 2018 23:05:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t29-v6sor5209980pfi.143.2018.08.12.23.05.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 Aug 2018 23:05:55 -0700 (PDT)
Date: Mon, 13 Aug 2018 15:05:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: fix linking bug in init_zspage
Message-ID: <20180813060549.GB64836@rodete-desktop-imager.corp.google.com>
References: <20180810002817.2667-1-zhouxianrong@tom.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180810002817.2667-1-zhouxianrong@tom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@tom.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, zhouxianrong <zhouxianrong@huawei.com>

Hi,

On Thu, Aug 09, 2018 at 08:28:17PM -0400, zhouxianrong wrote:
> From: zhouxianrong <zhouxianrong@huawei.com>
> 
> The last partial object in last subpage of zspage should not be linked
> in allocation list. Otherwise it could trigger BUG_ON explicitly at
> function zs_map_object. But it happened rarely.

Could you be more specific? What case did you see the problem?
Is it a real problem or one founded by review?

Thanks.

> 
> Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> ---
>  mm/zsmalloc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 8d87e973a4f5..24dd8da0aa59 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1040,6 +1040,8 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
>  			 * Reset OBJ_TAG_BITS bit to last link to tell
>  			 * whether it's allocated object or not.
>  			 */
> +			if (off > PAGE_SIZE)
> +				link -= class->size / sizeof(*link);
>  			link->next = -1UL << OBJ_TAG_BITS;
>  		}
>  		kunmap_atomic(vaddr);
> -- 
> 2.13.6
> 
