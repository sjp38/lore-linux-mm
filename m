Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2376B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 10:41:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d18-v6so2211058edp.0
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 07:41:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91-v6si1423170edd.11.2018.08.09.07.41.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 07:41:26 -0700 (PDT)
Subject: Re: [PATCH] zsmalloc: fix linking bug in init_zspage
References: <20180809135356.4070-1-zhouxianrong@tom.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5985fb0b-1241-9ddb-c32d-bc879247270d@suse.cz>
Date: Thu, 9 Aug 2018 16:41:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180809135356.4070-1-zhouxianrong@tom.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@tom.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com

On 08/09/2018 03:53 PM, zhouxianrong wrote:
> The last partial object in last subpage of zspage should not be linked
> in allocation list.

Please expand the changelog. Why it should not be? What happens if it
is? Kernel panic, data corruption or whatnot? So that people not
familiar with zsmalloc internals can judge how important the patch is
for e.g. backporting.

Thanks,
Vlastimil

> Signed-off-by: zhouxianrong <zhouxianrong@tom.com>
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
> 
