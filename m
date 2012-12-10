Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id EA76D6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 06:17:19 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 17so9723542iea.30
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 03:17:19 -0800 (PST)
Message-ID: <1355138235.1821.0.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH 3/3] HWPOISON, hugetlbfs: fix RSS-counter warning
From: Simon Jeons <simon.jeons@gmail.com>
Date: Mon, 10 Dec 2012 05:17:15 -0600
In-Reply-To: <1354744058-26373-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	 <1354744058-26373-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2012-12-05 at 16:47 -0500, Naoya Horiguchi wrote:
> Memory error handling on hugepages can break a RSS counter, which emits
> a message like "Bad rss-counter state mm:ffff88040abecac0 idx:1 val:-1".
> This is because PageAnon returns true for hugepage (this behavior is

Could you explain why PageAnon returns true for hugepage?

> necessary for reverse mapping to work on hugetlbfs).
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/rmap.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git v3.7-rc8.orig/mm/rmap.c v3.7-rc8/mm/rmap.c
> index 2ee1ef0..df54ef0 100644
> --- v3.7-rc8.orig/mm/rmap.c
> +++ v3.7-rc8/mm/rmap.c
> @@ -1235,7 +1235,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  	update_hiwater_rss(mm);
>  
>  	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
> -		if (PageAnon(page))
> +		if (PageHuge(page))
> +			;
> +		else if (PageAnon(page))
>  			dec_mm_counter(mm, MM_ANONPAGES);
>  		else
>  			dec_mm_counter(mm, MM_FILEPAGES);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
