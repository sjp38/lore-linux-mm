Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 872B36B05C5
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 02:55:13 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d24so5723779wmi.0
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 23:55:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h11si21761304wrb.480.2017.07.30.23.55.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 30 Jul 2017 23:55:12 -0700 (PDT)
Date: Mon, 31 Jul 2017 08:55:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't zero ballooned pages
Message-ID: <20170731065508.GE13036@dhcp22.suse.cz>
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org, zhenwei.pi@youruncloud.com

On Mon 31-07-17 12:13:33, Wei Wang wrote:
> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> shouldn't be given to the host ksmd to scan.

Could you point me where this MADV_DONTNEED is done, please?

> Therefore, it is not
> necessary to zero ballooned pages, which is very time consuming when
> the page amount is large. The ongoing fast balloon tests show that the
> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
> __GFP_ZERO added. So, this patch removes the flag.

Please make it obvious that this is a revert of bb01b64cfab7
("mm/balloon_compaction.c: enqueue zero page to balloon device").

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
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
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
