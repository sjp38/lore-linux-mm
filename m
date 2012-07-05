Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id B704E6B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 13:36:18 -0400 (EDT)
Date: Thu, 5 Jul 2012 12:36:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
In-Reply-To: <4FF5B909.30409@gmail.com>
Message-ID: <alpine.DEB.2.00.1207051229490.8670@router.home>
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050942540.4984@router.home> <4FF5B909.30409@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 5 Jul 2012, Jiang Liu wrote:

> 	I think here PageSlab() is used to check whether a page hosting a memory
> object is managed/allocated by the slab allocator. If it's allocated by slab
> allocator, we could use kfree() to free the object.

This is BS (here? what does that refer to). Could you please respond to my
email?

> 	We encountered this issue when trying to implement physical memory hot-removal.
> After removing a memory device, we need to tear down memory management structures
> of the removed memory device. Those memory management structures may be allocated
> by bootmem allocator at boot time, or allocated by slab allocator at runtime when
> hot-adding memory device. So in our case, PageSlab() is used to distinguish between
> bootmem allocator and slab allocator. With SLUB, some pages will never be released
> due to the issue described above.

Trying to be more detailed that in my last email:

These compound pages could also be allocated by any other kernel subsystem
for metadata purposes and they will never be marked as slab pages. These
generic structures generally cannot be removed.

For the slab allocators: Only kmalloc memory uses the unmarked compound
pages and those kmalloc objects are never recoverable. You can only
recover objects that are in slabs marked reclaimable and those are
properly marked as slab pages.

AFAICT the patchset is pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
