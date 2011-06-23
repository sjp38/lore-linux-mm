Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 01522900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 23:15:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 990D03EE0C2
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:15:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76C2745DE9E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:15:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 605FC45DE9D
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:15:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 50BE11DB8058
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:15:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E3511DB804C
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 12:15:50 +0900 (JST)
Message-ID: <4E02AFCE.6000604@jp.fujitsu.com>
Date: Thu, 23 Jun 2011 12:15:26 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fadvise: move active pages to inactive list with
 POSIX_FADV_DONTNEED
References: <1308779480-4950-1-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308779480-4950-1-git-send-email-andrea@betterlinux.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: andrea@betterlinux.com
Cc: akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2011/06/23 6:51), Andrea Righi wrote:
> There were some reported problems in the past about trashing page cache
> when a backup software (i.e., rsync) touches a huge amount of pages (see
> for example [1]).
> 
> This problem has been almost fixed by the Minchan Kim's patch [2] and a
> proper use of fadvise() in the backup software. For example this patch
> set [3] has been proposed for inclusion in rsync.
> 
> However, there can be still other similar trashing problems: when the
> backup software reads all the source files, some of them may be part of
> the actual working set of the system. When a
> posix_fadvise(POSIX_FADV_DONTNEED) is performed _all_ pages are evicted
> from pagecache, both the working set and the use-once pages touched only
> by the backup software.
> 
> With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
> called for an active page instead of removing it from the page cache it
> is added to the tail of the inactive list. Otherwise, if it's already in
> the inactive list the page is removed from the page cache.
> 
> In this way if the backup was the only user of a page, that page will
> be immediately removed from the page cache by calling
> posix_fadvise(POSIX_FADV_DONTNEED). If the page was also touched by
> other processes it'll be moved to the inactive list, having another
> chance of being re-added to the working set, or simply reclaimed when
> memory is needed.
> 
> Testcase:
> 
>   - create a 1GB file called "zero"
>   - run md5sum zero to read all the pages in page cache (this is to
>     simulate the user activity on this file)
>   - run "rsync zero zero_copy" (rsync is patched with [3])
>   - re-run md5sum zero (user activity on the working set) and measure
>     the time to complete this command
> 
> The test has been performed using 3.0.0-rc4 vanilla and with this patch
> applied (3.0.0-rc4-fadvise).
> 
> Results:
>                   avg elapsed time      block:block_bio_queue
>  3.0.0-rc4                  4.127s                      8,214
>  3.0.0-rc4-fadvise          2.146s                          0
> 
> In the first case the file is evicted from page cache completely and we
> must re-read it from the disk. In the second case the file is still in
> page cache (in the inactive list) and we don't need any other additional
> I/O operation.
> 
> [1] http://marc.info/?l=rsync&m=128885034930933&w=2
> [2] https://lkml.org/lkml/2011/2/20/57
> [3] http://lists.samba.org/archive/rsync/2010-November/025827.html
> 
> Signed-off-by: Andrea Righi <andrea@betterlinux.com>
> ---
>  mm/swap.c     |    9 +++++----
>  mm/truncate.c |    5 ++++-
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a442f1..fc8bb76 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -411,10 +411,11 @@ void add_page_to_unevictable_list(struct page *page)
>   *
>   * 1. active, mapped page -> none
>   * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
> - * 3. inactive, mapped page -> none
> - * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> - * 5. inactive, clean -> inactive, tail
> - * 6. Others -> none
> + * 3. active, clean -> inactive, tail
> + * 4. inactive, mapped page -> none
> + * 5. inactive, dirty/writeback page -> inactive, head, PG_reclaim
> + * 6. inactive, clean -> inactive, tail
> + * 7. Others -> none
>   *
>   * In 4, why it moves inactive's head, the VM expects the page would
>   * be write it out by flusher threads as this is much more effective
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 3a29a61..043aabd 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -357,7 +357,10 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  			if (lock_failed)
>  				continue;
>  
> -			ret = invalidate_inode_page(page);
> +			if (PageActive(page))
> +				ret = 0;
> +			else
> +				ret = invalidate_inode_page(page);

So, after this patch, following comment is a bit outdated. we deactivate
the page even if it's not invalidated.

                        /*
                         * Invalidation is a hint that the page is no longer
                         * of interest and try to speed up its reclaim.
                         */

Can you please fix the comment too? Other than that,
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
