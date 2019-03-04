Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3C04C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:58:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B799F20835
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:58:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B799F20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ED118E0003; Mon,  4 Mar 2019 14:58:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39D268E0001; Mon,  4 Mar 2019 14:58:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23E788E0003; Mon,  4 Mar 2019 14:58:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3CCA8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:58:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id e1so5785274pgs.9
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:58:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8Urlv/kHG1i5voROlgsy6xLuxTxqh+sUWVGy9cVwXb8=;
        b=W+HY1CwS7vol7VhfQVx2LvTZyIYSIo/iGMxhUv/ETGNPKghmFRnAiXCThUk7A5qPR2
         ub18d1PLBkviMeurWrHsVs/kbDABmAm7r41G5yAzmCakzOSkukG1x2ByRKX7QgjGi09P
         ISKu3xeo02Jw806RI3si/exhjOQtqa98lli1bQcU98R4E+z5RPl629D6bAdJteP8anQC
         cjQ92Kza0JqaMOREqIVu0z7bePFRyGwspybNgMgsBvXAay67Gk6ZXy7T6IeGah8Ae6hW
         99N+txBiv2fE5oo0eZhwVX66N2Weft6lk0M2JD/YPaOTpCfwO9pvC/4tkYReNtQ5b83I
         ZBrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX+PNZjpcJQYd5RsXCzm08qyQX9yjQXJ+3+xBLhxG8iwYKLoH29
	ZpnpDuyXblYLVI1To9libbAEQBY0ZjkandSYVBxQBCIV+IqUvNvYYFj4rmUCHE52XMaQsUHq9eS
	3L7aJRxltIt1K3EbbOLtfZnAs3URCDQt6PoajaQzADvJzh+gIIBI/vES/gP97LBvsCQ==
X-Received: by 2002:a63:ca:: with SMTP id 193mr20124673pga.288.1551729535545;
        Mon, 04 Mar 2019 11:58:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqyEk1c/ZEfAFQo55D+AQIQpkyDXXh8KMKPngnqrDjz/bdEdv71LCvyZaxVIck7EWIlx4951
X-Received: by 2002:a63:ca:: with SMTP id 193mr20124616pga.288.1551729534602;
        Mon, 04 Mar 2019 11:58:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551729534; cv=none;
        d=google.com; s=arc-20160816;
        b=MRF2xwmDauB4k7JCPCYsTJOkU8eOe50wR5u5WqHmfkP96F0Kl2maTYRrNM7vZ0NeLI
         lFPqtQHHT1tvpsr/kVAy2gGkbMytJYBDKgk60OpeaTOWLZhOFzRYOx93wt/Pnjsm/BXV
         HiMV1ePaSjXSZc0oFF0O6SRqCibKRqo6yehSMxS4O5AStptFH6/wtTXxqnCs/QFP8j7+
         ajdInQoZY2Vvb6+dO3YOabxbiPypoMeJ5i5CEQtqC3sQQ7/yBnybXsE1rcRotYaDAG8B
         XHRMpmKC5uthgYyegbmljg3+UsFB3HyI2pwg/OSnWUobH9yFTSj3jcQJC80IPyS3t2K8
         AI6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8Urlv/kHG1i5voROlgsy6xLuxTxqh+sUWVGy9cVwXb8=;
        b=Mpt7bItzxe7LbK4CQFoc3zF4K+hLZC5oGxd4iJSW9qifK2nANnGRWws3ZfJZb2PqGk
         ZGl5PI+HWeQqvPQ2ONru4B0ZCShPBAzkjOKARZikTGevZtXIVunyOGuOBiqKgpYJc5Xo
         Pp+3d75t42mZwTEOqh1g23BSYD0uT7ZQg25KXdtGS7SED5Pi1i4kDvd1JXlOQwE79NFO
         DT9z3in+aN3fZihippuCxrijVUrDs+lQxWEh9JYDy3262IkQvjz6wOkULuLDfJ85eiaO
         sr+ceLE9JmHTYhYT0c2JdgtzoUHQkfOGLsJpM1NiSXVOhvxiU9mH/XVaD8kgnkeAjPPa
         1P/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h9si6500314plk.373.2019.03.04.11.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:58:54 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Mar 2019 11:58:54 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,441,1544515200"; 
   d="scan'208";a="131541557"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 04 Mar 2019 11:58:53 -0800
Date: Mon, 4 Mar 2019 03:57:14 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Leon Romanovsky <leon@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190304115713.GD30058@iweiny-DESK2.sc.intel.com>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
 <20190304194645.10422-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304194645.10422-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 11:46:45AM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> 1. Bug fix: fix an off by one error in the code that
> cleans up if it fails to dma-map a page, after having
> done a get_user_pages_remote() on a range of pages.
> 
> 2. Refinement: for that same cleanup code, release_pages()
> is better than put_page() in a loop.
> 
> Cc: Leon Romanovsky <leon@kernel.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

> ---
>  drivers/infiniband/core/umem_odp.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
> index acb882f279cb..d45735b02e07 100644
> --- a/drivers/infiniband/core/umem_odp.c
> +++ b/drivers/infiniband/core/umem_odp.c
> @@ -40,6 +40,7 @@
>  #include <linux/vmalloc.h>
>  #include <linux/hugetlb.h>
>  #include <linux/interval_tree_generic.h>
> +#include <linux/pagemap.h>
>  
>  #include <rdma/ib_verbs.h>
>  #include <rdma/ib_umem.h>
> @@ -684,9 +685,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
>  		mutex_unlock(&umem_odp->umem_mutex);
>  
>  		if (ret < 0) {
> -			/* Release left over pages when handling errors. */
> -			for (++j; j < npages; ++j)
> -				put_page(local_page_list[j]);
> +			/*
> +			 * Release pages, starting at the the first page
> +			 * that experienced an error.
> +			 */
> +			release_pages(&local_page_list[j], npages - j);
>  			break;
>  		}
>  	}
> -- 
> 2.21.0
> 

