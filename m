Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E28AC3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 11:31:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34BE62064A
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 11:31:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34BE62064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF1516B0005; Sat, 17 Aug 2019 07:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA1D76B0006; Sat, 17 Aug 2019 07:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B86F6B0007; Sat, 17 Aug 2019 07:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 79FCA6B0005
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 07:31:33 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 314C18248ACA
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 11:31:33 +0000 (UTC)
X-FDA: 75831704466.07.desk89_47b568e173f28
X-HE-Tag: desk89_47b568e173f28
X-Filterd-Recvd-Size: 1730
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 11:31:32 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id D1B4A68B02; Sat, 17 Aug 2019 13:31:28 +0200 (CEST)
Date: Sat, 17 Aug 2019 13:31:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 01/10] mm: turn migrate_vma upside down
Message-ID: <20190817113128.GA23295@lst.de>
References: <20190814075928.23766-1-hch@lst.de> <20190814075928.23766-2-hch@lst.de> <20190816171101.GK5412@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816171101.GK5412@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 05:11:07PM +0000, Jason Gunthorpe wrote:
> -	if (args->cpages)
> -		migrate_vma_prepare(args);
> -	if (args->cpages)
> -		migrate_vma_unmap(args);
> +	if (!args->cpages)
> +		return 0;
> +
> +	migrate_vma_prepare(args);
> +	migrate_vma_unmap(args);

I don't think this is ok.  Both migrate_vma_prepare and migrate_vma_unmap
can reduce args->cpages, including possibly to 0.

