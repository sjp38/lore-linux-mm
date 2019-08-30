Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E09BC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 14:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2189D23427
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 14:59:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2189D23427
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3EBC6B000C; Fri, 30 Aug 2019 10:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEF006B000D; Fri, 30 Aug 2019 10:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2BDE6B000E; Fri, 30 Aug 2019 10:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 927DA6B000C
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 10:59:40 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 161BF181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 14:59:40 +0000 (UTC)
X-FDA: 75879403320.02.print26_1a21b86cff74b
X-HE-Tag: print26_1a21b86cff74b
X-Filterd-Recvd-Size: 2428
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 14:59:39 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 8244E68BFE; Fri, 30 Aug 2019 16:59:35 +0200 (CEST)
Date: Fri, 30 Aug 2019 16:59:35 +0200
From: Christoph Hellwig <hch@lst.de>
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-xtensa@linux-xtensa.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] vmalloc: lift the arm flag for coherent mappings
 to common code
Message-ID: <20190830145935.GA19838@lst.de>
References: <20190830062924.21714-1-hch@lst.de> <20190830062924.21714-2-hch@lst.de> <20190830092918.GV13294@shell.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190830092918.GV13294@shell.armlinux.org.uk>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 10:29:18AM +0100, Russell King - ARM Linux admin wrote:
> On Fri, Aug 30, 2019 at 08:29:21AM +0200, Christoph Hellwig wrote:
> > The arm architecture had a VM_ARM_DMA_CONSISTENT flag to mark DMA
> > coherent remapping for a while.  Lift this flag to common code so
> > that we can use it generically.  We also check it in the only place
> > VM_USERMAP is directly check so that we can entirely replace that
> > flag as well (although I'm not even sure why we'd want to allow
> > remapping DMA appings, but I'd rather not change behavior).
> 
> Good, because if you did change that behaviour, you'd break almost
> every ARM framebuffer and cripple ARM audio drivers.

How would that break them?  All the usual video and audio drivers that
use dma_alloc_* then use dma_mmap_* which never end up in the only place
that actually checks VM_USERMAP (remap_vmalloc_range_partial) as they
end up in the dma_map_ops mmap methods which contain what is effecitvely
open coded versions of that routine.  There are very few callers of
remap_vmalloc_range_partial / remap_vmalloc_range, and while a few of
those actually are in media drivers and the virtual frame buffer video
driver, none of these seems to be called on dma memory (which would
be a layering violation anyway).

