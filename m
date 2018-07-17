Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C38586B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:27:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g15-v6so1024909plo.11
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:27:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g4-v6si1472464plb.377.2018.07.17.11.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 11:27:30 -0700 (PDT)
Subject: Re: [PATCH v2 1/7] swap: Add comments to lock_cluster_or_swap_info()
References: <20180717005556.29758-1-ying.huang@intel.com>
 <20180717005556.29758-2-ying.huang@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <0b478120-1af2-1251-361a-58c30b258ca3@linux.intel.com>
Date: Tue, 17 Jul 2018 11:27:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180717005556.29758-2-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>

On 07/16/2018 05:55 PM, Huang, Ying wrote:
> +/*
> + * For non-HDD swap devices, the fine grained cluster lock is used to
> + * protect si->swap_map.  But cluster and cluster locks isn't
> + * available for HDD, so coarse grained si->lock will be used instead
> + * for that.
> + */
>  static inline struct swap_cluster_info *lock_cluster_or_swap_info(
>  	struct swap_info_struct *si,
>  	unsigned long offset)

This nomenclature is not consistent with the rest of the file.  We call
a "non-HDD" device an "ssd" absolutely everywhere else in the file.  Why
are you calling it a non-HDD here?  (fwiw, HDD _barely_ hits my acronym
cache anyway).

How about this?

/*
 * Determine the locking method in use for this device.  Return
 * swap_cluster_info if SSD-style cluster-based locking is in place.
 */
static inline struct swap_cluster_info *lock_cluster_or_swap_info(
        struct swap_info_struct *si,
        unsigned long offset)
{
        struct swap_cluster_info *ci;

	/* Try to use fine-grained SSD-style locking if available: */
        ci = lock_cluster(si, offset);

	/* Otherwise, fall back to traditional, coarse locking: */
        if (!ci)
                spin_lock(&si->lock);

        return ci;
}

Which reminds me?  Why do we even bother having two locking models?
