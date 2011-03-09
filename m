Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C68108D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 04:18:57 -0500 (EST)
Date: Wed, 9 Mar 2011 10:18:40 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: THP, rmap and page_referenced_one()
Message-ID: <20110309091840.GC30778@cmpxchg.org>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
 <AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
 <AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com>
 <20110308113245.GR25641@random.random>
 <20110308122115.GA28054@google.com>
 <20110308125830.GS25641@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110308125830.GS25641@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Tue, Mar 08, 2011 at 01:58:30PM +0100, Andrea Arcangeli wrote:
> When vmscan.c calls page_referenced, if an anon page was created before a
> process forked, rmap will search for it in both of the processes, even though
> one of them might have since broken COW. If the child process mlocks the vma
> where the COWed page belongs to, page_referenced() running on the page mapped
> by the parent would lead to *vm_flags getting VM_LOCKED set erroneously (leading
> to the references on the parent page being ignored and evicting the parent page
> too early).
> 
> *mapcount would also be decremented by page_referenced_one even if the page
> wasn't found by page_check_address.
> 
> This also let pmdp_clear_flush_young_notify() go ahead on a
> pmd_trans_splitting() pmd. We hold the page_table_lock so
> __split_huge_page_map() must wait the pmdp_clear_flush_young_notify() to
> complete before it can modify the pmd. The pmd is also still mapped in userland
> so the young bit may materialize through a tlb miss before split_huge_page_map
> runs. This will provide a more accurate page_referenced() behavior during
> split_huge_page().
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Michel Lespinasse <walken@google.com>
> Reviewed-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
