Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C21A96B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 01:47:19 -0400 (EDT)
Date: Mon, 19 Aug 2013 14:47:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [BUG REPORT] ZSWAP: theoretical race condition issues
Message-ID: <20130819054742.GA28062@bbox>
References: <CAL1ERfOiT7QV4UUoKi8+gwbHc9an4rUWriufpOJOUdnTYHHEAw@mail.gmail.com>
 <52118042.30101@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52118042.30101@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.magenheimer@oracle.com

On Mon, Aug 19, 2013 at 10:17:38AM +0800, Bob Liu wrote:
> Hi Weijie,
> 
> On 08/19/2013 12:14 AM, Weijie Yang wrote:
> > I found a few bugs in zswap when I review Linux-3.11-rc5, and I have
> > also some questions about it, described as following:
> > 
> > BUG:
> > 1. A race condition when reclaim a page
> > when a handle alloced from zbud, zbud considers this handle is used
> > validly by upper(zswap) and can be a candidate for reclaim.
> > But zswap has to initialize it such as setting swapentry and addding
> > it to rbtree. so there is a race condition, such as:
> > thread 0: obtain handle x from zbud_alloc
> > thread 1: zbud_reclaim_page is called
> > thread 1: callback zswap_writeback_entry to reclaim handle x
> > thread 1: get swpentry from handle x (it is random value now)
> > thread 1: bad thing may happen
> > thread 0: initialize handle x with swapentry

Nice catch!

> 
> Yes, this may happen potentially but in rare case.
> Because we have a LRU list for page frames, after Thread 0 called
> zbud_alloc the corresponding page will be add to the head of LRU
> list,While zbud_reclaim_page(Thread 1 called) is started from the tail
> of LRU list.
> 
> > Of course, this situation almost never happen, it is a "theoretical
> > race condition" issue.

But it's doable and we should prevent that although you feel it's rare
because system could go hang. When I look at the code, Why should zbud
have LRU logic instead of zswap? If I missed some history, sorry about that.
But at least to me, zbud is just allocator so it should have a role
to handle alloc/free object and how client of the allocator uses objects
depends on the upper layer so zbud should handle LRU. If so, we wouldn't
encounter this problem, either.

> > 
> > 2. Pollute swapcache data by add a pre-invalided swap page
> > when a swap_entry is invalidated, it will be reused by other anon
> > page. At the same time, zswap is reclaiming old page, pollute
> > swapcache of new page as a result, because old page and new page use
> > the same swap_entry, such as:
> > thread 1: zswap reclaim entry x
> > thread 0: zswap_frontswap_invalidate_page entry x
> > thread 0: entry x reused by other anon page
> > thread 1: add old data to swapcache of entry x
> 
> I didn't get your idea here, why thread1 will add old data to entry x?
> 
> > thread 0: swapcache of entry x is polluted
> > Of course, this situation almost never happen, it is another
> > "theoretical race condition" issue.

Don't swapcache_prepare close the race?

> > 
> > 3. Frontswap uses frontswap_map bitmap to track page in "backend"
> > implementation, when zswap reclaim a
> > page, the corresponding bitmap record is not cleared.
> >
> 
> That's true, but I don't think it's a big problem.
> Only waste little time to search rbtree during zswap_frontswap_load().
> 
> > 4. zswap_tree is not freed when swapoff, and it got re-kzalloc in
> > swapon, memory leak occurs.
> 
> Nice catch! I think it should be freed in zswap_frontswap_invalidate_area().
> 
> > 
> > questions:
> > 1. How about SetPageReclaim befor __swap_writepage, so that move it to
> > the tail of the inactive list?

It's a good idea to avoid unnecessary page scanning.

> 
> It will be added to inactive now.
> 
> > 2. zswap uses GFP_KERNEL flag to alloc things in store and reclaim
> > function, does this lead to these function called recursively?
> 
> Yes, that's a potential problem.

It should use GFP_NOIO.

> 
> > 3. for reclaiming one zbud page which contains two buddies, zswap
> > needs to alloc two pages. Does this reclaim cost-efficient?

It would be better to evict zpage which is a compressed sequence of
PAGE_SIZE bytes rather than decompresesed PAGE_SIZE bytes a page when
we are about to reclaim the page but it's hard part from frontswap API.

> > 
> 
> Yes, that's a problem too. And that's why we use zbud as the default
> allocator instead of zsmalloc.
> I think improving the write back path of zswap is the next important
> step for zswap.
> 
> -- 
> Regards,
> -Bob
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
