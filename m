Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E64D86B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 23:49:41 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so2017311pad.24
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:49:41 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id kn7si17709814pbc.66.2014.01.13.20.49.39
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 20:49:40 -0800 (PST)
Date: Tue, 14 Jan 2014 13:50:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zswap: Check all pool pages instead of one pool pages
Message-ID: <20140114045022.GZ1992@bbox>
References: <000101cf0ea0$f4e7c560$deb75020$@samsung.com>
 <20140113233505.GS1992@bbox>
 <52D4909B.7070107@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D4909B.7070107@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Cai Liu <cai.liu@samsung.com>, sjenning@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, liucai.lfn@gmail.com

Hello Bob,

On Tue, Jan 14, 2014 at 09:19:23AM +0800, Bob Liu wrote:
> 
> On 01/14/2014 07:35 AM, Minchan Kim wrote:
> > Hello,
> > 
> > On Sat, Jan 11, 2014 at 03:43:07PM +0800, Cai Liu wrote:
> >> zswap can support multiple swapfiles. So we need to check
> >> all zbud pool pages in zswap.
> > 
> > True but this patch is rather costly that we should iterate
> > zswap_tree[MAX_SWAPFILES] to check it. SIGH.
> > 
> > How about defining zswap_tress as linked list instead of static
> > array? Then, we could reduce unnecessary iteration too much.
> > 
> 
> But if use linked list, it might not easy to access the tree like this:
> struct zswap_tree *tree = zswap_trees[type];

struct zswap_tree {
    ..
    ..
    struct list_head list;
}

zswap_frontswap_init()
{
    ..
    ..
    zswap_trees[type] = tree;
    list_add(&tree->list, &zswap_list);
}

get_zswap_pool_pages(void)
{
    struct zswap_tree *cur;
    list_for_each_entry(cur, &zswap_list, list) {
        pool_pages += zbud_get_pool_size(cur->pool);
    }
    return pool_pages;
}


> 
> BTW: I'm still prefer to use dynamic pool size, instead of use
> zswap_is_full(). AFAIR, Seth has a plan to replace the rbtree with radix
> which will be more flexible to support this feature and page migration
> as well.
> 
> > Other question:
> > Why do we need to update zswap_pool_pages too frequently?
> > As I read the code, I think it's okay to update it only when user
> > want to see it by debugfs and zswap_is_full is called.
> > So could we optimize it out?
> > 
> >>
> >> Signed-off-by: Cai Liu <cai.liu@samsung.com>
> 
> Reviewed-by: Bob Liu <bob.liu@oracle.com>

Hmm, I really suprised you are okay in this code piece where we have
unnecessary cost most of case(ie, most system has a swap device) in
*mm* part.

Anyway, I don't want to merge this patchset.
If Andrew merge it and anybody doesn't do right work, I will send a patch.
Cai, Could you redo a patch?
I don't want to intercept your credit.

Even, we could optimize to reduce the the number of call as I said in
previous reply.

Thanks.

> 
> >> ---
> >>  mm/zswap.c |   18 +++++++++++++++---
> >>  1 file changed, 15 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> index d93afa6..2438344 100644
> >> --- a/mm/zswap.c
> >> +++ b/mm/zswap.c
> >> @@ -291,7 +291,6 @@ static void zswap_free_entry(struct zswap_tree *tree,
> >>  	zbud_free(tree->pool, entry->handle);
> >>  	zswap_entry_cache_free(entry);
> >>  	atomic_dec(&zswap_stored_pages);
> >> -	zswap_pool_pages = zbud_get_pool_size(tree->pool);
> >>  }
> >>  
> >>  /* caller must hold the tree lock */
> >> @@ -405,10 +404,24 @@ cleanup:
> >>  /*********************************
> >>  * helpers
> >>  **********************************/
> >> +static u64 get_zswap_pool_pages(void)
> >> +{
> >> +	int i;
> >> +	u64 pool_pages = 0;
> >> +
> >> +	for (i = 0; i < MAX_SWAPFILES; i++) {
> >> +		if (zswap_trees[i])
> >> +			pool_pages += zbud_get_pool_size(zswap_trees[i]->pool);
> >> +	}
> >> +	zswap_pool_pages = pool_pages;
> >> +
> >> +	return pool_pages;
> >> +}
> >> +
> >>  static bool zswap_is_full(void)
> >>  {
> >>  	return (totalram_pages * zswap_max_pool_percent / 100 <
> >> -		zswap_pool_pages);
> >> +		get_zswap_pool_pages());
> >>  }
> >>  
> >>  /*********************************
> >> @@ -716,7 +729,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >>  
> >>  	/* update stats */
> >>  	atomic_inc(&zswap_stored_pages);
> >> -	zswap_pool_pages = zbud_get_pool_size(tree->pool);
> >>  
> >>  	return 0;
> >>  
> >> -- 
> >> 1.7.10.4
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
