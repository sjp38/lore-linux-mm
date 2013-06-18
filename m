Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 899636B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 00:11:02 -0400 (EDT)
Date: Tue, 18 Jun 2013 13:11:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/8] Volatile Ranges (v8?)
Message-ID: <20130618041100.GA3116@bbox>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
 <51BF3827.4060606@mozilla.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51BF3827.4060606@mozilla.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dhaval Giani <dgiani@mozilla.com>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello Dhaval,

On Mon, Jun 17, 2013 at 12:24:07PM -0400, Dhaval Giani wrote:
> Hi John,
> 
> I have been giving your git tree a whirl, and in order to simulate a
> limited memory environment, I was using memory cgroups.
> 
> The program I was using to test is attached here. It is your test
> code, with some changes (changing the syscall interface, reducing
> the memory pressure to be generated).
> 
> I trapped it in a memory cgroup with 1MB memory.limit_in_bytes and hit this,
> 
> [  406.207612] ------------[ cut here ]------------
> [  406.207621] kernel BUG at mm/vrange.c:523!
> [  406.207626] invalid opcode: 0000 [#1] SMP
> [  406.207631] Modules linked in:
> [  406.207637] CPU: 0 PID: 1579 Comm: volatile-test Not tainted

Thanks for the testing!
Does below patch fix your problem?

diff --git a/mm/swapfile.c b/mm/swapfile.c
index d41c63f..1f6c80e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -751,7 +751,7 @@ int __free_swap_and_cache(swp_entry_t entry)
 			page = find_get_page(swap_address_space(entry),
 						entry.val);
 		}
-		spin_unlock(&swap_lock);
+		spin_unlock(&p->lock);
 	}
 
 	if (page) {
diff --git a/mm/vrange.c b/mm/vrange.c
index fa965fb..dc32cfa 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -485,7 +485,7 @@ int try_to_discard_one(struct vrange_root *vroot, struct page *page,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
-	pte_t pteval;
+	pte_t pteval, pteswap;
 	spinlock_t *ptl;
 	int ret = 0;
 	bool present;
@@ -505,7 +505,7 @@ int try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	present = pte_present(*pte);
 	flush_cache_page(vma, address, page_to_pfn(page));
 
-	ptep_clear_flush(vma, address, pte);
+	pteswap = ptep_clear_flush(vma, address, pte);
 	pteval = pte_mkvrange(*pte);
 
 	update_hiwater_rss(mm);
@@ -517,10 +517,11 @@ int try_to_discard_one(struct vrange_root *vroot, struct page *page,
 	page_remove_rmap(page);
 	page_cache_release(page);
 	if (!present) {
-		swp_entry_t entry = pte_to_swp_entry(*pte);
+		swp_entry_t entry = pte_to_swp_entry(pteswap);
 		dec_mm_counter(mm, MM_SWAPENTS);
-		if (unlikely(!__free_swap_and_cache(entry)))
+		if (unlikely(!__free_swap_and_cache(entry))) {
 			BUG_ON(1);
+		}
 	}
 
 	set_pte_at(mm, address, pte, pteval);
-- 
1.7.9.5

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
