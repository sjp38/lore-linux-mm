Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DAD5C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:44:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECE32218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:44:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECE32218AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80BD88E0002; Thu, 31 Jan 2019 14:44:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BA6E8E0001; Thu, 31 Jan 2019 14:44:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9818E0002; Thu, 31 Jan 2019 14:44:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 444858E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:44:31 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id r65so3442656iod.12
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:44:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=0o4vhTA4NO2rqrBFyR4se9S2ZEfxlXHdQ1c/HXiw8Y8=;
        b=kTLArljuivkPVN5FUzYvjj98bJ8PPpUKB531NmgiSx7qyl0sDFGv1+3lXHAfI9Dd4q
         hwH3nr+3G3l+lzQeXBhbmdAJZVyIyinfeziIHHj79+NYQei0WUlFlbsO4XWoFdjeE6vP
         R25oRh+YN7Pxc+4OvabSgZ3cAaOPHaAel6/1naPYq2jwDKx2IhY+AZMTzhAz3nNq3/bS
         DUIcS3yn7UVc2/ZsvsTy0Cu0pdwf4wvWpY/PPDAUEfpX32Bae36CjVYeNnLFHOEXESI2
         AB6UwKKYo7hbEpNjQMbokWRLXFnZc4Abx2LIfJdONLsMuXSuwGFJz1Ac5Xf1lb9OPqwi
         fYCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAubvx1RN/KNHdpMeBOzsoPoAeMOQ5+2B9Jr9FET//SVSowHIygJT
	SUjcFBa9DdpamZnt7aBU25Sfb3E4i+LOPRkbj3pcDlLCQf3FYJ2zhQ12kjolQJAEO2R5VcCDrt1
	1ZkskRuL4+igt37sQ4Mq3SZennKJXWD+zCYXvomlyl5IRU6Z4to2cojG9WruPMxT3lw==
X-Received: by 2002:a6b:7e04:: with SMTP id i4mr19860405iom.116.1548963870976;
        Thu, 31 Jan 2019 11:44:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7g19MimdB0Fc2w6csvtKnabvtK0ipHSdPJDNA4ZFmE23JMD7/0YAqgVdCbc6sYGwpF5JLn
X-Received: by 2002:a6b:7e04:: with SMTP id i4mr19860390iom.116.1548963870307;
        Thu, 31 Jan 2019 11:44:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548963870; cv=none;
        d=google.com; s=arc-20160816;
        b=SAo+lu2Rv/lHZMASlXrZ+nAWquC20sz2AMXzvsTeEO71Z3adcohvvnnWoPYqoWXClZ
         ayJ7pb+2tGj5liKse6yUkcNpEW2SemPdEePsbLsYHHcTuWA5FRRsEv/ec85y2ZdVI2h7
         LVbVzJeD/d7g1mbpnYYBW6CDRYSWSqNPwYu0Ir1C2VkVbbzJyqyljSke2PTSEL5XHk+A
         rRIBHAM7qBfDjUtlZfmVfN8Frs0+6CaLSoRW9qrhbR9PLknM/RIH1jEVB5vXX75MrOgD
         0QDmDvZycX5bjICC7tB+OrvTg1PuWbnhWw5/1iW5mtfMPb3w4chtObxDrdti8VouiQDo
         9FkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=0o4vhTA4NO2rqrBFyR4se9S2ZEfxlXHdQ1c/HXiw8Y8=;
        b=EJSLg2zGfvpd6+UVxHMZAclsTEdIYDkrOhmeWthT7z/2aAnOBfTzcAQYvWbpMuK6mo
         QGRE0Ef3Jd5rM/9H8Qynl1eTSWAqNiDMWchVor0V5EZTOaD2OzGFQcxndBsQjABtvmcP
         96T49JimRh6Wv4mPL6XZFP3DysJE/3ylqDbhHCynlI0LMFZj8yV8iH9zrcY8Fs4ngK49
         vKBPK8xkfg0+7kVUoNcb7Ifx03S/XyWHf8q/nlhA43n3L7eQ9xQAleip3V/yOCBV1rY/
         rwlXnI+necfxCF/i+jt4FHnUNkkQFtrLCPiEnXxEiGkmO9t5D6enaf05t+OZNXPcYWOU
         plLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id l63si115178itl.65.2019.01.31.11.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 11:44:30 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gpIG3-0002ds-Dl; Thu, 31 Jan 2019 12:44:20 -0700
To: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
References: <20190130041841.GB30598@mellanox.com>
 <20190130080006.GB29665@lst.de> <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de> <20190131190202.GC7548@mellanox.com>
 <20190131193513.GC16593@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <c82228c8-1879-b9f6-6b07-6867df826d2c@deltatee.com>
Date: Thu, 31 Jan 2019 12:44:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131193513.GC16593@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, jgg@mellanox.com, jglisse@redhat.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-31 12:35 p.m., Jerome Glisse wrote:
> So what is this O_DIRECT thing that keep coming again and again here :)
> What is the use case ? Note that bio will always have valid struct page
> of regular memory as using PCIE BAR for filesystem is crazy (you do not
> have atomic or cache coherence and many CPU instruction have _undefined_
> effect so what ever the userspace would do might do nothing.

The point is to be able to use a BAR as the source of data to write/read
from a file system. So as a simple example, if an NVMe drive had a CMB,
and you could map that CMB to userspace, you could do an O_DIRECT read
to the BAR on one drive and an O_DIRECT write from the BAR on another
drive. Thus you could bypass the upstream port of a switch (and
therefore all CPU resources) altogether.

For the most part nobody would want to put a filesystem on a BAR.
(Though there have been some crazy ideas to put persistent memory behind
a CMB...)

> Now if you want to use BAR address as destination or source of directIO
> then let just update the directIO code to handle this. There is no need
> to go hack every single place in the kernel that might deal with struct
> page or sgl. Just update the place that need to understand this. We can
> even update directIO to work on weird platform. The change to directIO
> will be small, couple hundred line of code at best.

Well if you want to figure out how to remove struct page from the entire
block layer that would help everybody. But until then, it's pretty much
impossible to use the block layer (and therefore O_DIRECT) without
struct page.

Logan

