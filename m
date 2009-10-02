Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 613BD6B0055
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 22:37:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n922ediE030166
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Oct 2009 11:40:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9DD5745DE50
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 11:40:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DAD845DE4F
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 11:40:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 58FEC1DB8037
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 11:40:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 805DEE08001
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 11:40:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
In-Reply-To: <1254344964-8124-3-git-send-email-hannes@cmpxchg.org>
References: <1254344964-8124-1-git-send-email-hannes@cmpxchg.org> <1254344964-8124-3-git-send-email-hannes@cmpxchg.org>
Message-Id: <20091002100838.5F5A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  2 Oct 2009 11:40:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi

thanks for very interesting patches.
I have a question.


> @@ -835,6 +835,43 @@ static unsigned long zap_pte_range(struc
>  				    (page->index < details->first_index ||
>  				     page->index > details->last_index))
>  					continue;
> +				/*
> +				 * When truncating, private COW pages may be
> +				 * mlocked in VM_LOCKED VMAs, so they need
> +				 * munlocking here before getting freed.
> +				 *
> +				 * Skip them completely if we don't have the
> +				 * anon_vma locked.  We will get it the second
> +				 * time.  When page cache is truncated, no more
> +				 * private pages can show up against this VMA
> +				 * and the anon_vma is either present or will
> +				 * never be.
> +				 *
> +				 * Otherwise, we still have to synchronize
> +				 * against concurrent reclaimers.  We can not
> +				 * grab the page lock, but with correct
> +				 * ordering of page flag accesses we can get
> +				 * away without it.
> +				 *
> +				 * A concurrent isolator may add the page to
> +				 * the unevictable list, set PG_lru and then
> +				 * recheck PG_mlocked to verify it chose the
> +				 * right list and conditionally move it again.
> +				 *
> +				 * TestClearPageMlocked() provides one half of
> +				 * the barrier: when we do not see the page on
> +				 * the LRU and fail isolation, the isolator
> +				 * must see PG_mlocked cleared and move the
> +				 * page on its own back to the evictable list.
> +				 */
> +				if (private && !details->anon_vma)
> +					continue;
> +				if (private && TestClearPageMlocked(page)) {
> +					dec_zone_page_state(page, NR_MLOCK);
> +					count_vm_event(UNEVICTABLE_PGCLEARED);
> +					if (!isolate_lru_page(page))
> +						putback_lru_page(page);
> +				}
>  			}
>  			ptent = ptep_get_and_clear_full(mm, addr, pte,
>  							tlb->fullmm);

Umm..
I haven't understand this.

(1) unmap_mapping_range() is called twice.

	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
	truncate_inode_pages(mapping, new);
	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);

(2) PG_mlock is turned on from mlock() and vmscan.
(3) vmscan grab anon_vma, but mlock don't grab anon_vma.
(4) after truncate_inode_pages(), we don't need to think vs-COW, because
    find_get_page() never success. but first unmap_mapping_range()
    have vs-COW racing. 

So, Is anon_vma grabbing really sufficient?
Or, you intent to the following?

	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 0);
	truncate_inode_pages(mapping, new);
	unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);



> @@ -544,6 +544,13 @@ redo:
>  		 */
>  		lru = LRU_UNEVICTABLE;
>  		add_page_to_unevictable_list(page);
> +		/*
> +		 * See the TestClearPageMlocked() in zap_pte_range():
> +		 * if a racing unmapper did not see the above setting
> +		 * of PG_lru, we must see its clearing of PG_locked
> +		 * and move the page back to the evictable list.
> +		 */
> +		smp_mb();
>  	}

add_page_to_unevictable() have a spin lock. Why do we need additionl
explicit memory barrier?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
