Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 52D326B0032
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 04:13:25 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so8450173pad.30
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 01:13:24 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUC00G32C69HKC0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 08 Oct 2013 09:13:21 +0100 (BST)
Message-id: <1381220000.16135.10.camel@AMDC1943>
Subject: Re: [PATCH] frontswap: enable call to invalidate area on swapoff
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Tue, 08 Oct 2013 10:13:20 +0200
In-reply-to: <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
References: <1381159541-13981-1-git-send-email-k.kozlowski@samsung.com>
 <20131007150338.1fdee18b536bb1d9fe41a07b@linux-foundation.org>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On pon, 2013-10-07 at 15:03 -0700, Andrew Morton wrote:
> On Mon, 07 Oct 2013 17:25:41 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:
> 
> > During swapoff the frontswap_map was NULL-ified before calling
> > frontswap_invalidate_area(). However the frontswap_invalidate_area()
> > exits early if frontswap_map is NULL. Invalidate was never called during
> > swapoff.
> > 
> > This patch moves frontswap_map_set() in swapoff just after calling
> > frontswap_invalidate_area() so outside of locks
> > (swap_lock and swap_info_struct->lock). This shouldn't be a problem as
> > during swapon the frontswap_map_set() is called also outside of any
> > locks.
> > 
> 
> Ahem.  So there's a bunch of code in __frontswap_invalidate_area()
> which hasn't ever been executed and nobody noticed it.  So perhaps that
> code isn't actually needed?
> 
> More seriously, this patch looks like it enables code which hasn't been
> used or tested before.  How well tested was this?
> 
> Are there any runtime-visible effects from this change?

I tested zswap on x86 and x86-64 and there was no difference. This is
good as there shouldn't be visible anything because swapoff is unusing
all pages anyway:
	try_to_unuse(type, false, 0); /* force all pages to be unused */

I haven't tested other frontswap users.


Best regards,
Krzysztof Kozlowski



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
