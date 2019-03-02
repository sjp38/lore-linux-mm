Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCFA6C10F00
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 03:45:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6411E20863
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 03:45:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6411E20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A14828E0003; Sat,  2 Mar 2019 22:45:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C3D98E0001; Sat,  2 Mar 2019 22:45:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B31C8E0003; Sat,  2 Mar 2019 22:45:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46F998E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 22:45:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id e5so1463919pgc.16
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 19:45:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ejN7RosPXtM9+dZClz8gCr4+GKgap8joGFNG7pkWjew=;
        b=WixkliEpPGmJHZIqJp3SU4oAfYQwkIBFejm8g2uD9x2RTikyMQVPat41v0OocSlyK9
         cEOKMbFmIakciNqZGf0osxwNrDGFEjz450+728Y9nPrxtUVUBPC2x8GwpalseGUvpgw6
         /mvCmA50+zTts3W3bsmtydU3gyhT5uil/BsEBabHqMbu4gcu14DQq38zJlv2d3w8gFHS
         n/eTK2wPfMH9cdGb2cFAXPOAioFvJTKIxc+5/AT48ma5nVr7UPh79oSGHsm70Rr02Exo
         HynUQVGTu7O/ID33e8Cr9lHW8m05ajGSrkdyAsb8fo3L6M9bC/4i3Re3Wv5cLPyvO9Ro
         4qSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV4v8Sq/BrZAcDfvBkoEcg4sGAmkHxNNXCz6g8quM/ER/FvRSfD
	9hZpDTZ5VHcet2guB+In5TS2biyN6H1VgOGPT0+Z6vjkd472MLpkjn0LwcecJmiB+dVhF+ELFV1
	2V0xXNnNKGMHjBhbOnN2EddN2zg+hjIpc/pmgzLDPEmH/XlhJEW1I5XpNgbmDQOz3AQ==
X-Received: by 2002:a63:1061:: with SMTP id 33mr12215381pgq.226.1551584747813;
        Sat, 02 Mar 2019 19:45:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqycF0peN8nl9Vk+5f4xIdxORjlyhe4zy6qmGf99QE7ldNqveMZ88A3R6jiay7JkZkQ7byxQ
X-Received: by 2002:a63:1061:: with SMTP id 33mr12215332pgq.226.1551584746656;
        Sat, 02 Mar 2019 19:45:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551584746; cv=none;
        d=google.com; s=arc-20160816;
        b=xuTRlLMd/ngl7KTLtiqKKie243NVpxu1SFxRslufkCH8vpvcshLHI302zZ30/9ryRa
         DkkBy+8c+t9AEA9N6nou9ulxI/WgdYAPc+Tw45sSO8KlnYj3ovD+eJj2IbuToWeLnDuo
         qZbPidVSyIooocxnKncxARXdDHmFC7UYbw3fGIVRgqKtGfByO5D3eSLfTcZe6XK9FyUM
         G9AZ4gkyHNgJFgEi9iO1F6clWI/qn/x/EOF/nYyeRBrCZUjQExJAbh3NcZoP7KtvhxHs
         UYHoJw+/hMHcsirR3vRddiQ2+6HKTB2uLgsRZG7xj2iEKgqZeOjLJx9Xt0ZuWyIttD80
         /5ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ejN7RosPXtM9+dZClz8gCr4+GKgap8joGFNG7pkWjew=;
        b=0eIEJZeliQodDp9pFFS3Jtm/1qeVmx3dUOlAUtz3sYJJz9LXnBZurVHUleBEQ2GaUJ
         dVgz5Bga/8QvRCZMDacaFM6IzvN5sDs23ytf22Kiv8Ei9bH1Oxb7aMHy//0u7WwyzqAn
         trqxPBy3rK+e9aqjeojYueJv1qsRHTRo0dFLO1kLNI2BRRHYCRvnkdEx8CRNXkBQugg8
         QYVEvHo4yret9yL8eB47nJDPXmh7yplnKHTL1o4plrh54bieSVLqLPjcES4Dd4+U21Mj
         z12GXmIB2cE+lw5JmDHOgo2CAk8V2zes/GrF0ZMDwOVjbMnpVfHaExktaw6/ShkXWeDq
         eG6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id q13si1989758pgv.157.2019.03.02.19.45.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Mar 2019 19:45:46 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Mar 2019 19:45:45 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,434,1544515200"; 
   d="scan'208";a="128568232"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga008.fm.intel.com with ESMTP; 02 Mar 2019 19:45:44 -0800
