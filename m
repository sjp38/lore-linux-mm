Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8C066B0279
	for <linux-mm@kvack.org>; Mon, 22 May 2017 22:51:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a66so149737340pfl.6
        for <linux-mm@kvack.org>; Mon, 22 May 2017 19:51:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p189sor482970pfg.9.2017.05.22.19.51.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 May 2017 19:51:21 -0700 (PDT)
Date: Mon, 22 May 2017 19:51:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm, something wring in page_lock_anon_vma_read()?
In-Reply-To: <59239C4C.5020709@huawei.com>
Message-ID: <alpine.LSU.2.11.1705221943490.5541@eggly.anvils>
References: <591D6D79.7030704@huawei.com> <591EB25C.9080901@huawei.com> <591EBE71.7080402@huawei.com> <alpine.LSU.2.11.1705191453040.3819@eggly.anvils> <591F9A09.6010707@huawei.com> <alpine.LSU.2.11.1705191852360.11060@eggly.anvils> <591FA78E.9050307@huawei.com>
 <alpine.LSU.2.11.1705191935220.11750@eggly.anvils> <5922B3D4.1030700@huawei.com> <alpine.LSU.2.11.1705221213580.4090@eggly.anvils> <59239C4C.5020709@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, aarcange@redhat.com, sumeet.keswani@hpe.com, Rik van Riel <riel@redhat.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>

On Tue, 23 May 2017, Xishi Qiu wrote:
> On 2017/5/23 3:26, Hugh Dickins wrote:
> > I mean, there are various places in mm/memory.c which decide what they
> > intend to do based on orig_pte, then take pte lock, then check that
> > pte_same(pte, orig_pte) before taking it any further.  If a pte_same()
> > check were missing (I do not know of any such case), then two racing
> > tasks might install the same pte, one on top of the other - page
> > mapcount being incremented twice, but decremented only once when
> > that pte is finally unmapped later.
> > 
> 
> Hi Hugh,
> 
> Do you mean that the ptes from two racing point to the same page?
> or the two racing point to two pages, but one covers the other later?
> and the first page maybe alone in the lru list, and it will never be freed
> when the process exit.
> 
> We got this info before crash.
> [26068.316592] BUG: Bad rss-counter state mm:ffff8800a7de2d80 idx:1 val:1

I might mean either: you are taking my suggestion too seriously,
it is merely a suggestion of one way in which this could happen.

Another way is ordinary memory corruption (whether by software error
or by flipped DRAM bits) of a page table: that could end up here too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
