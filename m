Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 405576B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 16:15:09 -0400 (EDT)
Date: Thu, 2 Jun 2011 22:15:01 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110602201501.GC4114@thinkpad>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602143143.GI23047@sequoia.sous-sol.org>
 <20110602143622.GE19505@random.random>
 <20110602153641.GJ23047@sequoia.sous-sol.org>
 <20110602164458.GG19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602164458.GG19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Wright <chrisw@sous-sol.org>, CAI Qian <caiqian@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Izik Eidus <ieidus@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jun 02, 2011 at 06:44:58PM +0200, Andrea Arcangeli wrote:
> On Thu, Jun 02, 2011 at 08:36:41AM -0700, Chris Wright wrote:
> > * Andrea Arcangeli (aarcange@redhat.com) wrote:
> > > On Thu, Jun 02, 2011 at 07:31:43AM -0700, Chris Wright wrote:
> > > > * CAI Qian (caiqian@redhat.com) wrote:
> > > > > madvise(0x2210000, 4096, 0xc /* MADV_??? */) = 0
> > > > > --- SIGSEGV (Segmentation fault) @ 0 (0) ---
> > > > 
> > > > Right, that's just what the program is trying to do, segfault.
> > > > 
> > > > > +++ killed by SIGSEGV (core dumped) +++
> > > > > Segmentation fault (core dumped)
> > > > > 
> > > > > Did I miss anything?
> > > > 
> > > > I found it works but not 100% of the time.
> > > > 
> > > > So I just run the bug in a loop.
> > > 
> > > echo 0 >scan_millisecs helps.
> > 
> > BTW, here's my stack trace (I dropped back to 2.6.39 just to see if it
> > happened to be recent regression).  It looks like mm_slot is off the list:
> > 
> > R10: dead000000200200 R11: dead000000100100
> 
> Yes it had to be use after free.
> 
> I cooked this patch, still untested but it builds. Will test it soon.

Hi Andrea,

I just tested this patch, but it doesn't seem to fix the problem, at
least not the one I reported. The same bug happens again.

Thanks,
-Andrea

> 
> ===
> Subject: ksm: fix __ksm_exit vs ksm scan SMP race
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> If the KSM scan releases the ksm_mmlist_lock after the mm_users already dropped
> to zero but before __ksm_exit had a chance runs, both the KSM scan and
> __ksm_exit will free the slot. This fixes the SMP race condition by using
> test_and_bit_set in __ksm_exit to see if __ksm_exit arrived before the KSM
> scan or not.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index d708b3e..47ef4c1 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -645,10 +645,16 @@ static int unmerge_and_remove_all_rmap_items(void)
>  		if (ksm_test_exit(mm)) {
>  			hlist_del(&mm_slot->link);
>  			list_del(&mm_slot->mm_list);
> +			/*
> +			 * After releasing ksm_mmlist_lock __ksm_exit
> +			 * can run and we already changed mm_slot, so
> +			 * notify it with MMF_VM_MERGEABLE not to free
> +			 * this again.
> +			 */
> +			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  			spin_unlock(&ksm_mmlist_lock);
>  
>  			free_mm_slot(mm_slot);
> -			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  			up_read(&mm->mmap_sem);
>  			mmdrop(mm);
>  		} else {
> @@ -1377,10 +1383,15 @@ next_mm:
>  		 */
>  		hlist_del(&slot->link);
>  		list_del(&slot->mm_list);
> +		/*
> +		 * After releasing ksm_mmlist_lock __ksm_exit can run
> +		 * and we already changed mm_slot, so notify it with
> +		 * MMF_VM_MERGEABLE not to free this again.
> +		 */
> +		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  		spin_unlock(&ksm_mmlist_lock);
>  
>  		free_mm_slot(slot);
> -		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  		up_read(&mm->mmap_sem);
>  		mmdrop(mm);
>  	} else {
> @@ -1463,6 +1474,11 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
>  				 VM_NONLINEAR | VM_MIXEDMAP | VM_SAO))
>  			return 0;		/* just ignore the advice */
>  
> +		/*
> +		 * It should be safe to test_bit instead of
> +		 * test_and_bit_set because the madvise generic caller
> +		 * holds the mmap_sem write mode.
> +		 */
>  		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
>  			err = __ksm_enter(mm);
>  			if (err)
> @@ -1511,6 +1527,10 @@ int __ksm_enter(struct mm_struct *mm)
>  	list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
>  	spin_unlock(&ksm_mmlist_lock);
>  
> +	/*
> +	 * It should be safe to set it outside ksm_mmlist_lock because
> +	 * we hold a mm_user pin on the mm so __ksm_exit can't run.
> +	 */
>  	set_bit(MMF_VM_MERGEABLE, &mm->flags);
>  	atomic_inc(&mm->mm_count);
>  
> @@ -1538,9 +1558,28 @@ void __ksm_exit(struct mm_struct *mm)
>  	mm_slot = get_mm_slot(mm);
>  	if (mm_slot && ksm_scan.mm_slot != mm_slot) {
>  		if (!mm_slot->rmap_list) {
> -			hlist_del(&mm_slot->link);
> -			list_del(&mm_slot->mm_list);
> -			easy_to_free = 1;
> +			/*
> +			 * If MMF_VM_MERGEABLE isn't set it was freed
> +			 * by the scan immediately after mm_count
> +			 * reached zero (visible by the scan) but
> +			 * before __ksm_exit() run, so we don't need
> +			 * to do anything here. We don't even need to
> +			 * wait for the KSM scan to release the
> +			 * mmap_sem as it's not working on the mm
> +			 * anymore but it's just releasing it, and it
> +			 * probably already did and dropped its
> +			 * mm_count too (it would however be safe to
> +			 * take mmap_sem here even if MMF_VM_MERGEABLE
> +			 * is already clear, as the actual mm can't be
> +			 * freed until we return and we run mmdrop
> +			 * too, but it's unnecessary).
> +			 */
> +			if (test_and_clear_bit(MMF_VM_MERGEABLE, &mm->flags)) {
> +				hlist_del(&mm_slot->link);
> +				list_del(&mm_slot->mm_list);
> +				easy_to_free = 1;
> +			} else
> +				mm_slot = NULL;
>  		} else {
>  			list_move(&mm_slot->mm_list,
>  				  &ksm_scan.mm_slot->mm_list);
> @@ -1550,7 +1589,6 @@ void __ksm_exit(struct mm_struct *mm)
>  
>  	if (easy_to_free) {
>  		free_mm_slot(mm_slot);
> -		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
>  		mmdrop(mm);
>  	} else if (mm_slot) {
>  		down_write(&mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
