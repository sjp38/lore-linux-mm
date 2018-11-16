Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29A266B09D2
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:51:20 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a199so50937841qkb.23
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:51:20 -0800 (PST)
Received: from a9-34.smtp-out.amazonses.com (a9-34.smtp-out.amazonses.com. [54.240.9.34])
        by mx.google.com with ESMTPS id p55si10633595qtf.16.2018.11.16.05.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Nov 2018 05:51:19 -0800 (PST)
Date: Fri, 16 Nov 2018 13:51:19 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix 'dubious: x & !y' warning from Sparse
In-Reply-To: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
Message-ID: <010001671cca4b8b-2333373d-6b28-44e1-bca3-24570b8e0d2b-000000@email.amazonses.com>
References: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 16 Nov 2018, Masahiro Yamada wrote:

> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 918f374..d395c73 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>  	 */
> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +	return type_dma + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM;
>  }

Ok then lets revert the initial patch whose point was to avoid a branch.
&& causes a branch again.
