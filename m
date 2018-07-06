Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57AF56B0007
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 08:49:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w11-v6so962008pfk.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 05:49:19 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n9-v6si7514234pgp.558.2018.07.06.05.49.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 05:49:18 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v4 05/21] mm, THP, swap: Support PMD swap mapping in free_swap_and_cache()/swap_free()
References: <20180622035151.6676-1-ying.huang@intel.com>
	<20180622035151.6676-6-ying.huang@intel.com>
	<20180705183318.je4gd32awgh2tnb5@ca-dmjordan1.us.oracle.com>
Date: Fri, 06 Jul 2018 20:49:05 +0800
In-Reply-To: <20180705183318.je4gd32awgh2tnb5@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Thu, 5 Jul 2018 11:33:18 -0700")
Message-ID: <877em8msvy.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Jun 22, 2018 at 11:51:35AM +0800, Huang, Ying wrote:
>> +static unsigned char swap_free_cluster(struct swap_info_struct *si,
>> +				       swp_entry_t entry)
> ...
>> +	/* Cluster has been split, free each swap entries in cluster */
>> +	if (!cluster_is_huge(ci)) {
>> +		unlock_cluster(ci);
>> +		for (i = 0; i < SWAPFILE_CLUSTER; i++, entry.val++) {
>> +			if (!__swap_entry_free(si, entry, 1)) {
>> +				free_entries++;
>> +				free_swap_slot(entry);
>> +			}
>> +		}
>
> Is is better on average to use __swap_entry_free_locked instead of
> __swap_entry_free here?  I'm not sure myself, just asking.
>
> As it's written, if the cluster's been split, we always take and drop the
> cluster lock 512 times, but if we don't expect to call free_swap_slot that
> often, then we could just drop and retake the cluster lock inside the innermost
> 'if' against the possibility that free_swap_slot eventually makes us take the
> cluster lock again.

Yes.  This is a good idea.  Thanks for your suggestion!  I will change
this in the next version.

Best Regards,
Huang, Ying

> ...
>> +		return !(free_entries == SWAPFILE_CLUSTER);
>
>                 return free_entries != SWAPFILE_CLUSTER;
