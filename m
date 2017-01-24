Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAE86B0038
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:01:12 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r126so31168284wmr.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:01:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f36si6168193qtb.331.2017.01.24.14.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:01:11 -0800 (PST)
Message-ID: <1485295267.15964.38.camel@redhat.com>
Subject: Re: [PATCH RFC 3/3] mm, vmscan: correct prepare_kswapd_sleep return
 value
From: Rik van Riel <riel@redhat.com>
Date: Tue, 24 Jan 2017 17:01:07 -0500
In-Reply-To: <1485244144-13487-4-git-send-email-hejianet@gmail.com>
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
	 <1485244144-13487-4-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Tue, 2017-01-24 at 15:49 +0800, Jia He wrote:
> When there is no reclaimable pages in the zone, even the zone is
> not balanced, we let kswapd go sleeping. That is prepare_kswapd_sleep
> will return true in this case.
> 
> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
> A mm/vmscan.c | 3 ++-
> A 1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 7396a0a..54445e2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3140,7 +3140,8 @@ static bool prepare_kswapd_sleep(pg_data_t
> *pgdat, int order, int classzone_idx)
> A 		if (!managed_zone(zone))
> A 			continue;
> A 
> -		if (!zone_balanced(zone, order, classzone_idx))
> +		if (!zone_balanced(zone, order, classzone_idx)
> +			&& !zone_reclaimable_pages(zone))
> A 			return false;
> A 	}

This patch does the opposite of what your changelog
says.  The above keeps kswapd running forever if
the zone is not balanced, and there are no reclaimable
pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
