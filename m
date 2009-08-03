Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EA8316B005D
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:35:36 -0400 (EDT)
Message-ID: <4A76FA08.9090903@redhat.com>
Date: Mon, 03 Aug 2009 17:54:00 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/12] ksm: pages_unshared and pages_volatile
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031311061.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031311061.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> The pages_shared and pages_sharing counts give a good picture of how
> successful KSM is at sharing; but no clue to how much wasted work it's
> doing to get there.  Add pages_unshared (count of unique pages waiting
> in the unstable tree, hoping to find a mate) and pages_volatile.
>
> pages_volatile is harder to define.  It includes those pages changing
> too fast to get into the unstable tree, but also whatever other edge
> conditions prevent a page getting into the trees: a high value may
> deserve investigation.  Don't try to calculate it from the various
> conditions: it's the total of rmap_items less those accounted for.
>
> Also show full_scans: the number of completed scans of everything
> registered in the mm list.
>
> The locking for all these counts is simply ksm_thread_mutex.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>  mm/ksm.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 51 insertions(+), 1 deletion(-)
>
> --- ksm2/mm/ksm.c	2009-08-02 13:49:43.000000000 +0100
> +++ ksm3/mm/ksm.c	2009-08-02 13:49:51.000000000 +0100
> @@ -155,6 +155,12 @@ static unsigned long ksm_pages_shared;
>  /* The number of page slots additionally sharing those nodes */
>  static unsigned long ksm_pages_sharing;
>  
> +/* The number of nodes in the unstable tree */
> +static unsigned long ksm_pages_unshared;
> +
> +/* The number of rmap_items in use: to calculate pages_volatile */
> +static unsigned long ksm_rmap_items;
> +
>  /* Limit on the number of unswappable pages used */
>  static unsigned long ksm_max_kernel_pages;
>  
> @@ -204,11 +210,17 @@ static void __init ksm_slab_free(void)
>  
>  static inline struct rmap_item *alloc_rmap_item(void)
>  {
> -	return kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> +	struct rmap_item *rmap_item;
> +
> +	rmap_item = kmem_cache_zalloc(rmap_item_cache, GFP_KERNEL);
> +	if (rmap_item)
> +		ksm_rmap_items++;
> +	return rmap_item;
>  }
>  
>  static inline void free_rmap_item(struct rmap_item *rmap_item)
>  {
> +	ksm_rmap_items--;
>  	rmap_item->mm = NULL;	/* debug safety */
>  	kmem_cache_free(rmap_item_cache, rmap_item);
>  }
> @@ -419,6 +431,7 @@ static void remove_rmap_item_from_tree(s
>  		BUG_ON(age > 2);
>  		if (!age)
>  			rb_erase(&rmap_item->node, &root_unstable_tree);
> +		ksm_pages_unshared--;
>  	}
>  
>  	rmap_item->address &= PAGE_MASK;
> @@ -1002,6 +1015,7 @@ static struct rmap_item *unstable_tree_s
>  	rb_link_node(&rmap_item->node, parent, new);
>  	rb_insert_color(&rmap_item->node, &root_unstable_tree);
>  
> +	ksm_pages_unshared++;
>  	return NULL;
>  }
>  
> @@ -1098,6 +1112,8 @@ static void cmp_and_merge_page(struct pa
>  		if (!err) {
>  			rb_erase(&tree_rmap_item->node, &root_unstable_tree);
>  			tree_rmap_item->address &= ~NODE_FLAG;
> +			ksm_pages_unshared--;
> +
>  			/*
>  			 * If we fail to insert the page into the stable tree,
>  			 * we will have 2 virtual addresses that are pointing
> @@ -1481,6 +1497,37 @@ static ssize_t pages_sharing_show(struct
>  }
>  KSM_ATTR_RO(pages_sharing);
>  
> +static ssize_t pages_unshared_show(struct kobject *kobj,
> +				   struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", ksm_pages_unshared);
> +}
> +KSM_ATTR_RO(pages_unshared);
> +
> +static ssize_t pages_volatile_show(struct kobject *kobj,
> +				   struct kobj_attribute *attr, char *buf)
> +{
> +	long ksm_pages_volatile;
> +
> +	ksm_pages_volatile = ksm_rmap_items - ksm_pages_shared
> +				- ksm_pages_sharing - ksm_pages_unshared;
> +	/*
> +	 * It was not worth any locking to calculate that statistic,
> +	 * but it might therefore sometimes be negative: conceal that.
> +	 */
> +	if (ksm_pages_volatile < 0)
> +		ksm_pages_volatile = 0;
> +	return sprintf(buf, "%ld\n", ksm_pages_volatile);

ACK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
