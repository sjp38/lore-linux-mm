Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 95D196B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 09:30:44 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so35818950lfw.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 06:30:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fj4si18950818wjb.194.2016.07.29.06.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 06:30:43 -0700 (PDT)
Date: Fri, 29 Jul 2016 09:30:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: move swap-in anonymous page into active list
Message-ID: <20160729133033.GA2034@cmpxchg.org>
References: <1469762740-17860-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469762740-17860-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Jul 29, 2016 at 12:25:40PM +0900, Minchan Kim wrote:
> Every swap-in anonymous page starts from inactive lru list's head.
> It should be activated unconditionally when VM decide to reclaim
> because page table entry for the page always usually has marked
> accessed bit. Thus, their window size for getting a new referece
> is 2 * NR_inactive + NR_active while others is NR_active + NR_active.
> 
> It's not fair that it has more chance to be referenced compared
> to other newly allocated page which starts from active lru list's
> head.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

That behavior stood out to me as well recently, but I couldn't
convince myself that activation is the right thing.

The page can still have a valid copy on the swap device, so prefering
to reclaim that page over a fresh one could make sense. But as you
point out, having it start inactive instead of active actually ends up
giving it *more* LRU time, and that seems to be without justification.

So this change makes sense to me. Maybe somebody else remembers a good
reason for why the behavior is the way it is, but likely it has always
been an oversight.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> ---
>  mm/memory.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 4425b6059339..3a730b920242 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2642,6 +2642,7 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
>  	if (page == swapcache) {
>  		do_page_add_anon_rmap(page, vma, fe->address, exclusive);
>  		mem_cgroup_commit_charge(page, memcg, true, false);
> +		activate_page(page);
>  	} else { /* ksm created a completely new copy */
>  		page_add_new_anon_rmap(page, vma, fe->address, false);
>  		mem_cgroup_commit_charge(page, memcg, false, false);
> -- 
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
