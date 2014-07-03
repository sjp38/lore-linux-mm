Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id DA7316B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 11:37:34 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id u57so445735wes.19
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 08:37:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si35917337wjz.0.2014.07.03.08.37.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 08:37:33 -0700 (PDT)
Message-ID: <53B578BC.4050300@suse.cz>
Date: Thu, 03 Jul 2014 17:37:32 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] shmem: fix faulting into a hole while it's punched,
 take 2
References: <alpine.LSU.2.11.1407021204180.12131@eggly.anvils> <alpine.LSU.2.11.1407021209570.12131@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407021209570.12131@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/02/2014 09:11 PM, Hugh Dickins wrote:
> Trinity finds that mmap access to a hole while it's punched from shmem
> can prevent the madvise(MADV_REMOVE) or fallocate(FALLOC_FL_PUNCH_HOLE)
> from completing, until the (killable) reader stops; with the puncher's
> hold on i_mutex locking out all other writers until it can complete.
> This issue was tagged with CVE-2014-4171.
>
> It appears that the tmpfs fault path is too light in comparison with its
> hole-punching path, lacking an i_data_sem to obstruct it; but we don't
> want to slow down the common case.  It is not a problem in truncation,
> because there the SIGBUS beyond i_size stops pages from being appended.
>
> The origin of this problem is my v3.1 commit d0823576bf4b ("mm: pincer
> in truncate_inode_pages_range"), once it was duplicated into shmem.c.
> It seemed like a nice idea at the time, to ensure (barring RCU lookup
> fuzziness) that there's an instant when the entire hole is empty; but
> the indefinitely repeated scans to ensure that make it vulnerable.
>
> Revert that "enhancement" to hole-punch from shmem_undo_range(), but
> retain the unproblematic rescanning when it's truncating; add a couple
> of comments there.
>
> Remove the "indices[0] >= end" test: that is now handled satisfactorily
> by the inner loop, and mem_cgroup_uncharge_start()/end() are too light
> to be worth avoiding here.
>
> But if we do not always loop indefinitely, we do need to handle the
> case of swap swizzled back to page before shmem_free_swap() gets it:
> add a retry for that case, as suggested by Konstantin Khlebnikov.
>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Suggested-and-Tested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Lukas Czerner <lczerner@redhat.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: stable@vger.kernel.org # v3.1+
> ---
>
>   mm/shmem.c |   19 ++++++++++---------
>   1 file changed, 10 insertions(+), 9 deletions(-)
>
> --- 3.16-rc3+/mm/shmem.c	2014-07-02 03:31:12.956546569 -0700
> +++ linux/mm/shmem.c	2014-07-02 03:34:13.172550852 -0700
> @@ -467,23 +467,20 @@ static void shmem_undo_range(struct inod
>   		return;
>
>   	index = start;
> -	for ( ; ; ) {
> +	while (index < end) {
>   		cond_resched();
>
>   		pvec.nr = find_get_entries(mapping, index,
>   				min(end - index, (pgoff_t)PAGEVEC_SIZE),
>   				pvec.pages, indices);
>   		if (!pvec.nr) {
> -			if (index == start || unfalloc)
> +			/* If all gone or hole-punch or unfalloc, we're done */
> +			if (index == start || end != -1)
>   				break;
> +			/* But if truncating, restart to make sure all gone */
>   			index = start;
>   			continue;
>   		}
> -		if ((index == start || unfalloc) && indices[0] >= end) {
> -			pagevec_remove_exceptionals(&pvec);
> -			pagevec_release(&pvec);
> -			break;
> -		}
>   		mem_cgroup_uncharge_start();
>   		for (i = 0; i < pagevec_count(&pvec); i++) {
>   			struct page *page = pvec.pages[i];
> @@ -495,8 +492,12 @@ static void shmem_undo_range(struct inod
>   			if (radix_tree_exceptional_entry(page)) {
>   				if (unfalloc)
>   					continue;
> -				nr_swaps_freed += !shmem_free_swap(mapping,
> -								index, page);
> +				if (shmem_free_swap(mapping, index, page)) {
> +					/* Swap was replaced by page: retry */
> +					index--;
> +					break;
> +				}
> +				nr_swaps_freed++;
>   				continue;

Ugh, a warning to anyone trying to backport this. This hunk can match 
both instances of the same code in the function, and I've just seen 
patch picking the wrong one.

>   			}
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
