Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B2ABF6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:46:33 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id q2so16961723pap.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 23:46:33 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r27si7822847pfi.37.2016.07.18.23.46.32
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 23:46:33 -0700 (PDT)
Date: Tue, 19 Jul 2016 15:50:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mem-hotplug: use GFP_HIGHUSER_MOVABLE in,
 alloc_migrate_target()
Message-ID: <20160719065042.GC17479@js1304-P5Q-DELUXE>
References: <57884EAA.9030603@huawei.com>
 <20160718055150.GF9460@js1304-P5Q-DELUXE>
 <578C8C8A.8000007@huawei.com>
 <7ce4a7ac-07aa-6a81-48c2-91c4a9355778@suse.cz>
 <578C93CF.50509@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578C93CF.50509@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 04:31:11PM +0800, Xishi Qiu wrote:
> On 2016/7/18 16:05, Vlastimil Babka wrote:
> 
> > On 07/18/2016 10:00 AM, Xishi Qiu wrote:
> >> On 2016/7/18 13:51, Joonsoo Kim wrote:
> >>
> >>> On Fri, Jul 15, 2016 at 10:47:06AM +0800, Xishi Qiu wrote:
> >>>> alloc_migrate_target() is called from migrate_pages(), and the page
> >>>> is always from user space, so we can add __GFP_HIGHMEM directly.
> >>>
> >>> No, all migratable pages are not from user space. For example,
> >>> blockdev file cache has __GFP_MOVABLE and migratable but it has no
> >>> __GFP_HIGHMEM and __GFP_USER.
> >>>
> >>
> >> Hi Joonsoo,
> >>
> >> So the original code "gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;"
> >> is not correct?
> > 
> > It's not incorrect. GFP_USER just specifies some reclaim flags, and may perhaps restrict allocation through __GFP_HARDWALL, where the original
> > page could have been allocated without the restriction. But it doesn't put the place in an unexpected address range, as placing a non-highmem page into highmem could. __GFP_MOVABLE then just controls a heuristic for placement within a zone.
> > 
> >>> And, zram's memory isn't GFP_HIGHUSER_MOVABLE but has __GFP_MOVABLE.
> >>>
> >>
> >> Can we distinguish __GFP_MOVABLE or GFP_HIGHUSER_MOVABLE when doing
> >> mem-hotplug?
> > 
> > I don't understand the question here, can you rephrase with more detail? Thanks.
> > 
> 
> Hi Joonsoo,

Above is answered by Vlastimil. :)

> When we do memory offline, and the zone is movable zone,
> can we use "alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);" to alloc a
> new page? the nid is the next node.

I don't know much about memory offline, but, AFAIK, memory offline
could happen on non-movable zone like as ZONE_NORMAL. Perhaps, you can add
"if zone of the page is movable zone then alloc with GFP_HIGHUSER_MOVABLE".

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
