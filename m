Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id AA7D66B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 00:31:39 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so96062649pfn.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 21:31:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ym10si29002769pab.146.2016.02.01.21.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 21:31:38 -0800 (PST)
Date: Mon, 1 Feb 2016 21:34:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 1/8] kasan: Change the behavior of
 kmalloc_large_oob_right test
Message-Id: <20160201213427.f428b08d.akpm@linux-foundation.org>
In-Reply-To: <35b553cafcd5b77838aeaf5548b457dfa09e30cf.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
	<35b553cafcd5b77838aeaf5548b457dfa09e30cf.1453918525.git.glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, ryabinin.a.a@gmail.com, rostedt@goodmis.org, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Jan 2016 19:25:06 +0100 Alexander Potapenko <glider@google.com> wrote:

> depending on which allocator (SLAB or SLUB) is being used
> 
> ...
>
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -68,7 +68,22 @@ static noinline void __init kmalloc_node_oob_right(void)
>  static noinline void __init kmalloc_large_oob_right(void)
>  {
>  	char *ptr;
> -	size_t size = KMALLOC_MAX_CACHE_SIZE + 10;
> +	size_t size;
> +
> +	if (KMALLOC_MAX_CACHE_SIZE == KMALLOC_MAX_SIZE) {
> +		/*
> +		 * We're using the SLAB allocator. Allocate a chunk that fits
> +		 * into a slab.
> +		 */
> +		size = KMALLOC_MAX_CACHE_SIZE - 256;
> +	} else {
> +		/*
> +		 * KMALLOC_MAX_SIZE > KMALLOC_MAX_CACHE_SIZE.
> +		 * We're using the SLUB allocator. Allocate a chunk that does
> +		 * not fit into a slab to trigger the page allocator.
> +		 */
> +		size = KMALLOC_MAX_CACHE_SIZE + 10;
> +	}

This seems a weird way of working out whether we're using SLAB or SLUB.

Can't we use, umm, #ifdef CONFIG_SLAB?  If not that then let's cook up
something standardized rather than a weird just-happens-to-work like
this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
