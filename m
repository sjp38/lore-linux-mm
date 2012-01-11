Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E5CB86B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:42:44 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 25FC63EE0C7
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:42:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05E8545DEDC
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:42:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5A8A45DEEA
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:42:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCE851DB8045
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:42:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 680C01DB8038
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:42:38 +0900 (JST)
Date: Wed, 11 Jan 2012 14:41:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
Message-Id: <20120111144125.0c61f35f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120106173856.11700.98858.stgit@zurg>
References: <20120106173827.11700.74305.stgit@zurg>
	<20120106173856.11700.98858.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 06 Jan 2012 21:38:56 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Memory migration fill pte with migration entry and it didn't update rss counters.
> Then it replace migration entry with new page (or old one if migration was failed).
> But between this two passes this pte can be unmaped, or task can fork child and
> it will get copy of this migration entry. Nobody account this into rss counters.
> 
> This patch properly adjust rss counters for migration entries in zap_pte_range()
> and copy_one_pte(). Thus we avoid extra atomic operations on migration fast-path.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

It's better to show wheter this is a bug-fix or not in changelog.

IIUC, the bug-fix is the 1st harf of this patch + patch [2/3].
Your new bug-check code is in patch[1/3] and 2nd half of this patch.

I think it's better to do bug-fix 1st and add bug-check later.

So, could you reorder patches to bug-fix and new-bug-check ?

To the logic itself,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Please CC when you repost.



> ---
>  mm/memory.c |   37 ++++++++++++++++++++++++++++---------
>  1 files changed, 28 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 829d437..2f96ffc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -878,15 +878,24 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  			}
>  			if (likely(!non_swap_entry(entry)))
>  				rss[MM_SWAPENTS]++;
> -			else if (is_write_migration_entry(entry) &&
> -					is_cow_mapping(vm_flags)) {
> -				/*
> -				 * COW mappings require pages in both parent
> -				 * and child to be set to read.
> -				 */
> -				make_migration_entry_read(&entry);
> -				pte = swp_entry_to_pte(entry);
> -				set_pte_at(src_mm, addr, src_pte, pte);
> +			else if (is_migration_entry(entry)) {
> +				page = migration_entry_to_page(entry);
> +
> +				if (PageAnon(page))
> +					rss[MM_ANONPAGES]++;
> +				else
> +					rss[MM_FILEPAGES]++;
> +
> +				if (is_write_migration_entry(entry) &&
> +				    is_cow_mapping(vm_flags)) {
> +					/*
> +					 * COW mappings require pages in both
> +					 * parent and child to be set to read.
> +					 */
> +					make_migration_entry_read(&entry);
> +					pte = swp_entry_to_pte(entry);
> +					set_pte_at(src_mm, addr, src_pte, pte);
> +				}
>  			}
>  		}
>  		goto out_set_pte;
> @@ -1191,6 +1200,16 @@ again:
>  
>  			if (!non_swap_entry(entry))
>  				rss[MM_SWAPENTS]--;
> +			else if (is_migration_entry(entry)) {
> +				struct page *page;
> +
> +				page = migration_entry_to_page(entry);
> +
> +				if (PageAnon(page))
> +					rss[MM_ANONPAGES]--;
> +				else
> +					rss[MM_FILEPAGES]--;
> +			}
>  			if (unlikely(!free_swap_and_cache(entry)))
>  				print_bad_pte(vma, addr, ptent, NULL);
>  		}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
