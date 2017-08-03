Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7F06B06A5
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 08:24:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p135so5668233qke.0
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 05:24:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o32si19248262qtb.269.2017.08.03.05.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 05:24:05 -0700 (PDT)
Date: Thu, 3 Aug 2017 15:24:01 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
Message-ID: <20170803151844-mutt-send-email-mst@kernel.org>
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mhocko@kernel.org, zhenwei.pi@youruncloud.com, akpm@linux-foundation.org, dave.hansen@intel.com, mawilcox@microsoft.com

On Thu, Aug 03, 2017 at 07:59:17PM +0800, Wei Wang wrote:
> This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
> enqueue zero page to balloon device")'
> 
> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> shouldn't be given to the host ksmd to scan. Therefore, it is not
> necessary to zero ballooned pages, which is very time consuming when
> the page amount is large. The ongoing fast balloon tests show that the
> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
> __GFP_ZERO added. So, this patch removes the flag.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>

Fixes: bb01b64cfab7 ("mm/balloon_compaction.c: enqueue zero page to balloon device")

Looks like hypervisor is better placed to zero these if it wants to.
If it can't for some reason, this change would need a feature bit
to avoid adding extra work for all guests.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
