Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CBA16B01AC
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 11:31:55 -0400 (EDT)
Subject: Re: [RFC][PATCH] migrate_pages:skip migration between intersect
 nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
References: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain
Date: Mon, 29 Mar 2010 11:31:48 -0400
Message-Id: <1269876708.13829.30.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, andi@firstfloor.org, minchar.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Mon, 2010-03-29 at 22:57 +0800, Bob Liu wrote:
> In current do_migrate_pages(),if from_nodes and to_nodes have some
> intersect nodes,pages in these intersect nodes will also be
> migrated.
> eg. Assume that, from_nodes: 1,2,3,4 to_nodes: 2,3,4,5. Then these
> migrates will happen:
> migrate_pages(4,5);
> migrate_pages(3,4);
> migrate_pages(2,3);
> migrate_pages(1,2);
> 
> But the user just want all pages in from_nodes move to to_nodes,
> only migrate(1,2)(ignore the intersect nodes.) can satisfied 
> the user's request.
> 
> I amn't sure what's migrate_page's semantic.
> Hoping for your suggestions.

I believe that the current code matches the intended semantics.  I can't
find a man pages for the migrate_pages() system call, but the
migratepages(8) man page says:

"If  multiple  nodes  are specified for from-nodes or to-nodes then an
attempt is made to preserve the relative location of each page in each
nodeset."

If one just wanted to move all task pages from node 1 to 2, one would
specify:

to_nodes: 1
from_nodes: 2

Christoph L may have more to say.  I believe he wrote migrate_pages()
and that very interesting remapping function.

Lee


> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/mempolicy.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 08f40a2..c6dd931 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -922,7 +922,7 @@ int do_migrate_pages(struct mm_struct *mm,
>  	 * moved to an empty node, then there is nothing left worth migrating.
>  	 */
>  
> -	tmp = *from_nodes;
> +	nodes_andnot(tmp, *from_nodes, *to_nodes);
>  	while (!nodes_empty(tmp)) {
>  		int s,d;
>  		int source = -1;
> @@ -935,10 +935,7 @@ int do_migrate_pages(struct mm_struct *mm,
>  
>  			source = s;	/* Node moved. Memorize */
>  			dest = d;
> -
> -			/* dest not in remaining from nodes? */
> -			if (!node_isset(dest, tmp))
> -				break;
> +			break;
>  		}
>  		if (source == -1)
>  			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
