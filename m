Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 866AD6B01EF
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 11:55:48 -0400 (EDT)
Date: Fri, 16 Apr 2010 10:55:07 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
In-Reply-To: <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1004161049130.7710@router.home>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>  <s2wcf18f8341004130120jc473e334pa6407b8d2e1ccf0a@mail.gmail.com>  <20100413083855.GS25756@csn.ul.ie>  <q2ycf18f8341004130728hf560f5cdpa8704b7031a0076d@mail.gmail.com>  <20100416111539.GC19264@csn.ul.ie>
 <o2kcf18f8341004160803v9663d602g8813b639024b5eca@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 16 Apr 2010, Bob Liu wrote:

> Hmm.
> What about this change? If the from_nodes and to_nodes' weight is different,
> then we can don't preserv of the relative position of the page to the beginning
> of the node set. This case if a page allocation from the dest node
> failed, it will
> be allocated from the next node instead of early return.

Understand what you are doing first. The fallback is already there.

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..094d092 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page,
> struct list_head *pagelist,
>
>  static struct page *new_node_page(struct page *page, unsigned long
> node, int **x)
>  {
> -       return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
> +       return alloc_pages_exact_node(node,
> +                       GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);

You eliminate falling back to the next node?

GFP_THISNODE forces allocation from the node. Without it we will fallback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
