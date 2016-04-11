Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB226B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 00:35:27 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id 184so116293562pff.0
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 21:35:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 90si997520pfs.233.2016.04.10.21.35.25
        for <linux-mm@kvack.org>;
        Sun, 10 Apr 2016 21:35:26 -0700 (PDT)
Date: Mon, 11 Apr 2016 13:35:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 00/16] Support non-lru page migration
Message-ID: <20160411043557.GC4804@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <20160404131718.GA18963@e106921-lin.trondheim.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160404131718.GA18963@e106921-lin.trondheim.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Mon, Apr 04, 2016 at 03:17:18PM +0200, John Einar Reitan wrote:
> On Wed, Mar 30, 2016 at 04:11:59PM +0900, Minchan Kim wrote:
> > Recently, I got many reports about perfermance degradation
> > in embedded system(Android mobile phone, webOS TV and so on)
> > and failed to fork easily.
> > 
> > The problem was fragmentation caused by zram and GPU driver
> > pages. Their pages cannot be migrated so compaction cannot
> > work well, either so reclaimer ends up shrinking all of working
> > set pages. It made system very slow and even to fail to fork
> > easily.
> > 
> > Other pain point is that they cannot work with CMA.
> > Most of CMA memory space could be idle(ie, it could be used
> > for movable pages unless driver is using) but if driver(i.e.,
> > zram) cannot migrate his page, that memory space could be
> > wasted. In our product which has big CMA memory, it reclaims
> > zones too exccessively although there are lots of free space
> > in CMA so system was very slow easily.
> > 
> > To solve these problem, this patch try to add facility to
> > migrate non-lru pages via introducing new friend functions
> > of migratepage in address_space_operation and new page flags.
> > 
> > 	(isolate_page, putback_page)
> > 	(PG_movable, PG_isolated)
> > 
> > For details, please read description in
> > "mm/compaction: support non-lru movable page migration".
> 
> Thanks, this mirrors what we see with the ARM Mali GPU drivers too.
> 
> One thing with the current design which worries me is the potential
> for multiple calls due to many separated pages being migrated.
> On GPUs (or any other device) which has an IOMMU and L2 cache, which
> isn't coherent with the CPU, we must do L2 cache flush & invalidation
> per page. I guess batching pages isn't easily possible?
> 

Hmm, I think it seems to cause many code stirring but surely worth
to work. So, IMMO, it would be better to add such feature after soft
landing of current work.

Anyway, I will Cc'ed you in next revision.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
