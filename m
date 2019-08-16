Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC1F2C3A59F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:01:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F45621721
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 21:01:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="V+taPJeo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F45621721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 060D36B000C; Fri, 16 Aug 2019 17:01:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2BEB6B000D; Fri, 16 Aug 2019 17:01:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCC9F6B000E; Fri, 16 Aug 2019 17:01:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id B64A66B000C
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:01:37 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 349A4180ACF75
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:01:37 +0000 (UTC)
X-FDA: 75829512234.07.brass38_2b24a99871b5a
X-HE-Tag: brass38_2b24a99871b5a
X-Filterd-Recvd-Size: 2051
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 21:01:36 +0000 (UTC)
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 28D7C2133F;
	Fri, 16 Aug 2019 21:01:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565989295;
	bh=MxoPEBdUgeGG8r1YMtqWjR43bDHROWKuxhhQbv0Dyd4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=V+taPJeoXoU39dnw4eLkWys2oiJYLOa4Kz30m61AGUDeqfuWPigLu5mtk/NBZ4EVe
	 B+vgjZJsohmFph06ZE175qMwGCufq9Lz2dwY9FU1nW8Qnmq5y54FKkcs3RmSkO7pGl
	 B5jzTM/MEaZDZcmqg90IE5o1Sx27v/d00qBxFkww=
Date: Fri, 16 Aug 2019 14:01:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe
 <jgg@mellanox.com>, Bharata B Rao <bharata@linux.ibm.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH 1/4] resource: add a not device managed
 request_free_mem_region variant
Message-Id: <20190816140134.1f3225bed9bf2734c03341b1@linux-foundation.org>
In-Reply-To: <20190816065434.2129-2-hch@lst.de>
References: <20190816065434.2129-1-hch@lst.de>
	<20190816065434.2129-2-hch@lst.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 16 Aug 2019 08:54:31 +0200 Christoph Hellwig <hch@lst.de> wrote:

> Just add a simple macro that passes a NULL dev argument to
> dev_request_free_mem_region, and call request_mem_region in the
> function for that particular case.

Nit:

> +struct resource *request_free_mem_region(struct resource *base,
> +		unsigned long size, const char *name);

This isn't a macro ;)

