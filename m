From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 00/10] implement zsmalloc shrinking
Date: Thu, 11 Sep 2014 22:14:56 -0500
Message-ID: <20140912031456.GA17818@cerebellum.variantweb.net>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Thu, Sep 11, 2014 at 04:53:51PM -0400, Dan Streetman wrote:
> Now that zswap can use zsmalloc as a storage pool via zpool, it will
> try to shrink its zsmalloc zs_pool once it reaches its max_pool_percent
> limit.  These patches implement zsmalloc shrinking.  The way the pool is
> shrunk is by finding a zspage and reclaiming it, by evicting each of its
> objects that is in use.
> 
> Without these patches zswap, and any other future user of zpool/zsmalloc
> that attempts to shrink the zpool/zs_pool, will only get errors and will
> be unable to shrink its zpool/zs_pool.  With the ability to shrink, zswap
> can keep the most recent compressed pages in memory.
> 
> Note that the design of zsmalloc makes it impossible to actually find the
> LRU zspage, so each class and fullness group is searched in a round-robin
> method to find the next zspage to reclaim.  Each fullness group orders its
> zspages in LRU order, so the oldest zspage is used for each fullness group.

After a quick inspection, the code looks reasonable.  Thanks!

I do wonder if this actually works well in practice though.

Have you run any tests that overflow the zsmalloc pool?  What does
performance look like at that point?  I would expect it would be worse
than allowing the overflow pages to go straight to swap, since, in
almost every case, you would be writing back more than one page.  In
some cases, MANY more than one page (up to 255 for a full zspage in the
minimum class size).

There have always been two sticking points with shrinking in zsmalloc
(one of which you have mentioned)

1) Low LRU locality among objects in a zspage.  zsmalloc values density
over reclaim ordering so it is hard to make good reclaim selection
decisions.

2) Writeback storm. If you try to reclaim a zspage with lots of objects
(i.e. small class size in fullness group ZS_FULL) you can create a ton
of memory pressure by uncompressing objects and adding them to the swap
cache.

A few reclaim models:

- Reclaim zspage with fewest objects: 

  This reduces writeback storm but would likely reclaim more recently
  allocated zspages that contain more recently used (added) objects.

- Reclaim zspage with largest class size:

  This also reduces writeback storm as zspages with larger objects
  (poorly compressible) are written back first.  This is not LRU though.
  This is the best of the options IMHO.  I'm not saying that is it good.

- Reclaim LRU round-robin through the fullness groups (approach used):

  The LRU here is limited since as the number of object in the zspage
  increase, it is LRU only wrt the most recently added object in the
  zspage.  It also has high risk of a writeback storm since it will
  eventually try to reclaim from the ZS_FULL group of the minimum class
  size.

There is also the point that writing back objects might not be the best
way to reclaim from zsmalloc at all.  Maybe compaction is the way to go.
This was recently discussed on the list.

http://marc.info/?l=linux-mm&m=140917577412645&w=2

As mentioned in that thread, it would require zsmalloc to add a
layer of indirection so that the objects could be relocated without
notifying the user.  The compaction mechanism would also be "fun" to
design I imagine.  But, in my mind, compaction is really needed,
regardless of whether or not zsmalloc is capable of writeback, and would
be more beneficial.

tl;dr version:

I would really need to see some evidence (and try it myself) that this
didn't run off a cliff when you overflow the zsmalloc pool.  It seems
like additional risk and complexity to avoid LRU inversion _after_ the
pool overflows.  And by "avoid" I mean "maybe avoid" as the reclaim
selection is just slightly more LRUish than random selection.

Thanks,
Seth

> 
> ---
> 
> This patch set applies to linux-next.
> 
> Dan Streetman (10):
>   zsmalloc: fix init_zspage free obj linking
>   zsmalloc: add fullness group list for ZS_FULL zspages
>   zsmalloc: always update lru ordering of each zspage
>   zsmalloc: move zspage obj freeing to separate function
>   zsmalloc: add atomic index to find zspage to reclaim
>   zsmalloc: add zs_ops to zs_pool
>   zsmalloc: add obj_handle_is_free()
>   zsmalloc: add reclaim_zspage()
>   zsmalloc: add zs_shrink()
>   zsmalloc: implement zs_zpool_shrink() with zs_shrink()
> 
>  drivers/block/zram/zram_drv.c |   2 +-
>  include/linux/zsmalloc.h      |   7 +-
>  mm/zsmalloc.c                 | 314 +++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 290 insertions(+), 33 deletions(-)
> 
> -- 
> 1.8.3.1
> 
