Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 36F186B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 23:37:32 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id wn14so2272431obc.4
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 20:37:31 -0700 (PDT)
Message-ID: <515E46F3.1060400@gmail.com>
Date: Fri, 05 Apr 2013 11:37:23 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 04/30] radix-tree: implement preload for multiple
 contiguous elements
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Kirill,
On 03/15/2013 01:50 AM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Currently radix_tree_preload() only guarantees enough nodes to insert
> one element. It's a hard limit. You cannot batch a number insert under
> one tree_lock.
>
> This patch introduces radix_tree_preload_count(). It allows to
> preallocate nodes enough to insert a number of *contiguous* elements.
>
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   include/linux/radix-tree.h |    3 +++
>   lib/radix-tree.c           |   32 +++++++++++++++++++++++++-------
>   2 files changed, 28 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index ffc444c..81318cb 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -83,6 +83,8 @@ do {									\
>   	(root)->rnode = NULL;						\
>   } while (0)
>   
> +#define RADIX_TREE_PRELOAD_NR		512 /* For THP's benefit */
> +
>   /**
>    * Radix-tree synchronization
>    *
> @@ -231,6 +233,7 @@ unsigned long radix_tree_next_hole(struct radix_tree_root *root,
>   unsigned long radix_tree_prev_hole(struct radix_tree_root *root,
>   				unsigned long index, unsigned long max_scan);
>   int radix_tree_preload(gfp_t gfp_mask);
> +int radix_tree_preload_count(unsigned size, gfp_t gfp_mask);
>   void radix_tree_init(void);
>   void *radix_tree_tag_set(struct radix_tree_root *root,
>   			unsigned long index, unsigned int tag);
> diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> index e796429..9bef0ac 100644
> --- a/lib/radix-tree.c
> +++ b/lib/radix-tree.c
> @@ -81,16 +81,24 @@ static struct kmem_cache *radix_tree_node_cachep;
>    * The worst case is a zero height tree with just a single item at index 0,
>    * and then inserting an item at index ULONG_MAX. This requires 2 new branches
>    * of RADIX_TREE_MAX_PATH size to be created, with only the root node shared.
> + *
> + * Worst case for adding N contiguous items is adding entries at indexes
> + * (ULONG_MAX - N) to ULONG_MAX. It requires nodes to insert single worst-case
> + * item plus extra nodes if you cross the boundary from one node to the next.
> + *

What's the meaning of this comments? Could you explain in details? I 
also don't understand #define RADIX_TREE_PRELOAD_SIZE 
(RADIX_TREE_MAX_PATH * 2 - 1), why RADIX_TREE_MAX_PATH * 2 - 1, I fail 
to understand comments above it.

>    * Hence:
>    */
> -#define RADIX_TREE_PRELOAD_SIZE (RADIX_TREE_MAX_PATH * 2 - 1)
> +#define RADIX_TREE_PRELOAD_MIN (RADIX_TREE_MAX_PATH * 2 - 1)
> +#define RADIX_TREE_PRELOAD_MAX \
> +	(RADIX_TREE_PRELOAD_MIN + \
> +	 DIV_ROUND_UP(RADIX_TREE_PRELOAD_NR - 1, RADIX_TREE_MAP_SIZE))
>   
>   /*
>    * Per-cpu pool of preloaded nodes
>    */
>   struct radix_tree_preload {
>   	int nr;
> -	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_SIZE];
> +	struct radix_tree_node *nodes[RADIX_TREE_PRELOAD_MAX];
>   };
>   static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
>   
> @@ -257,29 +265,34 @@ radix_tree_node_free(struct radix_tree_node *node)
>   
>   /*
>    * Load up this CPU's radix_tree_node buffer with sufficient objects to
> - * ensure that the addition of a single element in the tree cannot fail.  On
> - * success, return zero, with preemption disabled.  On error, return -ENOMEM
> + * ensure that the addition of *contiguous* elements in the tree cannot fail.
> + * On success, return zero, with preemption disabled.  On error, return -ENOMEM
>    * with preemption not disabled.
>    *
>    * To make use of this facility, the radix tree must be initialised without
>    * __GFP_WAIT being passed to INIT_RADIX_TREE().
>    */
> -int radix_tree_preload(gfp_t gfp_mask)
> +int radix_tree_preload_count(unsigned size, gfp_t gfp_mask)
>   {
>   	struct radix_tree_preload *rtp;
>   	struct radix_tree_node *node;
>   	int ret = -ENOMEM;
> +	int alloc = RADIX_TREE_PRELOAD_MIN +
> +		DIV_ROUND_UP(size - 1, RADIX_TREE_MAP_SIZE);
> +
> +	if (size > RADIX_TREE_PRELOAD_NR)
> +		return -ENOMEM;
>   
>   	preempt_disable();
>   	rtp = &__get_cpu_var(radix_tree_preloads);
> -	while (rtp->nr < ARRAY_SIZE(rtp->nodes)) {
> +	while (rtp->nr < alloc) {
>   		preempt_enable();
>   		node = kmem_cache_alloc(radix_tree_node_cachep, gfp_mask);
>   		if (node == NULL)
>   			goto out;
>   		preempt_disable();
>   		rtp = &__get_cpu_var(radix_tree_preloads);
> -		if (rtp->nr < ARRAY_SIZE(rtp->nodes))
> +		if (rtp->nr < alloc)
>   			rtp->nodes[rtp->nr++] = node;
>   		else
>   			kmem_cache_free(radix_tree_node_cachep, node);
> @@ -288,6 +301,11 @@ int radix_tree_preload(gfp_t gfp_mask)
>   out:
>   	return ret;
>   }
> +
> +int radix_tree_preload(gfp_t gfp_mask)
> +{
> +	return radix_tree_preload_count(1, gfp_mask);
> +}
>   EXPORT_SYMBOL(radix_tree_preload);
>   
>   /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
