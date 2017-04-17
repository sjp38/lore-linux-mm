Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF2B96B0397
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 11:23:17 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j29so3729002qtj.19
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 08:23:17 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id q66si11197103qki.83.2017.04.17.08.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 08:23:17 -0700 (PDT)
Date: Mon, 17 Apr 2017 10:20:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
In-Reply-To: <20170417014803.GC518@jagdpanzerIV.localdomain>
Message-ID: <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, 17 Apr 2017, Sergey Senozhatsky wrote:

> Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
> with DEBUG_SLAB enabled can cause a memory corruption (See below or
> lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )

Yes the alignment guarantees do not require alignment on a page boundary.

The alignment for kmalloc allocations is controlled by KMALLOC_MIN_ALIGN.
Usually this is either double word aligned or cache line aligned.

> that's an interesting problem. arm64 copy_page(), for instance, wants src
> and dst to be page aligned, which is reasonable, while generic copy_page(),
> on the contrary, simply does memcpy(). there are, probably, other callpaths
> that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
> sort of a generic fix to the problem.

Simple solution is to not allocate pages via the slab allocator but use
the page allocator for this. The page allocator provides proper alignment.

There is a reason it is called the page allocator because if you want a
page you use the proper allocator for it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
