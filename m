Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 9D5546B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:45:21 -0400 (EDT)
Date: Thu, 5 Jul 2012 09:45:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
In-Reply-To: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.00.1207050942540.4984@router.home>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

On Tue, 3 Jul 2012, Jiang Liu wrote:

> Several subsystems, including memory-failure, swap, sparse, DRBD etc,
> use PageSlab() to check whether a page is managed by SLAB/SLUB/SLOB.
> And they treat slab pages differently from pagecache/anonymous pages.
>
> But it's unsafe to use PageSlab() to detect whether a page is managed by
> SLUB. SLUB allocates compound pages when page order is bigger than 0 and
> only sets PG_slab on head pages. So if a SLUB object is hosted by a tail
> page, PageSlab() will incorrectly return false for that object.

This is not an issue only with slab allocators. Multiple kernel systems
may do a compound order allocation for some or the other metadata and
will not mark the page in any special way. What makes the slab allocators
so special that you need to do this?

> So introduce a transparent huge page and compound page safe macro as below
> to check whether a page is managed by SLAB/SLUB/SLOB allocator.

Why? Any page is unsafe to touch unless you can account for all references to
the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
