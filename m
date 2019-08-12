Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B7FDC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C438B20679
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 15:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C438B20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6193B6B0006; Mon, 12 Aug 2019 11:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CA0A6B0007; Mon, 12 Aug 2019 11:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B8826B0008; Mon, 12 Aug 2019 11:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0242.hostedemail.com [216.40.44.242])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0FF6B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 11:51:16 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BF0A28248AA2
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:51:15 +0000 (UTC)
X-FDA: 75814214910.10.wood04_af9227d0924c
X-HE-Tag: wood04_af9227d0924c
X-Filterd-Recvd-Size: 3986
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:51:15 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6CFC24E93D;
	Mon, 12 Aug 2019 15:51:14 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AFD0162671;
	Mon, 12 Aug 2019 15:51:13 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org,  linux-mm@kvack.org,  Jason Gunthorpe <jgg@mellanox.com>,  Andrew Morton <akpm@linux-foundation.org>,  Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/memremap: Fix reuse of pgmap instances with internal references
References: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Mon, 12 Aug 2019 11:51:12 -0400
In-Reply-To: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
	(Dan Williams's message of "Thu, 08 Aug 2019 14:43:49 -0700")
Message-ID: <x49blwuidqn.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 12 Aug 2019 15:51:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> Currently, attempts to shutdown and re-enable a device-dax instance
> trigger:

What does "shutdown and re-enable" translate to?  If I disable and
re-enable a device-dax namespace, I don't see this behavior.

-Jeff

>
>     Missing reference count teardown definition
>     WARNING: CPU: 37 PID: 1608 at mm/memremap.c:211 devm_memremap_pages+0x234/0x850
>     [..]
>     RIP: 0010:devm_memremap_pages+0x234/0x850
>     [..]
>     Call Trace:
>      dev_dax_probe+0x66/0x190 [device_dax]
>      really_probe+0xef/0x390
>      driver_probe_device+0xb4/0x100
>      device_driver_attach+0x4f/0x60
>
> Given that the setup path initializes pgmap->ref, arrange for it to be
> also torn down so devm_memremap_pages() is ready to be called again and
> not be mistaken for the 3rd-party per-cpu-ref case.
>
> Fixes: 24917f6b1041 ("memremap: provide an optional internal refcount in struct dev_pagemap")
> Reported-by: Fan Du <fan.du@intel.com>
> Tested-by: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>
> Andrew, I have another dax fix pending, so I'm ok to take this through
> the nvdimm tree, holler if you want it in -mm.
>
>  mm/memremap.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/mm/memremap.c b/mm/memremap.c
> index 6ee03a816d67..86432650f829 100644
> --- a/mm/memremap.c
> +++ b/mm/memremap.c
> @@ -91,6 +91,12 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
>  		wait_for_completion(&pgmap->done);
>  		percpu_ref_exit(pgmap->ref);
>  	}
> +	/*
> +	 * Undo the pgmap ref assignment for the internal case as the
> +	 * caller may re-enable the same pgmap.
> +	 */
> +	if (pgmap->ref == &pgmap->internal_ref)
> +		pgmap->ref = NULL;
>  }
>  
>  static void devm_memremap_pages_release(void *data)
>
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

