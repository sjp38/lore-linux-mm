Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2DD8E6B0038
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:23:50 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Tue, 30 Jul 2013 20:46:42 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C27BB394004D
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 20:53:34 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UFNZE949021128
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 20:53:37 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UFNcMH018675
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:38 +1000
Date: Mon, 29 Jul 2013 10:01:47 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/5] rbtree: add postorder iteration functions
Message-ID: <20130729150147.GA4381@variantweb.net>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
 <1374873223-25557-2-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374873223-25557-2-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Fri, Jul 26, 2013 at 02:13:39PM -0700, Cody P Schafer wrote:
> Add postorder iteration functions for rbtree. These are useful for
> safely freeing an entire rbtree without modifying the tree at all.
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  include/linux/rbtree.h |  4 ++++
>  lib/rbtree.c           | 40 ++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 44 insertions(+)
> 
> diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
> index 0022c1b..2879e96 100644
> --- a/include/linux/rbtree.h
> +++ b/include/linux/rbtree.h
> @@ -68,6 +68,10 @@ extern struct rb_node *rb_prev(const struct rb_node *);
>  extern struct rb_node *rb_first(const struct rb_root *);
>  extern struct rb_node *rb_last(const struct rb_root *);
> 
> +/* Postorder iteration - always visit the parent after it's children */

s/it's/its/

> +extern struct rb_node *rb_first_postorder(const struct rb_root *);
> +extern struct rb_node *rb_next_postorder(const struct rb_node *);
> +
>  /* Fast replacement of a single node without remove/rebalance/add/rebalance */
>  extern void rb_replace_node(struct rb_node *victim, struct rb_node *new, 
>  			    struct rb_root *root);
> diff --git a/lib/rbtree.c b/lib/rbtree.c
> index c0e31fe..65f4eff 100644
> --- a/lib/rbtree.c
> +++ b/lib/rbtree.c
> @@ -518,3 +518,43 @@ void rb_replace_node(struct rb_node *victim, struct rb_node *new,
>  	*new = *victim;
>  }
>  EXPORT_SYMBOL(rb_replace_node);
> +
> +static struct rb_node *rb_left_deepest_node(const struct rb_node *node)
> +{
> +	for (;;) {
> +		if (node->rb_left)
> +			node = node->rb_left;

Assigning to an argument passed as const seems weird to me.  I would
think it shouldn't compile but it does.  I guess my understanding of
const is incomplete.

> +		else if (node->rb_right)
> +			node = node->rb_right;
> +		else
> +			return (struct rb_node *)node;
> +	}
> +}
> +
> +struct rb_node *rb_next_postorder(const struct rb_node *node)
> +{
> +	const struct rb_node *parent;
> +	if (!node)
> +		return NULL;
> +	parent = rb_parent(node);

Again here.

Seth

> +
> +	/* If we're sitting on node, we've already seen our children */
> +	if (parent && node == parent->rb_left && parent->rb_right) {
> +		/* If we are the parent's left node, go to the parent's right
> +		 * node then all the way down to the left */
> +		return rb_left_deepest_node(parent->rb_right);
> +	} else
> +		/* Otherwise we are the parent's right node, and the parent
> +		 * should be next */
> +		return (struct rb_node *)parent;
> +}
> +EXPORT_SYMBOL(rb_next_postorder);
> +
> +struct rb_node *rb_first_postorder(const struct rb_root *root)
> +{
> +	if (!root->rb_node)
> +		return NULL;
> +
> +	return rb_left_deepest_node(root->rb_node);
> +}
> +EXPORT_SYMBOL(rb_first_postorder);
> -- 
> 1.8.3.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
