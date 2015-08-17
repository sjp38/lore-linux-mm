Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6286B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:59:35 -0400 (EDT)
Received: by qgj62 with SMTP id 62so104539420qgj.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 14:59:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s21si11476045qgs.97.2015.08.17.14.59.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 14:59:34 -0700 (PDT)
Date: Mon, 17 Aug 2015 14:59:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/memblock: check memblock_reserve on fail in
 memblock_virt_alloc_internal
Message-Id: <20150817145932.68fe9460c4392a0c3907392a@linux-foundation.org>
In-Reply-To: <1439663206-15484-1-git-send-email-kuleshovmail@gmail.com>
References: <1439663206-15484-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Robin Holt <holt@sgi.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Santosh Shilimkar <santosh.shilimkar@ti.com>

On Sun, 16 Aug 2015 00:26:46 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> This patch adds a check for memblock_reserve() call in the
> memblock_virt_alloc_internal() function, because memblock_reserve()
> can return -errno on fail.
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1298,7 +1298,9 @@ again:
>  
>  	return NULL;
>  done:
> -	memblock_reserve(alloc, size);
> +	if (memblock_reserve(alloc, size))
> +		return NULL;
> +
>  	ptr = phys_to_virt(alloc);
>  	memset(ptr, 0, size);

This shouldn't ever happen.  If it *does* happen, something is messed
up and we should warn.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
