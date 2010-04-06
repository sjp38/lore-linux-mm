Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 978E96B01EF
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 00:33:36 -0400 (EDT)
Received: by pvg11 with SMTP id 11so1519745pvg.14
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 21:33:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
References: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
Date: Tue, 6 Apr 2010 13:33:34 +0900
Message-ID: <k2m28c262361004052133jfc62525bw3cd570765d160876@mail.gmail.com>
Subject: Re: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 6, 2010 at 11:59 AM, Bob Liu <lliubbo@gmail.com> wrote:
> In funtion migrate_pages(), if the dest node have no
> enough free pages,it will fallback to other nodes.
> Add GFP_THISNODE to avoid this, the same as what
> funtion new_page_node() do in migrate.c.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Yes. It can be fixed. but I have a different concern.

I looked at 6484eb3e2a81807722c5f28ef.
"   page allocator: do not check NUMA node ID when the caller knows
the node is valid

   Callers of alloc_pages_node() can optionally specify -1 as a node to mean
   "allocate from the current node".  However, a number of the callers in
   fast paths know for a fact their node is valid.  To avoid a comparison and
   branch, this patch adds alloc_pages_exact_node() that only checks the nid
   with VM_BUG_ON().  Callers that know their node is valid are then
   converted."

alloc_pages_exact_node's naming would be not good.
It is not for allocate page from exact node but just for
removing check of node's valid.
Some people like me who is poor english could misunderstood it.

How about changing name with following?
/* This function can allocate page to fallback list of node*/
alloc_pages_by_nodeid(...)

And instead of it, let's change alloc_pages_exact_node with following.
static inline struct page *alloc_pages_exact_node(...)
{
 VM_BUG_ON ..
 return __alloc_pages(gfp_mask|__GFP_THISNODE...);
}

I think it's more clear than old.
What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
