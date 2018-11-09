Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07C7F6B06E0
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:47:02 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id g28so835407otd.19
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:47:02 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v34si2996195oti.39.2018.11.09.02.47.00
        for <linux-mm@kvack.org>;
        Fri, 09 Nov 2018 02:47:00 -0800 (PST)
Subject: Re: [RFC][PATCH v1 04/11] mm: madvise: call soft_offline_page()
 without MF_COUNT_INCREASED
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-5-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <21e5b9ca-ad72-b0d5-3397-4b65831b236b@arm.com>
Date: Fri, 9 Nov 2018 16:16:55 +0530
MIME-Version: 1.0
In-Reply-To: <1541746035-13408-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>



On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> Currently madvise_inject_error() pins the target page when calling
> memory error handler, but it's not good because the refcount is just
> an artifact of error injector and mock nothing about hw error itself.
> IOW, pinning the error page is part of error handler's task, so
> let's stop doing it.

Did not get that. Could you please kindly explain how an incremented
ref count through get_user_pages_fast() was a mocking the HW error
previously ? Though I might be missing the some context here.

> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/madvise.c | 25 +++++++++++--------------
>  1 file changed, 11 insertions(+), 14 deletions(-)
> 
> diff --git v4.19-mmotm-2018-10-30-16-08/mm/madvise.c v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
> index 6cb1ca9..9fa0225 100644
> --- v4.19-mmotm-2018-10-30-16-08/mm/madvise.c
> +++ v4.19-mmotm-2018-10-30-16-08_patched/mm/madvise.c
> @@ -637,6 +637,16 @@ static int madvise_inject_error(int behavior,
>  		ret = get_user_pages_fast(start, 1, 0, &page);
>  		if (ret != 1)
>  			return ret;
> +		/*
> +		 * The get_user_pages_fast() is just to get the pfn of the
> +		 * given address, and the refcount has nothing to do with
> +		 * what we try to test, so it should be released immediately.
> +		 * This is racy but it's intended because the real hardware
> +		 * errors could happen at any moment and memory error handlers
> +		 * must properly handle the race.
> +		 */
> +		put_page(page);
> +
>  		pfn = page_to_pfn(page);
>  
>  		/*
> @@ -646,16 +656,11 @@ static int madvise_inject_error(int behavior,
>  		 */
>  		order = compound_order(compound_head(page));
>  
> -		if (PageHWPoison(page)) {
> -			put_page(page);
> -			continue;
> -		}
> -
>  		if (behavior == MADV_SOFT_OFFLINE) {
>  			pr_info("Soft offlining pfn %#lx at process virtual address %#lx\n",
>  					pfn, start);
>  
> -			ret = soft_offline_page(page, MF_COUNT_INCREASED);
> +			ret = soft_offline_page(page, 0);

Probably something defined as a new "ignored" in the memory faults flag
enumeration instead of passing '0' directly.
