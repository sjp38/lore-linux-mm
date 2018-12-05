Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2665E6B7543
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:35:24 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so17160087pfr.6
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:35:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si18135703pgd.256.2018.12.05.08.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:35:23 -0800 (PST)
Date: Wed, 5 Dec 2018 17:35:20 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 1/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end callback
Message-ID: <20181205163520.GG30615@quack2.suse.cz>
References: <20181205053628.3210-1-jglisse@redhat.com>
 <20181205053628.3210-2-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205053628.3210-2-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed 05-12-18 00:36:26, jglisse@redhat.com wrote:
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 5119ff846769..5f6665ae3ee2 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -178,14 +178,20 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end,
>  				  bool blockable)
>  {
> +	struct mmu_notifier_range _range, *range = &_range;

Why these games with two variables?

>  	struct mmu_notifier *mn;
>  	int ret = 0;
>  	int id;
>  
> +	range->blockable = blockable;
> +	range->start = start;
> +	range->end = end;
> +	range->mm = mm;
> +

Use your init function for this?

>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start) {
> -			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
> +			int _ret = mn->ops->invalidate_range_start(mn, range);
>  			if (_ret) {
>  				pr_info("%pS callback failed with %d in %sblockable context.\n",
>  						mn->ops->invalidate_range_start, _ret,
> @@ -205,9 +211,20 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
>  					 unsigned long end,
>  					 bool only_end)
>  {
> +	struct mmu_notifier_range _range, *range = &_range;
>  	struct mmu_notifier *mn;
>  	int id;
>  
> +	/*
> +	 * The end call back will never be call if the start refused to go
> +	 * through because of blockable was false so here assume that we
> +	 * can block.
> +	 */
> +	range->blockable = true;
> +	range->start = start;
> +	range->end = end;
> +	range->mm = mm;
> +

The same as above.

Otherwise the patch looks good to me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
