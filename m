Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 564416B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 19:38:07 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k6so1022212pgt.15
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 16:38:07 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l4-v6si1986561pln.121.2018.02.13.16.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 16:38:06 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v5 RESEND] mm, swap: Fix race between swapoff and some swap operations
In-Reply-To: <20180213154123.9f4ef9e406ea8365ca46d9c5@linux-foundation.org>
	(Andrew Morton's message of "Tue, 13 Feb 2018 15:41:23 -0800")
References: <20180213014220.2464-1-ying.huang@intel.com>
	<20180213154123.9f4ef9e406ea8365ca46d9c5@linux-foundation.org>
Date: Wed, 14 Feb 2018 08:38:00 +0800
Message-ID: <87fu64jthz.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, jglisse@redhat.com, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 13 Feb 2018 09:42:20 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> When the swapin is performed, after getting the swap entry information
>> from the page table, system will swap in the swap entry, without any
>> lock held to prevent the swap device from being swapoff.  This may
>> cause the race like below,
>
> Sigh.  In terms of putting all the work into the swapoff path and
> avoiding overheads in the hot paths, I guess this is about as good as
> it will get.
>
> It's a very low-priority fix so I'd prefer to keep the patch in -mm
> until Hugh has had an opportunity to think about it.
>
>> ...
>>  
>> +/*
>> + * Check whether swap entry is valid in the swap device.  If so,
>> + * return pointer to swap_info_struct, and keep the swap entry valid
>> + * via preventing the swap device from being swapoff, until
>> + * put_swap_device() is called.  Otherwise return NULL.
>> + */
>> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
>> +{
>> +	struct swap_info_struct *si;
>> +	unsigned long type, offset;
>> +
>> +	if (!entry.val)
>> +		goto out;
>> +	type = swp_type(entry);
>> +	if (type >= nr_swapfiles)
>> +		goto bad_nofile;
>> +	si = swap_info[type];
>> +
>> +	preempt_disable();
>
> This preempt_disable() is later than I'd expect.  If a well-timed race
> occurs, `si' could now be pointing at a defunct entry.  If that
> well-timed race include a swapoff AND a swapon, `si' could be pointing
> at the info for a new device?

struct swap_info_struct pointed to by swap_info[] will never be freed.
During swapoff, we only free the memory pointed to by the fields of
struct swap_info_struct.  And when swapon, we will always reuse
swap_info[type] if it's not NULL.  So it should be safe to dereference
swap_info[type] with preemption enabled.

Best Regards,
Huang, Ying

>> +	if (!(si->flags & SWP_VALID))
>> +		goto unlock_out;
>> +	offset = swp_offset(entry);
>> +	if (offset >= si->max)
>> +		goto unlock_out;
>> +
>> +	return si;
>> +bad_nofile:
>> +	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
>> +out:
>> +	return NULL;
>> +unlock_out:
>> +	preempt_enable();
>> +	return NULL;
>> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