Date: Sat, 2 Mar 2019 11:44:03 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	artemyko@mellanox.com
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error
 handling paths
Message-ID: <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190302202435.31889-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

FWIW I don't have ODP hardware either.  So I can't test this either.

On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> 1. Bug fix: the error handling release pages starting
> at the first page that experienced an error.
> 
> 2. Refinement: release_pages() is better than put_page()
> in a loop.
> 
> 3. Dead code removal: the check for (user_virt & ~page_mask)
> is checking for a condition that can never happen,
> because earlier:
> 
>     user_virt = user_virt & page_mask;
> 
> ...so, remove that entire phrase.
> 
> 4. Minor: As long as I'm here, shorten up a couple of long lines
> in the same function, without harming the ability to
> grep for the printed error message.
> 
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
> 
> v2: Fixes a kbuild test robot reported build failure, by directly
>     including pagemap.h
> 
>  drivers/infiniband/core/umem_odp.c | 25 ++++++++++---------------
>  1 file changed, 10 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
> index acb882f279cb..83872c1f3f2c 100644
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
> @@ -648,25 +649,17 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
>  
>  		if (npages < 0) {
>  			if (npages != -EAGAIN)
> -				pr_warn("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
> +				pr_warn("fail to get %zu user pages with error %d\n",
> +					gup_num_pages, npages);
>  			else
> -				pr_debug("fail to get %zu user pages with error %d\n", gup_num_pages, npages);
> +				pr_debug("fail to get %zu user pages with error %d\n",
> +					 gup_num_pages, npages);
>  			break;
>  		}
>  
>  		bcnt -= min_t(size_t, npages << PAGE_SHIFT, bcnt);
>  		mutex_lock(&umem_odp->umem_mutex);
>  		for (j = 0; j < npages; j++, user_virt += PAGE_SIZE) {
> -			if (user_virt & ~page_mask) {
> -				p += PAGE_SIZE;
> -				if (page_to_phys(local_page_list[j]) != p) {
> -					ret = -EFAULT;
> -					break;
> -				}
> -				put_page(local_page_list[j]);
> -				continue;
> -			}
> -

I think this is trying to account for compound pages. (ie page_mask could
represent more than PAGE_SIZE which is what user_virt is being incrimented by.)
But putting the page in that case seems to be the wrong thing to do?

Yes this was added by Artemy[1] now cc'ed.

>  			ret = ib_umem_odp_map_dma_single_page(
>  					umem_odp, k, local_page_list[j],
>  					access_mask, current_seq);
> @@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem_odp, u64 user_virt,
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

My concern here is that release_pages handle compound pages, perhaps
differently from the above code so calling it may may not work?  But I've not
really spent a lot of time on it...

:-/

Ira

[1]

commit 403cd12e2cf759ead5cbdcb62bf9872b9618d400
Author: Artemy Kovalyov <artemyko@mellanox.com>
Date:   Wed Apr 5 09:23:55 2017 +0300

    IB/umem: Add contiguous ODP support

    Currenlty ODP supports only regular MMU pages.
    Add ODP support for regions consisting of physically contiguous chunks
    of arbitrary order (huge pages for instance) to improve performance.

    Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
    Signed-off-by: Leon Romanovsky <leon@kernel.org>
    Signed-off-by: Doug Ledford <dledford@redhat.com>


