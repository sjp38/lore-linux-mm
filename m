Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1706B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 08:29:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u18so23885334wrc.10
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 05:29:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s80si15034731wma.18.2017.04.03.05.29.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 05:29:54 -0700 (PDT)
Date: Mon, 3 Apr 2017 14:29:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
Message-ID: <20170403122951.GL24661@dhcp22.suse.cz>
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
 <c0dc0633-06f8-e683-3caa-062993540d09@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0dc0633-06f8-e683-3caa-062993540d09@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Shakeel Butt <shakeelb@google.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon 03-04-17 14:57:11, Andrey Ryabinin wrote:
> On 04/03/2017 11:47 AM, Michal Hocko wrote:
> > On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
[...]
> >>> @@ -1017,9 +1018,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >>>
> >>>         /* store */
> >>>         len = dlen + sizeof(struct zswap_header);
> >>> -       ret = zpool_malloc(entry->pool->zpool, len,
> >>> -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLAIM,
> >>> -                          &handle);
> >>> +       ret = zpool_malloc(entry->pool->zpool, len, gfp, &handle);
> > 
> > and here we used to do GFP_NOWAIT alternative already. What is going on
> > here?
> 
> 
> I suspect that there was no particular reason to assemble this
> custom set of gfp flags.  This code probably should have been using
> GFP_NOWAIT|__GFP_NOWARN from the very beginning.

Or just use GFP_KERNEL with a comment that this is called from the
reclaim context and as such is properly addressed at the page allocator
layer. One reason why this makes more sense than GFP_NOWAIT is that
this is easier to follow. When you see GFP_NOWAIT then you usually
expect a best efford opportunistic allocation attempt (especially with
__GFP_NOWARN) which is not the case here because this paths gets a full
memory reserves access. If this is not intentional then use GFP_NOWAIT |
__GFP_NOMEMALLOC | __GFP_NOWARN.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
