Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0E796B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 00:07:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 66-v6so1500619plb.18
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 21:07:48 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id w22-v6si3297055pll.96.2018.07.13.21.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 21:07:47 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 1/6] swap: Add comments to lock_cluster_or_swap_info()
References: <20180712233636.20629-1-ying.huang@intel.com>
	<20180712233636.20629-2-ying.huang@intel.com>
	<3c3a4dce-980d-0405-d269-1da9e62b1344@linux.intel.com>
Date: Sat, 14 Jul 2018 12:07:43 +0800
In-Reply-To: <3c3a4dce-980d-0405-d269-1da9e62b1344@linux.intel.com> (Dave
	Hansen's message of "Fri, 13 Jul 2018 03:48:28 -0700")
Message-ID: <87in5ie9yo.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

Dave Hansen <dave.hansen@linux.intel.com> writes:

>> +/*
>> + * At most times, fine grained cluster lock is sufficient to protect
>
> Can we call out those times, please?

To protect si->swap_map[], if HDD, si->lock is used, otherwise cluster
lock is used.  "at most times" is ambiguous here, I will fix it.

>> + * the operations on sis->swap_map.  
>
> Please be careful with the naming.  You can call it 'si' because that's
> what the function argument is named.  Or, swap_info_struct because
> that's the struct name.  Calling it 'sis' is a bit sloppy, no?
>
>> 					No need to acquire gross grained
>
> "coarse" is a conventional antonym for "fine".

Sorry for my poor English, will change this.

>> + * sis->lock.  But cluster and cluster lock isn't available for HDD,
>> + * so sis->lock will be instead for them.
>> + */
>>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>>  	struct swap_info_struct *si,
>>  	unsigned long offset)
>
> What I already knew was: there are two locks.  We use one sometimes and
> the other at other times.
>
> What I don't know is why there are two locks, and the heuristics why we
> choose between them.  This comment doesn't help explain the things I
> don't know.

cluster lock is used to protect fields of struct swap_cluster_info, and
si->swap_map[], this is described in comments of struct
swap_cluster_info.  si->lock is used to protect other fields of si.  If
two locks need to be held, hold si->lock first.  This is for non-HDD.
For HDD, there are no cluster, so si->lock is used to protect
si->swap_map[].

Best Regards,
Huang, Ying
