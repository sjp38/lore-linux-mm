Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3567B6B0037
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 18:03:48 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7689215pbc.2
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 15:03:47 -0700 (PDT)
Date: Mon, 7 Oct 2013 15:03:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
Message-Id: <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
In-Reply-To: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Mon, 07 Oct 2013 17:25:41 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:

> During swapoff the frontswap_map was NULL-ified before calling
> frontswap_invalidate_area(). However the frontswap_invalidate_area()
> exits early if frontswap_map is NULL. Invalidate was never called during
> swapoff.
> 
> This patch moves frontswap_map_set() in swapoff just after calling
> frontswap_invalidate_area() so outside of locks
> (swap_lock and swap_info_struct->lock). This shouldn't be a problem as
> during swapon the frontswap_map_set() is called also outside of any
> locks.
> 

Ahem.  So there's a bunch of code in __frontswap_invalidate_area()
which hasn't ever been executed and nobody noticed it.  So perhaps that
code isn't actually needed?

More seriously, this patch looks like it enables code which hasn't been
used or tested before.  How well tested was this?

Are there any runtime-visible effects from this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
