Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A516D6B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 08:45:48 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p64so23944799wrb.18
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 05:45:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z45si19813062wrc.238.2017.04.03.05.45.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 05:45:47 -0700 (PDT)
Date: Mon, 3 Apr 2017 14:45:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/zswap: fix potential deadlock in
 zswap_frontswap_store()
Message-ID: <20170403124544.GN24661@dhcp22.suse.cz>
References: <20170331153009.11397-1-aryabinin@virtuozzo.com>
 <CALvZod5rnV5ZjKYxFwPDX8NcRQKJfwN-iWyVD-Mm4+fKten1+A@mail.gmail.com>
 <20170403084729.GG24661@dhcp22.suse.cz>
 <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4e8b895-260c-9b47-4531-5fac5cefa77c@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Shakeel Butt <shakeelb@google.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon 03-04-17 15:37:07, Andrey Ryabinin wrote:
> 
> 
> On 04/03/2017 11:47 AM, Michal Hocko wrote:
> > On Fri 31-03-17 10:00:30, Shakeel Butt wrote:
> >> On Fri, Mar 31, 2017 at 8:30 AM, Andrey Ryabinin
> >> <aryabinin@virtuozzo.com> wrote:
> >>> zswap_frontswap_store() is called during memory reclaim from
> >>> __frontswap_store() from swap_writepage() from shrink_page_list().
> >>> This may happen in NOFS context, thus zswap shouldn't use __GFP_FS,
> >>> otherwise we may renter into fs code and deadlock.
> >>> zswap_frontswap_store() also shouldn't use __GFP_IO to avoid recursion
> >>> into itself.
> >>>
> >>
> >> Is it possible to enter fs code (or IO) from zswap_frontswap_store()
> >> other than recursive memory reclaim? However recursive memory reclaim
> >> is protected through PF_MEMALLOC task flag. The change seems fine but
> >> IMHO reasoning needs an update. Adding Michal for expert opinion.
> > 
> > Yes this is true. 
> 
> Actually, no. I think we have a bug in allocator which may lead to
> recursive direct reclaim.
>
> E.g. for costly order allocations (or order > 0 &&
> ac->migratetype != MIGRATE_MOVABLE) with __GFP_NOMEMALLOC
> (gfp_pfmemalloc_allowed() returns false) __alloc_pages_slowpath()
> may call __alloc_pages_direct_compact() and unconditionally clear
> PF_MEMALLOC:

Not sure what is the bug here. __GFP_NOMEMALLOC is supposed to inhibit
PF_MEMALLOC. And we do not recurse to the reclaim path. We only do the
compaction. Or what am I missing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
