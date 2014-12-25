Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE706B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 03:30:38 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so12698593wgg.10
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 00:30:38 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0066.outbound.protection.outlook.com. [157.55.234.66])
        by mx.google.com with ESMTPS id d7si36243553wix.90.2014.12.25.00.30.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Dec 2014 00:30:37 -0800 (PST)
Message-ID: <549BCAF8.1070500@mellanox.com>
Date: Thu, 25 Dec 2014 10:29:44 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mmu_notifier: keep track of active invalidation ranges
 v2
References: <1419266940-5440-1-git-send-email-j.glisse@gmail.com>
 <1419266940-5440-3-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1419266940-5440-3-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 22/12/2014 18:48, j.glisse@gmail.com wrote:
>  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -						       unsigned long start,
> -						       unsigned long end,
> -						       enum mmu_event event)
> +						       struct mmu_notifier_range *range)
>  {
> +	/*
> +	 * Initialize list no matter what in case a mmu_notifier register after
> +	 * a range_start but before matching range_end.
> +	 */
> +	INIT_LIST_HEAD(&range->list);

I don't see how can an mmu_notifier register after a range_start but
before a matching range_end. The mmu_notifier registration locks all mm
locks, and that should prevent any invalidation from running, right?

>  	if (mm_has_notifiers(mm))
> -		__mmu_notifier_invalidate_range_start(mm, start, end, event);
> +		__mmu_notifier_invalidate_range_start(mm, range);
>  }

...

>  void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> -					   unsigned long start,
> -					   unsigned long end,
> -					   enum mmu_event event)
> +					   struct mmu_notifier_range *range)
>  
>  {
>  	struct mmu_notifier *mn;
> @@ -185,21 +183,36 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start)
> -			mn->ops->invalidate_range_start(mn, mm, start,
> -							end, event);
> +			mn->ops->invalidate_range_start(mn, mm, range);
>  	}
>  	srcu_read_unlock(&srcu, id);
> +
> +	/*
> +	 * This must happen after the callback so that subsystem can block on
> +	 * new invalidation range to synchronize itself.
> +	 */
> +	spin_lock(&mm->mmu_notifier_mm->lock);
> +	list_add_tail(&range->list, &mm->mmu_notifier_mm->ranges);
> +	mm->mmu_notifier_mm->nranges++;
> +	spin_unlock(&mm->mmu_notifier_mm->lock);
>  }
>  EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);

Don't you have a race here because you add the range struct after the
callback?

-------------------------------------------------------------------------
Thread A                    | Thread B
-------------------------------------------------------------------------
call mmu notifier callback  |
  clear SPTE                |
                            | device page fault
                            |   mmu_notifier_range_is_valid returns true
                            |   install new SPTE
add event struct to list    |
mm clears/modifies the PTE  |
-------------------------------------------------------------------------

So we are left with different entries in the host page table and the
secondary page table.

I would think you'd want the event struct to be added to the list before
the callback is run.

Best regards,
Haggai


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
