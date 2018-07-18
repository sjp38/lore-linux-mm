Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A66836B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 23:09:33 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q21-v6so1504582pff.21
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 20:09:33 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c5-v6si2376559pll.275.2018.07.17.20.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 20:09:32 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 1/7] swap: Add comments to lock_cluster_or_swap_info()
References: <20180717005556.29758-1-ying.huang@intel.com>
	<20180717005556.29758-2-ying.huang@intel.com>
	<0b478120-1af2-1251-361a-58c30b258ca3@linux.intel.com>
Date: Wed, 18 Jul 2018 11:09:25 +0800
In-Reply-To: <0b478120-1af2-1251-361a-58c30b258ca3@linux.intel.com> (Dave
	Hansen's message of "Tue, 17 Jul 2018 11:27:27 -0700")
Message-ID: <87bmb5gryy.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

> On 07/16/2018 05:55 PM, Huang, Ying wrote:
>> +/*
>> + * For non-HDD swap devices, the fine grained cluster lock is used to
>> + * protect si->swap_map.  But cluster and cluster locks isn't
>> + * available for HDD, so coarse grained si->lock will be used instead
>> + * for that.
>> + */
>>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>>  	struct swap_info_struct *si,
>>  	unsigned long offset)
>
> This nomenclature is not consistent with the rest of the file.  We call
> a "non-HDD" device an "ssd" absolutely everywhere else in the file.  Why
> are you calling it a non-HDD here?  (fwiw, HDD _barely_ hits my acronym
> cache anyway).
>
> How about this?
>
> /*
>  * Determine the locking method in use for this device.  Return
>  * swap_cluster_info if SSD-style cluster-based locking is in place.
>  */
> static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>         struct swap_info_struct *si,
>         unsigned long offset)
> {
>         struct swap_cluster_info *ci;
>
> 	/* Try to use fine-grained SSD-style locking if available: */
>         ci = lock_cluster(si, offset);
>
> 	/* Otherwise, fall back to traditional, coarse locking: */
>         if (!ci)
>                 spin_lock(&si->lock);
>
>         return ci;
> }

This is better than my one, will use this.  Thanks!

> Which reminds me?  Why do we even bother having two locking models?

Because si->cluster_info is NULL for non-SSD, so we cannot use cluster
lock.

About why not use struct swap_cluster_info for non-SSD?  Per my
understanding, struct swap_cluster_info is optimized for SSD.
Especially it assumes seeking is cheap.  So different free swap slot
scanning policy is used for SSD and non-SSD.

Best Regards,
Huang, Ying
