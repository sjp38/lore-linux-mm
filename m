Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B087BC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 615CA216F4
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:00:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 615CA216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8856B0006; Mon, 12 Aug 2019 11:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 099086B0008; Mon, 12 Aug 2019 11:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF0F46B000A; Mon, 12 Aug 2019 11:00:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id CD6B66B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:00:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 71A128248AA2
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:00:18 +0000 (UTC)
X-FDA: 75814086516.17.wish22_29b480cf7c06
X-HE-Tag: wish22_29b480cf7c06
X-Filterd-Recvd-Size: 2130
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:00:17 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 96323227A81; Mon, 12 Aug 2019 17:00:12 +0200 (CEST)
Date: Mon, 12 Aug 2019 17:00:12 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 5/5] memremap: provide a not device managed
 memremap_pages
Message-ID: <20190812150012.GA12700@lst.de>
References: <20190811081247.22111-1-hch@lst.de> <20190811081247.22111-6-hch@lst.de> <20190812145058.GA16950@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812145058.GA16950@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 08:20:58PM +0530, Bharata B Rao wrote:
> On Sun, Aug 11, 2019 at 10:12:47AM +0200, Christoph Hellwig wrote:
> > The kvmppc ultravisor code wants a device private memory pool that is
> > system wide and not attached to a device.  Instead of faking up one
> > provide a low-level memremap_pages for it.  Note that this function is
> > not exported, and doesn't have a cleanup routine associated with it to
> > discourage use from more driver like users.
> 
> The kvmppc secure pages management code will be part of kvm-hv which
> can be built as module too. So it would require memremap_pages() to be
> exported.
> 
> Additionally, non-dev version of the cleanup routine
> devm_memremap_pages_release() or equivalent would also be requried.
> With device being present, put_device() used to take care of this
> cleanup.

Oh well.  We can add them fairly easily if we really need to, but I
tried to avoid that.  Can you try to see if this works non-modular
for you for now until we hear more feedback from Dan?

