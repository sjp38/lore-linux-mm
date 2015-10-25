Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 949CF6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 19:18:15 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so168545110pad.1
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:18:15 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id oz1si48596452pbc.112.2015.10.25.16.18.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 16:18:14 -0700 (PDT)
Received: by pabuq3 with SMTP id uq3so3532586pab.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 16:18:14 -0700 (PDT)
Date: Sun, 25 Oct 2015 16:18:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/6] ksm: unstable_tree_search_insert error checking
 cleanup
In-Reply-To: <1444925065-4841-7-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.11.1510251601230.1923@eggly.anvils>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com> <1444925065-4841-7-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Oct 2015, Andrea Arcangeli wrote:

> get_mergeable_page() can only return NULL (in case of errors) or the
> pinned mergeable page. It can't return an error different than
> NULL. This makes it more readable and less confusion in addition to
> optimizing the check.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I share your sentiment, prefer to avoid an unnecessary IS_ERR_OR_NULL.
And you may be right that it's unnecessary; but that's far from clear
to me, and you haven't changed the IS_ERR_OR_NULL after follow_page()
in get_mergeable_page() where it originates, so I wonder if you just
got confused on this.

Even if you have established that there's currently no way that
follow_page(vma, addr, FOLL_GET) could return an -errno on a vma
validated by find_mergeable_vma(), I think we'd still be better off
to allow for some future -errno there; but I'd be happy for you to
keep the change below, but also adjust get_mergeable_page() to
convert an -errno immediately to NULL after follow_page().

So, I think this is gently Nacked in its present form,
but a replacement eagerly Acked.

Hugh

> ---
>  mm/ksm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 10618a3..dcefc37 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1409,7 +1409,7 @@ struct rmap_item *unstable_tree_search_insert(struct rmap_item *rmap_item,
>  		cond_resched();
>  		tree_rmap_item = rb_entry(*new, struct rmap_item, node);
>  		tree_page = get_mergeable_page(tree_rmap_item);
> -		if (IS_ERR_OR_NULL(tree_page))
> +		if (!tree_page)
>  			return NULL;
>  
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
