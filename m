Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 013636B06B1
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:54:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p43so1855342wrb.6
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:54:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si1297211wme.92.2017.08.03.05.54.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 05:54:13 -0700 (PDT)
Date: Thu, 3 Aug 2017 14:54:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
Message-ID: <20170803125409.GT12521@dhcp22.suse.cz>
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, zhenwei.pi@youruncloud.com, akpm@linux-foundation.org, dave.hansen@intel.com, mawilcox@microsoft.com

On Thu 03-08-17 19:59:17, Wei Wang wrote:
> This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
> enqueue zero page to balloon device")'
> 
> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> shouldn't be given to the host ksmd to scan.

I find MADV_DONTNEED reference still quite confusing. What do you think
about the following wording instead:
"
Zeroying ballon pages is rather time consuming, especially when a lot of
pages are in flight. E.g. 7GB worth of ballooned memory takes 2.8s with
__GFP_ZERO while it takes ~491ms without it. The original commit argued
that zeroying will help ksmd to merge these pages on the host but this
argument is assuming that the host actually marks balloon pages for ksm
which is not universally true. So we pay performance penalty for
something that even might not be used in the end which is wrong. The
host can zero out pages on its own when there is a need.
"

> Therefore, it is not
> necessary to zero ballooned pages, which is very time consuming when
> the page amount is large. The ongoing fast balloon tests show that the
> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
> __GFP_ZERO added. So, this patch removes the flag.

The only reason why unconditional zeroying makes some sense is the
data leak protection (guest doesn't want to leak potentially sensitive
data to a malicious guest). I am not sure such a thread applies here
though.

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>

other than that
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/balloon_compaction.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index 9075aa5..b06d9fe 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -24,7 +24,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
>  {
>  	unsigned long flags;
>  	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> -				__GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_ZERO);
> +				       __GFP_NOMEMALLOC | __GFP_NORETRY);
>  	if (!page)
>  		return NULL;
>  
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
