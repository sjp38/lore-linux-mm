Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D34246B006E
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:54:59 -0500 (EST)
Date: Tue, 27 Nov 2012 13:54:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, soft offline: split thp at the beginning of
 soft_offline_page()
Message-Id: <20121127135458.4b7369f7.akpm@linux-foundation.org>
In-Reply-To: <1354050331-26844-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1354050331-26844-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Nov 2012 16:05:31 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> When we try to soft-offline a thp tail page, put_page() is called on the
> tail page unthinkingly and VM_BUG_ON is triggered in put_compound_page().
> This patch splits thp before going into the main body of soft-offlining.
> 
> The interface of soft-offlining is open for userspace, so this bug can
> lead to DoS attack and should be fixed immedately.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/memory-failure.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git v3.7-rc7.orig/mm/memory-failure.c v3.7-rc7/mm/memory-failure.c
> index 8fe3640..e48e235 100644
> --- v3.7-rc7.orig/mm/memory-failure.c
> +++ v3.7-rc7/mm/memory-failure.c
> @@ -1548,9 +1548,17 @@ int soft_offline_page(struct page *page, int flags)
>  {
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
> +	struct page *hpage = compound_trans_head(page);
>  
>  	if (PageHuge(page))
>  		return soft_offline_huge_page(page, flags);
> +	if (PageTransHuge(hpage)) {
> +		if (PageAnon(hpage) && unlikely(split_huge_page(hpage))) {
> +			pr_info("soft offline: %#lx: failed to split THP\n",
> +				pfn);
> +			return -EBUSY;
> +		}
> +	}

We can use PageTransCompound() here, as we know it isn't a hugetlbfs
page.  This will then permit the PageAnon() test to be omitted, methinks?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
