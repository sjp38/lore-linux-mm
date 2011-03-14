Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 948078D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:52:37 -0400 (EDT)
Date: Mon, 14 Mar 2011 16:52:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
Message-ID: <20110314155232.GB10696@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 14, 2011 at 01:08:47AM -0700, Hugh Dickins wrote:
>  mm/huge_memory.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> --- 2.6.38-rc8/mm/huge_memory.c	2011-03-08 09:27:16.000000000 -0800
> +++ linux/mm/huge_memory.c	2011-03-13 18:26:21.000000000 -0700
> @@ -1762,6 +1762,10 @@ static void collapse_huge_page(struct mm
>  #ifndef CONFIG_NUMA
>  	VM_BUG_ON(!*hpage);
>  	new_page = *hpage;
> +	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> +		up_read(&mm->mmap_sem);
> +		return;
> +	}
>  #else
>  	VM_BUG_ON(*hpage);
>  	/*
> @@ -1781,12 +1785,12 @@ static void collapse_huge_page(struct mm
>  		*hpage = ERR_PTR(-ENOMEM);
>  		return;
>  	}
> -#endif
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>  		up_read(&mm->mmap_sem);
>  		put_page(new_page);
>  		return;
>  	}
> +#endif
>  
>  	/* after allocating the hugepage upgrade to mmap_sem write mode */
>  	up_read(&mm->mmap_sem);

Correct! I'd suggest to fix it without duplicating the
mem_cgroup_newpage_charge. It's just one more put_page than needed
with memcg enabled and NUMA disabled (I guess most memcg testing
happened with NUMA enabled). The larger diff likely rejects with -mm
NUMA code... I'll try to diff it with a smaller -U2 (this code has
little change to be misplaced) that may allow it to apply clean
regardless of the merging order, so it may make life easier.

It may have been overkill to keep the NUMA case separated in order to
avoid spurious allocations for the not-NUMA case, code become more
complex and I'm not sure if it's really worthwhile. The optimization
makes sense but it's minor and it created more complexity than
strictly needed. For now we can't change it in the short term as it
has been tested this way, but if people dislike the additional
complexity that this optimization created, I'm not against dropping it
in the future. Your comment was positive about the optimization (you
said understandable) so I wanted to share my current thinking on these
ifdefs...

Thanks,
Andrea

===
Subject: thp+memcg-numa: fix BUG at include/linux/mm.h:370!

From: Hugh Dickins <hughd@google.com>

THP's collapse_huge_page() has an understandable but ugly difference
in when its huge page is allocated: inside if NUMA but outside if not.
It's hardly surprising that the memcg failure path forgot that, freeing
the page in the non-NUMA case, then hitting a VM_BUG_ON in get_page()
(or even worse, using the freed page).

Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index dbe99a5..bf41114 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1785,5 +1785,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		up_read(&mm->mmap_sem);
+#ifdef CONFIG_NUMA
 		put_page(new_page);
+#endif
 		return;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
