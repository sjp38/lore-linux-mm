Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA696B0260
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:45:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so58328837pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:45:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s199si6586041pgs.43.2016.11.07.15.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:45:33 -0800 (PST)
Date: Mon, 7 Nov 2016 15:45:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] mm: merge as soon as possible when pcp alloc/free
Message-Id: <20161107154532.e3573bc08324e24aad6d1e26@linux-foundation.org>
In-Reply-To: <581D9103.1000202@huawei.com>
References: <581D9103.1000202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Yisheng Xie <xieyisheng1@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, 5 Nov 2016 15:57:55 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> Usually the memory of android phones is very small, so after a long
> running, the fragment is very large. Kernel stack which called by
> alloc_thread_stack_node() usually alloc 16K memory, and it failed
> frequently.
> 
> However we have CONFIG_VMAP_STACK now, but it do not support arm64,
> and maybe it has some regression because of vmalloc, it need to
> find an area and create page table dynamically, this will take a short
> time.
> 
> I think we can merge as soon as possible when pcp alloc/free to reduce
> fragment. The pcp page is hot page, so free it will cause cache miss,
> I use perf to test it, but it seems the regression is not so much, maybe
> it need to test more. Any reply is welcome.

per-cpu pages may not be worth the effort on such systems - probably
benefit is small.  I discussed this with Mel a few years ago and I
think he did some testing, but I forget the results?

Anyway, if per-cpu pages are causing problems then perhaps we should
have a Kconfig option which simply eliminates them: free these pages
direct into the buddy.  If the resulting code is clean-looking and the
performance testing on small systems shows decent results then that
should address the issues you're seeing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
