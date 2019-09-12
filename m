Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B2D9C49ED9
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 056E220650
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 08:26:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 056E220650
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542C26B0003; Thu, 12 Sep 2019 04:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CA4D6B0005; Thu, 12 Sep 2019 04:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B7B76B0006; Thu, 12 Sep 2019 04:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0090.hostedemail.com [216.40.44.90])
	by kanga.kvack.org (Postfix) with ESMTP id 136186B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 04:26:18 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B5F87180AD801
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:26:17 +0000 (UTC)
X-FDA: 75925586394.27.verse35_7119d7be2cd0a
X-HE-Tag: verse35_7119d7be2cd0a
X-Filterd-Recvd-Size: 1763
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 08:26:17 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 573D1227A81; Thu, 12 Sep 2019 10:26:13 +0200 (CEST)
Date: Thu, 12 Sep 2019 10:26:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/4] mm/hmm: make full use of walk_page_range()
Message-ID: <20190912082613.GA14368@lst.de>
References: <20190911222829.28874-1-rcampbell@nvidia.com> <20190911222829.28874-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190911222829.28874-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> +static int hmm_pfns_fill(unsigned long addr,
> +			 unsigned long end,
> +			 struct hmm_range *range,
> +			 enum hmm_pfn_value_e value)

Nit: can we use the space a little more efficient, e.g.:

static int hmm_pfns_fill(unsigned long addr, unsigned long end,
		struct hmm_range *range, enum hmm_pfn_value_e value)

> +static int hmm_vma_walk_test(unsigned long start,
> +			     unsigned long end,
> +			     struct mm_walk *walk)

Same here.

> +	if (!(vma->vm_flags & VM_READ)) {
> +		(void) hmm_pfns_fill(start, end, range, HMM_PFN_NONE);

There should be no need for the void cast here.

