Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE466B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 18:41:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id b53so7857173wrd.1
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 15:41:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 34si6845445wrd.124.2018.02.13.15.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 15:41:27 -0800 (PST)
Date: Tue, 13 Feb 2018 15:41:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v5 RESEND] mm, swap: Fix race between swapoff and
 some swap operations
Message-Id: <20180213154123.9f4ef9e406ea8365ca46d9c5@linux-foundation.org>
In-Reply-To: <20180213014220.2464-1-ying.huang@intel.com>
References: <20180213014220.2464-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Tue, 13 Feb 2018 09:42:20 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> When the swapin is performed, after getting the swap entry information
> from the page table, system will swap in the swap entry, without any
> lock held to prevent the swap device from being swapoff.  This may
> cause the race like below,

Sigh.  In terms of putting all the work into the swapoff path and
avoiding overheads in the hot paths, I guess this is about as good as
it will get.

It's a very low-priority fix so I'd prefer to keep the patch in -mm
until Hugh has had an opportunity to think about it.

> ...
>  
> +/*
> + * Check whether swap entry is valid in the swap device.  If so,
> + * return pointer to swap_info_struct, and keep the swap entry valid
> + * via preventing the swap device from being swapoff, until
> + * put_swap_device() is called.  Otherwise return NULL.
> + */
> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
> +{
> +	struct swap_info_struct *si;
> +	unsigned long type, offset;
> +
> +	if (!entry.val)
> +		goto out;
> +	type = swp_type(entry);
> +	if (type >= nr_swapfiles)
> +		goto bad_nofile;
> +	si = swap_info[type];
> +
> +	preempt_disable();

This preempt_disable() is later than I'd expect.  If a well-timed race
occurs, `si' could now be pointing at a defunct entry.  If that
well-timed race include a swapoff AND a swapon, `si' could be pointing
at the info for a new device?

> +	if (!(si->flags & SWP_VALID))
> +		goto unlock_out;
> +	offset = swp_offset(entry);
> +	if (offset >= si->max)
> +		goto unlock_out;
> +
> +	return si;
> +bad_nofile:
> +	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
> +out:
> +	return NULL;
> +unlock_out:
> +	preempt_enable();
> +	return NULL;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
