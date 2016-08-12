Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B29576B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:07:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so18319453wmz.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 06:07:30 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id j6si7044447wjy.133.2016.08.12.06.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 06:07:29 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so2762555wmg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 06:07:29 -0700 (PDT)
Date: Fri, 12 Aug 2016 15:07:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-page_owner-align-with-pageblock_nr-pages.patch added to -mm
 tree
Message-ID: <20160812130727.GI3639@dhcp22.suse.cz>
References: <578e7aae.YqKq+z5DSrpTUvhb%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578e7aae.YqKq+z5DSrpTUvhb%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: zhongjiang@huawei.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue 19-07-16 12:08:30, Andrew Morton wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> Subject: mm/page_owner: align with pageblock_nr pages
> 
> When pfn_valid(pfn) return false, pfn should be align with
> pageblock_nr_pages other than MAX_ORDER_NR_PAGES in init_pages_in_zone,
> because the skipped 2M may be valid pfn, as a result, early allocated
> count will not be accurate.
> 
> Link: http://lkml.kernel.org/r/1468938136-24228-1-git-send-email-zhongjiang@huawei.com
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

So I can still see this in the mmomt tree. We have discussed that
briefly and I am not sure this is an improvement or just replaces
a confused code by a differently confused one. See
http://lkml.kernel.org/r/8a4e54f2-23ed-f20f-c0da-e9412f52b606@suse.cz

What we haven't heard of yet is whether this patch actually fixes any
real problem. If not I would prefer not to make this kind of changes and
rather rework the function and co. to work with all the supported memory
models with different possible holes.

> ---
> 
>  mm/page_owner.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages mm/page_owner.c
> --- a/mm/page_owner.c~mm-page_owner-align-with-pageblock_nr-pages
> +++ a/mm/page_owner.c
> @@ -417,7 +417,7 @@ static void init_pages_in_zone(pg_data_t
>  	 */
>  	for (; pfn < end_pfn; ) {
>  		if (!pfn_valid(pfn)) {
> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>  			continue;
>  		}
>  
> _
> 
> Patches currently in -mm which might be from zhongjiang@huawei.com are
> 
> mm-update-the-comment-in-__isolate_free_page.patch
> mm-page_owner-align-with-pageblock_nr-pages.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
