Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56FF16B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 14:33:35 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id q184-v6so3632266vke.23
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 11:33:35 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c195-v6si2472638vkd.55.2018.07.05.11.33.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 11:33:34 -0700 (PDT)
Date: Thu, 5 Jul 2018 11:33:18 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in
 free_swap_and_cache()/swap_free()
Message-ID: <20180705183318.je4gd32awgh2tnb5@ca-dmjordan1.us.oracle.com>
References: <20180622035151.6676-1-ying.huang@intel.com>
 <20180622035151.6676-6-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622035151.6676-6-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Fri, Jun 22, 2018 at 11:51:35AM +0800, Huang, Ying wrote:
> +static unsigned char swap_free_cluster(struct swap_info_struct *si,
> +				       swp_entry_t entry)
...
> +	/* Cluster has been split, free each swap entries in cluster */
> +	if (!cluster_is_huge(ci)) {
> +		unlock_cluster(ci);
> +		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
> +			if (!__swap_entry_free(si, entry, 1)) {
> +				free_entries++;
> +				free_swap_slot(entry);
> +			}
> +		}

Is is better on average to use __swap_entry_free_locked instead of
__swap_entry_free here?  I'm not sure myself, just asking.

As it's written, if the cluster's been split, we always take and drop the
cluster lock 512 times, but if we don't expect to call free_swap_slot that
often, then we could just drop and retake the cluster lock inside the innermost
'if' against the possibility that free_swap_slot eventually makes us take the
cluster lock again.

...
> +		return !(free_entries == SWAPFILE_CLUSTER);

                return free_entries != SWAPFILE_CLUSTER;
