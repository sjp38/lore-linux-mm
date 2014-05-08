Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6DB6B0120
	for <linux-mm@kvack.org>; Thu,  8 May 2014 17:45:32 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so3364661pab.21
        for <linux-mm@kvack.org>; Thu, 08 May 2014 14:45:32 -0700 (PDT)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
        by mx.google.com with ESMTPS id hu10si1107547pbc.229.2014.05.08.14.45.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 14:45:32 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so3407889pad.18
        for <linux-mm@kvack.org>; Thu, 08 May 2014 14:45:31 -0700 (PDT)
Message-ID: <536BFAF7.4020405@linaro.org>
Date: Thu, 08 May 2014 14:45:27 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] MADV_VOLATILE: Add purged page detection on setting
 memory non-volatile
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org> <1398806483-19122-4-git-send-email-john.stultz@linaro.org> <20140508015130.GB5282@bbox>
In-Reply-To: <20140508015130.GB5282@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/07/2014 06:51 PM, Minchan Kim wrote:
> On Tue, Apr 29, 2014 at 02:21:22PM -0700, John Stultz wrote:
>> +/**
>> + * mvolatile_check_purged_pte - Checks ptes for purged pages
>> + * @pmd: pmd to walk
>> + * @addr: starting address
>> + * @end: end address
>> + * @walk: mm_walk ptr (contains ptr to mvolatile_walker)
>> + *
>> + * Iterates over the ptes in the pmd checking if they have
>> + * purged swap entries.
>> + *
>> + * Sets the mvolatile_walker.page_was_purged to 1 if any were purged,
>> + * and clears the purged pte swp entries (since the pages are no
>> + * longer volatile, we don't want future accesses to SIGBUS).
>> + */
>> +static int mvolatile_check_purged_pte(pmd_t *pmd, unsigned long addr,
>> +					unsigned long end, struct mm_walk *walk)
>> +{
>> +	struct mvolatile_walker *vw = walk->private;
>> +	pte_t *pte;
>> +	spinlock_t *ptl;
>> +
>> +	if (pmd_trans_huge(*pmd))
>> +		return 0;
>> +	if (pmd_trans_unstable(pmd))
>> +		return 0;
>> +
>> +	pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
>> +		if (!pte_present(*pte)) {
>> +			swp_entry_t mvolatile_entry = pte_to_swp_entry(*pte);
>> +
>> +			if (unlikely(is_purged_entry(mvolatile_entry))) {
>> +
>> +				vw->page_was_purged = 1;
>> +
>> +				/* clear the pte swp entry */
>> +				flush_cache_page(vw->vma, addr, pte_pfn(*pte));
> Maybe we don't need to flush the cache because there is no mapped page.
>
>> +				ptep_clear_flush(vw->vma, addr, pte);
> Maybe we don't need this, either. We didn't set present bit for purged
> page but when I look at the internal of ptep_clear_flush, it checks present bit
> and skip the TLB flush so it's okay for x86 but not sure other architecture.
> More clear function for our purpose would be pte_clear_not_present_full.

Ok.. basically I just wanted to zap the psudo-swp entry, so it will be
zero-filled from here on out.


> And we are changing page table so at least, we need to handle mmu_notifier to
> inform that to the client of mmu_notifier.

So yes, this is one item from my last iteration that I didn't act on
yet. It wasn't clear to me here that we need to do the mmu_notifier,
since the page is evicted earlier via try_to_purge_one (and we do notify
then). But in just removing the psudo-swap entry we need to do a
notification as well? Is there someplace where the mmu_notifier rules
are better documented?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
