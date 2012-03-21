Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C3FD06B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 14:02:30 -0400 (EDT)
Date: Wed, 21 Mar 2012 19:02:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V3] mm: convert rcu_read_lock() to srcu_read_lock(), thus
 allowing to sleep in callbacks
Message-ID: <20120321180227.GH24602@redhat.com>
References: <1328709344-6058-1-git-send-email-sagig@mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1328709344-6058-1-git-send-email-sagig@mellanox.co.il>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-mm@kvack.org, ogrelitz@mellanox.com

Hi Sagi,

There are a couple of rcu_read_lock not converted at the top.

On Wed, Feb 08, 2012 at 03:55:43PM +0200, Sagi Grimberg wrote:
> @@ -196,6 +200,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  	if (unlikely(!mmu_notifier_mm))
>  		goto out;
>  
> +	if (init_srcu_struct(&mmu_notifier_mm->srcu))
> +		goto out_cleanup;
> +
>  	if (take_mmap_sem)
>  		down_write(&mm->mmap_sem);

out_cleanup will up_write if take_mmap_sem is set, and at that point
the mmap_sem hasn't been taken yet.

>  	ret = mm_take_all_locks(mm);
> @@ -226,8 +233,11 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  out_cleanup:
>  	if (take_mmap_sem)
>  		up_write(&mm->mmap_sem);
> -	/* kfree() does nothing if mmu_notifier_mm is NULL */
> -	kfree(mmu_notifier_mm);
> +
> +	if (mm->mmu_notifier_mm) {

I guess this should be "if (mmu_notifier_mm)";

I happened to notice my older patch still applies cleanly and it has
the above issues already correct, so I'm appending it after refreshing
it to upstream.

====
