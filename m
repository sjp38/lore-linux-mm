Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id E50356B0033
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 02:31:29 -0400 (EDT)
Message-ID: <522976B4.3010509@oracle.com>
Date: Fri, 06 Sep 2013 14:31:16 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/4] mm/zswap: bugfix: memory leak when re-swapon
References: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
In-Reply-To: <000901ceaac0$a5f28420$f1d78c60$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 09/06/2013 01:16 PM, Weijie Yang wrote:
> zswap_tree is not freed when swapoff, and it got re-kmalloc in swapon,
> so memory-leak occurs.
> 
> Modify: free memory of zswap_tree in zswap_frontswap_invalidate_area().
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Reviewed-by: Bob Liu <bob.liu@oracle.com>

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
>  }
>  
>  static struct zbud_ops zswap_zbud_ops = {
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
