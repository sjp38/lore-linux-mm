Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 439676B004A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 18:22:43 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p68MMeuh007693
	for <linux-mm@kvack.org>; Fri, 8 Jul 2011 15:22:40 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by kpbe16.cbf.corp.google.com with ESMTP id p68MLp4K008577
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 8 Jul 2011 15:22:39 -0700
Received: by pvg11 with SMTP id 11so2316476pvg.27
        for <linux-mm@kvack.org>; Fri, 08 Jul 2011 15:22:27 -0700 (PDT)
Date: Fri, 8 Jul 2011 15:22:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/1] mmap: Don't count shmem pages as free in
 __vm_enough_memory
In-Reply-To: <1309721963-5577-1-git-send-email-dmitry.fink@palm.com>
Message-ID: <alpine.LSU.2.00.1107081433240.2840@sister.anvils>
References: <1309721963-5577-1-git-send-email-dmitry.fink@palm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Fink <finikk@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Fink <dmitry.fink@palm.com>, Minchan Kim <minchan.kim@gmail.com>

On Sun, 3 Jul 2011, Dmitry Fink wrote:

> shmem pages can't be reclaimed and if they are swapped out
> that doesn't affect the overall available memory in the system,
> so don't count them along with the rest of the file backed pages.
> 
> Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>

That's a good point.  You can add
Acked-by: Hugh Dickins <hughd@google.com>
if you'll let me burble on for a while...

1. Your block comment style differs from kernel coding style, and
   the nearby comments do follow kernel coding style: please adjust.

2. If you're wondering why this was missed for so long, it's simply
   that we didn't have that separate NR_SHMEM count until 2.6.32.

3. There's a danger that this change will fail some large mappings
   that were allowed before; but I guess we run that risk every
   time we release a larger kernel than before, so let's grant you
   the patch... but it might have to be reverted if anyone complains.

4. i915 GEM uses shmem pages that _can_ (sometimes) be freed under
   memory pressure; but then, on the other side, some of the pages
   counted as "free" may actually be locked or pinned in some way.

5. The OVERCOMMIT_GUESS estimation is at best something of a joke
   (a thousand concurrent tasks would each be allowed to make their
   own separate maximal mappings), and any change appears to dignify
   it somewhat; but you are right, so let's do it.

6. I was worried about additional overhead, and puzzled where the
   actual free pages get counted: ah, lower down, with a comment that
   nr_free_pages() is very expensive on large systems... and what does
   nr_free_pages() do?  It does global_page_state(NR_FREE_PAGES): so
   does that imply that your additional global_page_state(NR_SHMEM)
   will be expensive>?  No, the comment, and the peculiar placing of
   the nr_free_pages() call, date from when it was a loop over all
   zones (hence all nodes) in the system.  Now, tell me to go away
   and make a separate patch of my own if you wish, fair enough;
   but I suggest you tidy that up too (and clearer if it explicitly
   says global_page_state(NR_FREE_PAGES) rather than nr_free_pages()):

   free = global_page_state(NR_FREE_PAGES);
   free += global_page_state(NR_FILE_PAGES);
   etc.

7. There's an almost identical copy of this code in mm/nommu.c:
   please update that one too to keep them in synch.  I suppose it
   would be better to keep one copy of it somewhere else, but by
   now I've probably exhausted your patience, plus I've a nasty
   feeling that if I suggest somewhere, I'll be tricking you
   into a build error with this or that config.  Another time...

You can see why I don't like reviewing more than one-line changes,
can't you :-?

Thanks,
Hugh

> ---
>  mm/mmap.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index b88624f..3a34dc2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -119,6 +119,13 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>  		unsigned long n;
>  
>  		free = global_page_state(NR_FILE_PAGES);
> +
> +		/* shmem pages shouldn't be counted as free in this
> +		 * case, they can't be purged, only swapped out, and
> +		 * that won't affect the overall amount of available
> +		 * memory in the system. */
> +		free -= global_page_state(NR_SHMEM);
> +
>  		free += nr_swap_pages;
>  
>  		/*
> -- 
> 1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
