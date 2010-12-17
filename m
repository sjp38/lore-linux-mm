Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6142F6B0089
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 22:28:47 -0500 (EST)
Date: Fri, 17 Dec 2010 12:27:21 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [RFC] radix_tree_destroy?
Message-ID: <20101217032721.GD20847@linux-sh.org>
References: <62b1cf2f-17ec-45c9-a980-308d9b75cdc5@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62b1cf2f-17ec-45c9-a980-308d9b75cdc5@default>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 08:27:41AM -0800, Dan Magenheimer wrote:
> +static void
> +radix_tree_node_destroy(struct radix_tree_node *node, unsigned int height,
> +			void (*slot_free)(void *))
> +{
> +	int i;
> +
> +	if (height == 0)
> +		return;
> +	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
> +		if (node->slots[i]) {
> +			if (height > 1) {
> +				radix_tree_node_destroy(node->slots[i],
> +					height-1, slot_free);
> +				radix_tree_node_free(node->slots[i]);
> +				node->slots[i] = NULL;
> +			} else
> +				slot_free(node->slots[i]);
> +		}
> +	}
> +}
> +
> +void radix_tree_destroy(struct radix_tree_root *root, void (*slot_free)(void *))
> +{
> +	if (root->rnode == NULL)
> +		return;
> +	if (root->height == 0)
> +		slot_free(root->rnode);

Don't you want indirect_to_ptr(root->rnode) here? You probably also don't
want the callback in the !radix_tree_is_indirect_ptr() case.

> +	else {
> +		radix_tree_node_destroy(root->rnode, root->height, slot_free);
> +		radix_tree_node_free(root->rnode);
> +		root->height = 0;
> +	}
> +	root->rnode = NULL;
> +}

The above will handle the nodes, but what about the root? It looks like
you're at least going to leak tags on the root, so at the very least
you'd still want a root_tag_clear_all() here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
