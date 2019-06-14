Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02387C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A61AB20851
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:13:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A61AB20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA396B000A; Fri, 14 Jun 2019 02:13:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1451B6B000D; Fri, 14 Jun 2019 02:13:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05B596B000E; Fri, 14 Jun 2019 02:13:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id C622E6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:13:16 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id i22so254340wmb.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:13:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GnkUosHJoTXZL7xWafumCj5mzHivQ0r8P4JPAbzIotI=;
        b=jFLh/1/FvePCI0EVrCUcKENXEdITsazFthFEyx75vKS6DGJwWZSkRjQ0APqQgtfOkZ
         pRmNow6vI2l1/7LWIkm9YNYZnQUuGBFF4w4f03rIDWPjcRhTEdkgIw3zvtPpu8YSJbTD
         ytyo5O/Y9L/SIk1b62WIwv+D6CzxnR6c9h79ZqlwyhESPnhJAltWJn/OWv9z6gSFSjwN
         IHzgoHxcH8eEEkY8sU3qSAuRK5pHgFhD0R2C2iRb/UjFtxYvSoPZnpkjmxzIPKfXUMsh
         DdIQPfyN6+fzvMyavpVZXmlX6hlII8Ai0IFDQU2sVUgeVpGmEcIBbODEbIVu0QTRN8H3
         KfDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVZDc56st9Yd6fAu9jKH2szQvGttWMbK5RJ4YrjZhw+e5iXkyUD
	CO5ZAx13XOOnoRFzh1KxKtLyW/aeEuraDDhmS46gfYxqNF4mW+shUfp5SLOzdVZDs3uSIXM9ocb
	kKWMJ6yoH92ctUF2PNHqYXzI4729AbAd2cMeN6vXYiO/7k+kOyrmbboYRsKS3CCcdVA==
X-Received: by 2002:a5d:4fce:: with SMTP id h14mr16581wrw.231.1560492796307;
        Thu, 13 Jun 2019 23:13:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzM+cLTJJLGvQCAImnolfAnWJD98djxtfUtl90TygYl4yq3VF+wDFErHDq2XND6+3iBuaa
X-Received: by 2002:a5d:4fce:: with SMTP id h14mr16541wrw.231.1560492795636;
        Thu, 13 Jun 2019 23:13:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560492795; cv=none;
        d=google.com; s=arc-20160816;
        b=udZRl8CYBOo+LO0VXyH7L1kMoSnkrHZSUy3Of13SXHvJQSHAuXBen7lfGMRyGUJk9h
         g44A1zQXOQAy7QLQGX7R44pQMfpIrXh/TDHw1cpbBD9srsFiHxjkuGtxgWzgKaHHKdvQ
         B2GjHnqKSYdlS9IpMjOMeDVpih5GO7xWRJ82D+mmHchzaSNu8vscb495BuJ8iExAc2r3
         +dyOvQkjtvfoOezUnKLmLiZMYbUjKQuy2Fyag5YIRDmKsoHRG6lxpinv/ZneGfq1i4lD
         CjmKuXj1gRDpk8iY1kkns3RjKZLm8STkIvBP/gOBwANdZ6Jaj91C8lVlM1Lnf2UYe9Jf
         PAgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=GnkUosHJoTXZL7xWafumCj5mzHivQ0r8P4JPAbzIotI=;
        b=DZ7FtWbPq6hYKFw1fgC4/Z6iFUt3BJToikFOpl1URmKNEVTooDx/9KX/fd9Z4WBFm3
         yq9EFAFTC8M8OSYSpK1WnZeH0AKqBzdwwFq0wHMDG1H8exWrfeIm3GbrvurqpT+NAE3A
         7rfcyWysUTMMhbhldrqZHeWrblJcIdBEmf8sDDNMWnnab2B2JPHtCjayYX5pVJ6MWAp4
         w52Y1eb+7qmEjPhJFeF9wA6HSCsreDxahz/2BgZoM7HTRlWziicQ1/VyjINDJ1ZWRDlX
         gQf8R/K067iCF0+GvZgmFE37Pepd9FGwIwWI4TBATFlQ8r6UvOjEjV1YSSUNcgHa/V57
         lJsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i11si1228556wmi.66.2019.06.13.23.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:13:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 0B9D068B02; Fri, 14 Jun 2019 08:12:48 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:12:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190614061247.GB7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613141622.GE22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190613141622.GE22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 02:16:27PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 11:43:03AM +0200, Christoph Hellwig wrote:
> > Hi Dan, Jérôme and Jason,
> > 
> > below is a series that cleans up the dev_pagemap interface so that
> > it is more easily usable, which removes the need to wrap it in hmm
> > and thus allowing to kill a lot of code
> 
> Do you want some of this to run through hmm.git? I see many patches
> that don't seem to have inter-dependencies..

I think running it through hmm.git makes sense.  While there are not
actual functional dependency and just a few cosmetic conflicts keeping
the hmm stuff together makes a lot of sense.

