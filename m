Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7F05B6B00BC
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 15:13:41 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so2609379pdj.35
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:13:41 -0700 (PDT)
Date: Thu, 17 Oct 2013 19:13:38 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 13/15] slab: use struct page for slab management
In-Reply-To: <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000141c7d66282-aa92b1f2-2a69-424b-9498-8e5367304d32-000000@email.amazonses.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com> <1381913052-23875-14-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 16 Oct 2013, Joonsoo Kim wrote:

> -					 * see PAGE_MAPPING_ANON below.
> -					 */
> +	union {
> +		struct address_space *mapping;	/* If low bit clear, points to
> +						 * inode address_space, or NULL.
> +						 * If page mapped as anonymous
> +						 * memory, low bit is set, and
> +						 * it points to anon_vma object:
> +						 * see PAGE_MAPPING_ANON below.
> +						 */
> +		void *s_mem;			/* slab first object */
> +	};

The overloading of mapping has caused problems in the past since slab
pages are (or are they no longer?) used for DMA to disk. At that point the
I/O subsystem may be expecting a mapping in the page struct if this field
is not NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
