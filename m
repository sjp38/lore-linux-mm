Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id BFE426B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 02:20:29 -0400 (EDT)
Subject: Re: [PATCHv9 4/8] zswap: add to mm/
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
In-Reply-To: <1365617940-21623-5-git-send-email-sjenning@linux.vnet.ibm.com>
Date: Fri, 12 Apr 2013 23:20:27 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <D33AB581-608A-43DD-B47F-AA93DC9CA432@FreeBSD.org>
References: <1365617940-21623-1-git-send-email-sjenning@linux.vnet.ibm.com> <1365617940-21623-5-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hello,

On Apr 10, 2013, at 11:18 , Seth Jennings wrote:

> +/* invalidates all pages for the given swap type */
> +static void zswap_frontswap_invalidate_area(unsigned type)
> +{
> +	struct zswap_tree *tree = zswap_trees[type];
> +	struct rb_node *node;
> +	struct zswap_entry *entry;
> +
> +	if (!tree)
> +		return;
> +
> +	/* walk the tree and free everything */
> +	spin_lock(&tree->lock);
> +	/*
> +	 * TODO: Even though this code should not be executed because
> +	 * the try_to_unuse() in swapoff should have emptied the tree,
> +	 * it is very wasteful to rebalance the tree after every
> +	 * removal when we are freeing the whole tree.
> +	 *
> +	 * If post-order traversal code is ever added to the rbtree
> +	 * implementation, it should be used here.
> +	 */
> +	while ((node = rb_first(&tree->rbroot))) {
> +		entry = rb_entry(node, struct zswap_entry, rbnode);
> +		rb_erase(&entry->rbnode, &tree->rbroot);
> +		zs_free(tree->pool, entry->handle);
> +		zswap_entry_cache_free(entry);
> +	}
> +	tree->rbroot = RB_ROOT;
> +	spin_unlock(&tree->lock);
> +}

Should both the pool and the tree also be freed, here?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
