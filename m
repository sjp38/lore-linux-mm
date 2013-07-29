Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 729CF6B0034
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:23:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Wed, 31 Jul 2013 01:07:42 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6FA663578050
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:39 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UF7wH07668142
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:07:59 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6UFNcga002281
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:23:38 +1000
Date: Mon, 29 Jul 2013 10:08:05 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/5] mm/zswap: use postorder iteration when destroying
 rbtree
Message-ID: <20130729150805.GC4381@variantweb.net>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
 <1374873223-25557-6-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374873223-25557-6-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Fri, Jul 26, 2013 at 02:13:43PM -0700, Cody P Schafer wrote:
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> ---
>  mm/zswap.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..98d99c4 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -791,25 +791,14 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  {
>  	struct zswap_tree *tree = zswap_trees[type];
>  	struct rb_node *node;

Getting used variable warning on this now.  Just need to remove it.

Seth

> -	struct zswap_entry *entry;
> +	struct zswap_entry *entry, *n;
> 
>  	if (!tree)
>  		return;
> 
>  	/* walk the tree and free everything */
>  	spin_lock(&tree->lock);
> -	/*
> -	 * TODO: Even though this code should not be executed because
> -	 * the try_to_unuse() in swapoff should have emptied the tree,
> -	 * it is very wasteful to rebalance the tree after every
> -	 * removal when we are freeing the whole tree.
> -	 *
> -	 * If post-order traversal code is ever added to the rbtree
> -	 * implementation, it should be used here.
> -	 */
> -	while ((node = rb_first(&tree->rbroot))) {
> -		entry = rb_entry(node, struct zswap_entry, rbnode);
> -		rb_erase(&entry->rbnode, &tree->rbroot);
> +	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
>  		zbud_free(tree->pool, entry->handle);
>  		zswap_entry_cache_free(entry);
>  		atomic_dec(&zswap_stored_pages);
> -- 
> 1.8.3.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
