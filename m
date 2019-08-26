Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AB92C3A59E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 243182087E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 07:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 243182087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1FD06B0531; Mon, 26 Aug 2019 03:09:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD1BE6B0533; Mon, 26 Aug 2019 03:09:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E7086B0534; Mon, 26 Aug 2019 03:09:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id 7FF036B0531
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 03:09:44 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 189E4180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:09:44 +0000 (UTC)
X-FDA: 75863703888.10.cable47_37d6718e29a03
X-HE-Tag: cable47_37d6718e29a03
X-Filterd-Recvd-Size: 2186
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:09:43 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id B04E568B02; Mon, 26 Aug 2019 09:09:39 +0200 (CEST)
Date: Mon, 26 Aug 2019 09:09:39 +0200
From: Christoph Hellwig <hch@lst.de>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: catalin.marinas@arm.com, hch@lst.de, wahrenst@gmx.net,
	marc.zyngier@arm.com, robh+dt@kernel.org,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-riscv@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, phill@raspberryi.org,
	f.fainelli@gmail.com, will@kernel.org, linux-kernel@vger.kernel.org,
	eric@anholt.net, mbrugger@suse.com,
	linux-rpi-kernel@lists.infradead.org, akpm@linux-foundation.org,
	frowand.list@gmail.com, m.szyprowski@samsung.com
Subject: Re: [PATCH v2 01/11] asm-generic: add dma_zone_size
Message-ID: <20190826070939.GD11331@lst.de>
References: <20190820145821.27214-1-nsaenzjulienne@suse.de> <20190820145821.27214-2-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820145821.27214-2-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 04:58:09PM +0200, Nicolas Saenz Julienne wrote:
> Some architectures have platform specific DMA addressing limitations.
> This will allow for hardware description code to provide the constraints
> in a generic manner, so as for arch code to properly setup it's memory
> zones and DMA mask.

I know this just spreads the arm code, but I still kinda hate it.

MAX_DMA_ADDRESS is such an oddly defined concepts.  We have the mm
code that uses it to start allocating after the dma zones, but
I think that would better be done using a function returning
1 << max(zone_dma_bits, 32) or so.  Then we have about a handful
of drivers using it that all seem rather bogus, and one of which
I think are usable on arm64.

