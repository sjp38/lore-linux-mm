Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 786A5C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DBC22173E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 22:39:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DBC22173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D53F46B04EF; Sat, 24 Aug 2019 18:39:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D055E6B04F1; Sat, 24 Aug 2019 18:39:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF3956B04F2; Sat, 24 Aug 2019 18:39:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4C96B04EF
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 18:39:11 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 329AC45A8
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:39:11 +0000 (UTC)
X-FDA: 75858788502.10.pig45_330bc124ebf61
X-HE-Tag: pig45_330bc124ebf61
X-Filterd-Recvd-Size: 2150
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 22:39:10 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id BB04B68B02; Sun, 25 Aug 2019 00:39:07 +0200 (CEST)
Date: Sun, 25 Aug 2019 00:39:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm/hmm: hmm_range_fault() infinite loop
Message-ID: <20190824223907.GB21891@lst.de>
References: <20190823221753.2514-1-rcampbell@nvidia.com> <20190823221753.2514-3-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823221753.2514-3-rcampbell@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 03:17:53PM -0700, Ralph Campbell wrote:
> Normally, callers to handle_mm_fault() are supposed to check the
> vma->vm_flags first. hmm_range_fault() checks for VM_READ but doesn't
> check for VM_WRITE if the caller requests a page to be faulted in
> with write permission (via the hmm_range.pfns[] value).
> If the vma is write protected, this can result in an infinite loop:
>   hmm_range_fault()
>     walk_page_range()
>       ...
>       hmm_vma_walk_hole()
>         hmm_vma_walk_hole_()
>           hmm_vma_do_fault()
>             handle_mm_fault(FAULT_FLAG_WRITE)
>             /* returns VM_FAULT_WRITE */
>           /* returns -EBUSY */
>         /* returns -EBUSY */
>       /* returns -EBUSY */
>     /* loops on -EBUSY and range->valid */
> Prevent this by checking for vma->vm_flags & VM_WRITE before calling
> handle_mm_fault().
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

