Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 773028D003C
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 17:33:23 -0500 (EST)
Date: Wed, 2 Mar 2011 14:31:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte
 mapping to ksm pages
Message-Id: <20110302143142.a3c0002b.akpm@linux-foundation.org>
In-Reply-To: <201102262256.31565.nai.xia@gmail.com>
References: <201102262256.31565.nai.xia@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Sat, 26 Feb 2011 22:56:31 +0800
Nai Xia <nai.xia@gmail.com> wrote:

> ksm_pages_sharing is updated by ksmd periodically.  In some cases, it cannot 
> reflect the actual savings and makes the benchmarks on volatile VMAs very 
> inaccurate.
> 
> This patch add a vm_stat entry and let the /proc/meminfo show information 
> about how much virutal address pte is being mapped to ksm pages.  With default 
> ksm paramters (pages_to_scan==100 && sleep_millisecs==20), this can result in 
> 50% more accurate averaged savings result for the following test program. 
> Bigger sleep_millisecs values will increase this deviation. 
> 
> ...
>
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -87,6 +87,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		"SUnreclaim:     %8lu kB\n"
>  		"KernelStack:    %8lu kB\n"
>  		"PageTables:     %8lu kB\n"
> +#ifdef CONFIG_KSM
> +		"KsmSharing:     %8lu kB\n"
> +#endif
>  #ifdef CONFIG_QUICKLIST
>  		"Quicklists:     %8lu kB\n"
>  #endif
>
> ...
>
> @@ -904,6 +905,10 @@ static int try_to_merge_one_page(struct vm_area_struct 
> *vma,
>  			 */
>  			set_page_stable_node(page, NULL);
>  			mark_page_accessed(page);
> +			if (mapcount)
> +				add_zone_page_state(page_zone(page),
> +						    NR_KSM_PAGES_SHARING,
> +						    mapcount);
>  			err = 0;
>  		} else if (pages_identical(page, kpage))
>  			err = replace_page(vma, page, kpage, orig_pte);

This patch obviously wasn't tested with CONFIG_KSM=n, which was a
pretty basic patch-testing failure :(

I fixed up my tree with the below, but really the amount of ifdeffing
is unacceptable - please find a cleaner way to fix up this patch.

--- a/mm/ksm.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
+++ a/mm/ksm.c
@@ -883,7 +883,6 @@ static int try_to_merge_one_page(struct 
 	 */
 	if (write_protect_page(vma, page, &orig_pte) == 0) {
 		if (!kpage) {
-			long mapcount = page_mapcount(page);
 			/*
 			 * While we hold page lock, upgrade page from
 			 * PageAnon+anon_vma to PageKsm+NULL stable_node:
@@ -891,10 +890,12 @@ static int try_to_merge_one_page(struct 
 			 */
 			set_page_stable_node(page, NULL);
 			mark_page_accessed(page);
-			if (mapcount)
+#ifdef CONFIG_KSM
+			if (page_mapcount(page))
 				add_zone_page_state(page_zone(page),
 						    NR_KSM_PAGES_SHARING,
 						    mapcount);
+#endif
 			err = 0;
 		} else if (pages_identical(page, kpage))
 			err = replace_page(vma, page, kpage, orig_pte);
--- a/mm/memory.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
+++ a/mm/memory.c
@@ -719,8 +719,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
 			rss[MM_ANONPAGES]++;
 		else
 			rss[MM_FILEPAGES]++;
+#ifdef CONFIG_KSM
 		if (PageKsm(page)) /* follows page_dup_rmap() */
 			inc_zone_page_state(page, NR_KSM_PAGES_SHARING);
+#endif
 	}
 
 out_set_pte:
--- a/mm/rmap.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
+++ a/mm/rmap.c
@@ -893,11 +893,12 @@ void do_page_add_anon_rmap(struct page *
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 	}
+#ifdef CONFIG_KSM
 	if (unlikely(PageKsm(page))) {
 		__inc_zone_page_state(page, NR_KSM_PAGES_SHARING);
 		return;
 	}
-
+#endif
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	if (first)
@@ -955,9 +956,10 @@ void page_add_file_rmap(struct page *pag
  */
 void page_remove_rmap(struct page *page)
 {
+#ifdef CONFIG_KSM
 	if (PageKsm(page))
 		__dec_zone_page_state(page, NR_KSM_PAGES_SHARING);
-
+#endif
 	/* page still mapped by someone else? */
 	if (!atomic_add_negative(-1, &page->_mapcount))
 		return;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
