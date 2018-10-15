Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA626B026D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:42:43 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q6-v6so22733707qtb.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:42:43 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id f6-v6si10365179qtg.392.2018.10.15.15.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Oct 2018 15:42:42 -0700 (PDT)
Date: Mon, 15 Oct 2018 22:42:42 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
In-Reply-To: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
Message-ID: <0100016679e54c6e-67ca8716-c95e-427f-aec9-a5bee5e84792-000000@email.amazonses.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Oct 2018, David Rientjes wrote:

> @@ -1803,6 +1804,20 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
>  		 */
>  		if (left_over * 8 <= (PAGE_SIZE << gfporder))
>  			break;
> +
> +		/*
> +		 * If a higher gfporder would not reduce internal fragmentation,
> +		 * no need to continue.  The preference is to keep gfporder as
> +		 * small as possible so slab allocations can be served from
> +		 * MIGRATE_UNMOVABLE pcp lists to avoid stranding.
> +		 */

I think either go for order 0 (because then you can use the pcp lists) or
go as high as possible (then you can allocator larger memory areas with a
single pass through the page allocator).

But then I am not sure that the whole approach will do any good.
