Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E8D5D6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 13:04:56 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 9 Sep 2013 11:04:56 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 0F0C8C90043
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 13:04:52 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89H4qAw37159010
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 17:04:52 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r89H3pIQ020546
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 14:03:51 -0300
Date: Mon, 9 Sep 2013 12:03:49 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/4] mm/zswap: bugfix: memory leak when re-swapon
Message-ID: <20130909170349.GD4701@variantweb.net>
References: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
> zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
> so memory-leak occurs.
> 
> Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> ---
>  mm/zswap.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..cbd9578 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -816,6 +816,10 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  	}
>  	tree->rbroot = RB_ROOT;
>  	spin_unlock(&tree->lock);
> +
> +	zbud_destroy_pool(tree->pool);
> +	kfree(tree);
> +	zswap_trees[type] = NULL;

You changed how this works from v1.  Any particular reason?

In this version you free the tree structure, which is fine as long as we
know for sure nothing will try to access it afterward unless there is a
swapon to reactivate it.

I'm just a little worried about a race here between a store and
invalidate_area.  I think there is probably some mechanism to prevent
this, I just haven't been able to demonstrate it to myself.

The situation I'm worried about is:

shrink_page_list()
add_to_swap() then return (gets the swap entry)
try_to_unmap() then return (sets the swap entry in the pte)
pageout()
swap_writepage()
zswap_frontswap_store()

interacting with a swapoff operation.

When zswap_frontswap_store() is called, we continue to hold the page
lock.  I think that might block the loop in try_to_unuse(), called by
swapoff, until we release it after the store.

I think it should be fine.  Just wanted to think it through.

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

>  }
> 
>  static struct zbud_ops zswap_zbud_ops = {
> -- 
> 1.7.10.4
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
