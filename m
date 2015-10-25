Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4D46B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 19:34:32 -0400 (EDT)
Received: by pabuq3 with SMTP id uq3so3794301pab.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:34:31 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qx6si4525342pab.180.2015.10.25.16.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 16:34:31 -0700 (PDT)
Received: by pasz6 with SMTP id z6so168591284pas.2
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:34:31 -0700 (PDT)
Date: Sun, 25 Oct 2015 16:34:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/6] ksm: don't fail stable tree lookups if walking over
 stale stable_nodes
In-Reply-To: <1444925065-4841-4-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251622340.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> The stable_nodes can become stale at any time if the underlying pages
> gets freed. The stable_node gets collected and removed from the stable
> rbtree if that is detected during the rbtree tree lookups.
> 
> Don't fail the lookup if running into stale stable_nodes, just restart
> the lookup after collecting the stale entries. Otherwise the CPU spent
> in the preparation stage is wasted and the lookup must be repeated at
> the next loop potentially failing a second time in a second stale
> entry.
> 
> This also will contribute to pruning the stable tree and releasing the
> stable_node memory more efficiently.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I'll say
Acked-by: Hugh Dickins <hughd@google.com>
as a gesture of goodwill, but in honesty I'm sitting on the fence,
and couldn't decide.  I think I've gone back and forth on this in
my own mind in the past, worried that we might get stuck a long
time going back round to "again".  In the past I've felt that to
give up with NULL is consistent with KSM's willingness to give way
to any obstruction; but if you're finding "goto again" a better
strategy, sure, go ahead.  And at least there's a cond_resched()
just above the diff context shown.

A dittoed nit below...

> ---
>  mm/ksm.c | 30 +++++++++++++++++++++++++++---
>  1 file changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 39ef485..929b5c2 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1225,7 +1225,18 @@ again:
>  		stable_node = rb_entry(*new, struct stable_node, node);
>  		tree_page = get_ksm_page(stable_node, false);
>  		if (!tree_page)
> -			return NULL;
> +			/*
> +			 * If we walked over a stale stable_node,
> +			 * get_ksm_page() will call rb_erase() and it
> +			 * may rebalance the tree from under us. So
> +			 * restart the search from scratch. Returning
> +			 * NULL would be safe too, but we'd generate
> +			 * false negative insertions just because some
> +			 * stable_node was stale which would waste CPU
> +			 * by doing the preparation work twice at the
> +			 * next KSM pass.
> +			 */
> +			goto again;

When a comment gets that long, in fact even if it were only one line,
I'd much prefer that block inside braces.  I think I noticed Linus
feeling the same way a few days ago, when he fixed up someone's patch.

>  
>  		ret = memcmp_pages(page, tree_page);
>  		put_page(tree_page);
> @@ -1301,12 +1312,14 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  	unsigned long kpfn;
>  	struct rb_root *root;
>  	struct rb_node **new;
> -	struct rb_node *parent = NULL;
> +	struct rb_node *parent;
>  	struct stable_node *stable_node;
>  
>  	kpfn = page_to_pfn(kpage);
>  	nid = get_kpfn_nid(kpfn);
>  	root = root_stable_tree + nid;
> +again:
> +	parent = NULL;
>  	new = &root->rb_node;
>  
>  	while (*new) {
> @@ -1317,7 +1330,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
>  		stable_node = rb_entry(*new, struct stable_node, node);
>  		tree_page = get_ksm_page(stable_node, false);
>  		if (!tree_page)
> -			return NULL;
> +			/*
> +			 * If we walked over a stale stable_node,
> +			 * get_ksm_page() will call rb_erase() and it
> +			 * may rebalance the tree from under us. So
> +			 * restart the search from scratch. Returning
> +			 * NULL would be safe too, but we'd generate
> +			 * false negative insertions just because some
> +			 * stable_node was stale which would waste CPU
> +			 * by doing the preparation work twice at the
> +			 * next KSM pass.
> +			 */
> +			goto again;

Ditto.

>  
>  		ret = memcmp_pages(kpage, tree_page);
>  		put_page(tree_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
