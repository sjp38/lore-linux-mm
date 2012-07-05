Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 4A0D86B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 11:56:13 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so15759112pbb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 08:56:12 -0700 (PDT)
Message-ID: <4FF5B909.30409@gmail.com>
Date: Thu, 05 Jul 2012 23:55:53 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/4] mm: introduce a safer interface to check whether
 a page is managed by SLxB
References: <1341287837-7904-1-git-send-email-jiang.liu@huawei.com> <alpine.DEB.2.00.1207050942540.4984@router.home>
In-Reply-To: <alpine.DEB.2.00.1207050942540.4984@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/05/2012 10:45 PM, Christoph Lameter wrote:
> On Tue, 3 Jul 2012, Jiang Liu wrote:
> 
>> Several subsystems, including memory-failure, swap, sparse, DRBD etc,
>> use PageSlab() to check whether a page is managed by SLAB/SLUB/SLOB.
>> And they treat slab pages differently from pagecache/anonymous pages.
>>
>> But it's unsafe to use PageSlab() to detect whether a page is managed by
>> SLUB. SLUB allocates compound pages when page order is bigger than 0 and
>> only sets PG_slab on head pages. So if a SLUB object is hosted by a tail
>> page, PageSlab() will incorrectly return false for that object.
> 
> This is not an issue only with slab allocators. Multiple kernel systems
> may do a compound order allocation for some or the other metadata and
> will not mark the page in any special way. What makes the slab allocators
> so special that you need to do this?
HI Chris,
	I think here PageSlab() is used to check whether a page hosting a memory
object is managed/allocated by the slab allocator. If it's allocated by slab 
allocator, we could use kfree() to free the object.
	For SLUB allocator, if the memory space needed to host a memory object
is bigger than 2 pages, it directly depends on page allocator to fulfill the
request. But SLUB may allocate a compound page of two pages and only sets
PG_slab on the head page. So if a memory object is hosted by the second page,
we will get a wrong conclusion that the memory object wasn't allocated by slab.
	We encountered this issue when trying to implement physical memory hot-removal.
After removing a memory device, we need to tear down memory management structures
of the removed memory device. Those memory management structures may be allocated
by bootmem allocator at boot time, or allocated by slab allocator at runtime when
hot-adding memory device. So in our case, PageSlab() is used to distinguish between
bootmem allocator and slab allocator. With SLUB, some pages will never be released
due to the issue described above.
	Thanks!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
