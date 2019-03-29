Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3CAEC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:24:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88283218D9
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:24:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XaeoYxfB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88283218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 174B86B000D; Fri, 29 Mar 2019 13:24:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12E306B000E; Fri, 29 Mar 2019 13:24:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06526B0010; Fri, 29 Mar 2019 13:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2F1E6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:24:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q18so2102373pll.16
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:24:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mExVs3kZ1Z1sjG9qam6Rn5YDEB31Pu5dMm4hIqehDCc=;
        b=BpGf7wZ7Tr6CtQ81swGECsI0e+B4Uf0PUnxLHzxWysv09DZtBfwWTRQwkK7N2yIGWV
         FxyIEcFyQLwjY+NbEsO5gTPPkcDovzt6aH/jPo+79A78awIKm6lFnr4yb/ifmZ3JnP2N
         2+y0mMnSARH0NB7UG4XV+3TIROtxj9i7SFNsx2yKjpHqqHnHzZkAoejjbjnOCPi3FmRj
         qn5EC6ZqSkx4qP16Zd3EJ39WVOChBVV+wmapp903u0bdAWPKYbbOytiJ1LI3XJ+n5XR5
         83tWaGIGTiY/Oc2/DUqyLsqUj09efj5EpXEzq6+2vR0Gf+L3bCOS5X6bcN3C8JgcFhMa
         wJog==
X-Gm-Message-State: APjAAAWgNJEjqmbE1bUYNG+UvoWtNy3R56EOl/8kcgPtMCe0B/n2RmUS
	Fy98sAw08tS8qE3cGs4wGGHDmR4Pdh6xUPElIc6wtRf+0QiqTlNGygqrCbszHMk3/TgyII3mU/5
	SG/6WdFTdO4b4ucSAH75T1h4gmVd9GVLBd7tx43lH83I1Fa8myV5A/gG70SyqlQfJNw==
X-Received: by 2002:a17:902:8ecc:: with SMTP id x12mr37934488plo.0.1553880249079;
        Fri, 29 Mar 2019 10:24:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOn+/wGfUkOW6zTusJlYrKik4L6Ry7dcVmxfL1PkNGqb9n+eqwtt20VhZ6r8jokN2GEwNP
X-Received: by 2002:a17:902:8ecc:: with SMTP id x12mr37934427plo.0.1553880248236;
        Fri, 29 Mar 2019 10:24:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553880248; cv=none;
        d=google.com; s=arc-20160816;
        b=kT81EspsjPSKBkEy3aX0ABCnPVFhyyroagH0GLXK8aareZoqOJ7abTX8rGMOfnGQbk
         buOxk0ZOl8JpZWwAcofS7xLZavb6EHAYU915XdlY7t8gdU7BP/0/30JUJdhrJ66pHn+Z
         LJUCEV6umi9TqKOE8f8MpK9F7KEXrlHgSriXYb58qXacb5R3P2EqpXdMT9qpeavgfqI2
         Z+ip/T0ZoaOu4P2cqSVufxCco7X+B8SpBlqzyLQqtBnXcbQ1GJqnkpQlnsXiWWmJNgjJ
         iq3HYDN9ZMVvIrMcYv3M0asvpfIMy7/vqc9F2CFQNnFkel9hTlbKHhKIS8IvCHk8D+E/
         9FIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mExVs3kZ1Z1sjG9qam6Rn5YDEB31Pu5dMm4hIqehDCc=;
        b=sYDueMdjxA29GXKjRg/qL3lnlKYz16GAdch+qNPPQkl1LvL7KL2I0TR1d6gl4Qdbki
         fiXan2nV36bHrsP9Y5HwDvoZt0SOy5fBYH+pQlqsQEOwoipk1BgCTwBSQ9qVvA8a1lLH
         FqMlr9H9pK/zb7JtBDu3RRm5BlpOT6pxL8u2JdPTI9mLVsr4JXDMfD4gnGiygyrT5VQq
         rZMR4Iobry41lLeirgV5aCgNzjqu8PzMJFCRleX5D1pGn0vlkDSa1xA5oxc21T5G3yGr
         7IX6hanskVJLkaFFZ2HH0e1J2Sb3CxzZ1RzYQrN+XV0/qFi992VmFr+lILe772sB/YpP
         yZEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XaeoYxfB;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e10si2269761plt.283.2019.03.29.10.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 10:24:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=XaeoYxfB;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (173-25-63-173.client.mchsi.com [173.25.63.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8605E206B7;
	Fri, 29 Mar 2019 17:24:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553880247;
	bh=VC4PyqRuLdoo3kJeLqcTkeedPqD2aigIHEsXG/WvdXc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=XaeoYxfB4xX1jfhvGuFD1WI4kG+oFo3r1S3pW+ox5/B43OnMZuqtpT8oFsiV+9Cw+
	 u9BRIA7PCBsYOE/vk5/YvaWN+1vM0bvRT4dcEZjmNHRArK6U+zE5OxFght0BcU+gif
	 xoZeW5pdZYT2VFr0N++31z8hdFteGOty//947LTo=
Date: Fri, 29 Mar 2019 12:24:06 -0500
From: Bjorn Helgaas <helgaas@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>, Christoph Hellwig <hch@lst.de>,
	linux-mm@kvack.org, linux-pci@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/6] pci/p2pdma: Fix the gen_pool_add_virt() failure path
Message-ID: <20190329172406.GE24180@google.com>
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155387325926.2443841.6674640070856872301.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155387325926.2443841.6674640070856872301.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 08:27:39AM -0700, Dan Williams wrote:
> The pci_p2pdma_add_resource() implementation immediately frees the pgmap
> if gen_pool_add_virt() fails. However, that means that when @dev
> triggers a devres release devm_memremap_pages_release() will crash
> trying to access the freed @pgmap.
> 
> Use the new devm_memunmap_pages() to manually free the mapping in the
> error path.
> 
> Fixes: 52916982af48 ("PCI/P2PDMA: Support peer-to-peer memory")
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Bjorn Helgaas <bhelgaas@google.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Especially if you run "git log --oneline drivers/pci/p2pdma.c" and make
yours match :),

Acked-by: Bjorn Helgaas <bhelgaas@google.com>

> ---
>  drivers/pci/p2pdma.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index c52298d76e64..595a534bd749 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -208,13 +208,15 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  			pci_bus_address(pdev, bar) + offset,
>  			resource_size(&pgmap->res), dev_to_node(&pdev->dev));
>  	if (error)
> -		goto pgmap_free;
> +		goto pages_free;
>  
>  	pci_info(pdev, "added peer-to-peer DMA memory %pR\n",
>  		 &pgmap->res);
>  
>  	return 0;
>  
> +pages_free:
> +	devm_memunmap_pages(&pdev->dev, pgmap);
>  pgmap_free:
>  	devm_kfree(&pdev->dev, pgmap);
>  	return error;
> 

