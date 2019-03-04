Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FF5CC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7C3420830
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7C3420830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E95C8E0004; Mon,  4 Mar 2019 14:59:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 598638E0001; Mon,  4 Mar 2019 14:59:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 439838E0004; Mon,  4 Mar 2019 14:59:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F30028E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:59:56 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id h70so6451314pfd.11
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:59:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PmBrd4o9vunmvsiSxTL1Lv8RUgFNQhRz0D3UvZRqmjI=;
        b=Va72ZnDA4YquCdDTmABgHit8NvZZkbnA5OnuFTp9aSWtObnCmasmrSBuyFXh3xbt4v
         7hYxGPvHlDcOKqMWO24lr3obi+pBztEFdSNNV+ecWzF6gejZ+fTxJmI0ot/v223cF0Xc
         hpqwmL7oXQ3/n876YFQuG4xzrqu9d50lVVKCnvEMQk+DlZkBdrJAO6EAb+avTq6BnJw5
         6UAp5MCvfvVGWJFuE05pzxkBDt4L5A1uahB6fGolfnU4SHEEkLSVKu84fJ5u9K1kbzzQ
         pNUczrM1Y9qfsnlOeOq4luQMipsTEpF6oh2O36otHAC2OBQU9m4LeY0q3JQckOWf0bD5
         UOFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubRqg4E/fSk35/8CEe8V6q+NP+OVZYeraQxDsyCY1vziqEe3mX4
	3ugH9TTGCO6Cn1cKPlmtgDUbrF8+Ik66xVwNBQw6w6MKml4YZv2+KgIKN9FcPAVfT9OTrXzLoVW
	SV1etjAnFRXudeAI80nVFLZjotEThY0b5Fp7oBjPKYTquAPajCzvuxlJdrdD9Yx/1gA==
X-Received: by 2002:a62:b248:: with SMTP id x69mr21512891pfe.256.1551729596691;
        Mon, 04 Mar 2019 11:59:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYf5sjpiZdgFC7DW6xxdwFJGUEvrPEc5BMj2qhQRsV52DNjQ5GGWgesYtoOjAAJTxf61LQ+
X-Received: by 2002:a62:b248:: with SMTP id x69mr21512808pfe.256.1551729595821;
        Mon, 04 Mar 2019 11:59:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551729595; cv=none;
        d=google.com; s=arc-20160816;
        b=qKPXvuRcNzzl5Ngx7v8YQ0byYG13qx8Ump6mFs4g2JQH1LrMDT4HTG6rEWMvugKE4D
         mXP+dihOiU9bh75pggHqZmIHsUsSvj6eajkrZ4iHdqKS0eQ3nx27HDIEq8iukmQaWapx
         jkt9HCqvg/EdLKVx7Pm8V5W5ug8QOnG9V+KJuVeM48fcAehIdDHz9S/obRcM3QQfKw7z
         Xez+AZ21fyu1QPtBvTcUtqdvkn8QBTtDQYANZmmJa7Eo05cuXFuerxI5xh1J3/EzR7NN
         EW1P1QhX6PgBYH40u0At3RxuRzBQO06Kc2iyAPkm4OEU8+PeDT1790vd7oU+p4l0p+n0
         G4Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PmBrd4o9vunmvsiSxTL1Lv8RUgFNQhRz0D3UvZRqmjI=;
        b=cbYc/+jLa8eRs4m7Zq0OHE/r8bjJl7zZRdA/bv8Q8ZM8kJhGO5YstwRvBH93sp79FF
         J/iHhUxHzai8e95df75Q5juH8mlseHXBgHYnomyEgJQHYKNcw6UO3qiDmRB8JseoSTIr
         PJ1JZF1wx2FBPhLqWQh2AzbJOL9Br8qmHzOZokH6uo5i7n3b9wP/EoxxgCFvhINNOsjd
         9pPK8xHi/jOIQ7wcJBmY43m3Ez4GMgIODwu6SPWk/rrx7nXnmS5/MTJ1AfsmaVUTMn7i
         fI1KhG6zidmP+MVa/uQZ8XuqHn7r0sZeLFVxcW7aA+vYFz6Mt0+hIoBCKFRmjjcpUaXp
         wapg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id co9si6673990plb.324.2019.03.04.11.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:59:55 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Mar 2019 11:59:55 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,441,1544515200"; 
   d="scan'208";a="120916949"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 04 Mar 2019 11:59:54 -0800
Date: Mon, 4 Mar 2019 03:58:15 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Leon Romanovsky <leon@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190304115814.GE30058@iweiny-DESK2.sc.intel.com>
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

I meant...

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

<sigh>  just a bit too quick on the keyboard before lunch...  ;-)

Ira


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

