Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53A09C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:54:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 047342084B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:54:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 047342084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 742246B0005; Mon, 17 Jun 2019 15:54:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CBB58E0004; Mon, 17 Jun 2019 15:54:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 594998E0001; Mon, 17 Jun 2019 15:54:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2013C6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:54:35 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id g2so5119182wrq.19
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:54:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8qAXoaha6nS5Bg2dd917McMLU2jYEISNKGxtfLIae3I=;
        b=cUi7g3S/dV04FyAyjJ+fIObESnMb1TvykkmwwaZOkYZTbE6tETqM/s6XY0EZrnYBvT
         tX/qMKZ2Y/I9Bq/TWuqI90rsP850Na7x7B284HqpYDHgj9to+wr0Kt2OlTSCeFlaBPv4
         YWRfNM7czAxuBASo+rXCriM6V4aEcrbMytIJcpsGUbIxfafLQbEmko7QS3rU8veam5ry
         N3MAC2nEE/SfJhKLfFj2FuylF46RfssFSeWaB9XpnBCKfnN+Lhmna+BpJPzypb4QrJ2U
         YhzVPuNdPt8gNqPzASzj/jilt/WhRGdp08dRdmNDyM/aEW9O5CjbaSFw4BqWZ7IQ/dh5
         vgfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV1/L4kdHk4bl965BFBT1YrveW1bRJqiyb5AW0mWDSi1L773hlu
	59YOKM/sqG6BNKdbq0EwQOMQrL8K9j0aocdM+c+M10pjazBnrMEN49QlArhy4lVoi5Hwfm4JfH8
	iRQoPTL6jqDFHOOWXf4d4MqitiV7LueMcZb8Jvmtcv27LeYlnP3RJlmVByseMKf9n+w==
X-Received: by 2002:a5d:53c2:: with SMTP id a2mr25769114wrw.8.1560801274576;
        Mon, 17 Jun 2019 12:54:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVSbL39oZlSsfhetttDtWu4UoTv8Ln2+JQL+U3wBzIKiZyd/sasGhDYznKuC3sd0hsJ8rT
X-Received: by 2002:a5d:53c2:: with SMTP id a2mr25769094wrw.8.1560801273870;
        Mon, 17 Jun 2019 12:54:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560801273; cv=none;
        d=google.com; s=arc-20160816;
        b=CVoITvCMjDwmhiBg9tdEJpqLaohM8bQPppS967st/0DhuLSICuN+t+UQ0mHj42s8QB
         nw+bzW/qOrapt9Ii2X1prKchCUge0F+bhuG0PJH+JGWdFN2NW+SssqhoLqPL+595r/N4
         0oyOGfy3ouhyJKbLPTN9C2avtZNDMMC4DAZ0fKa9avmkof7lUpMsv4r+pXI1A+gOiS/l
         9bHXSx5NIy7Txd0ETNLOLT1gACKPPSgtSlIFQTCFmg/vH5m6BKrmyjP9g3DjGGtm3DjN
         wLPeLV9dxvNy3+XTvhkWJ3Hqrkweq7eHgGn6kAkuKY4vuxYQ2HmzUbVX0wRK2BAJMfRU
         oWdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8qAXoaha6nS5Bg2dd917McMLU2jYEISNKGxtfLIae3I=;
        b=0SMLTVuBPh0rcwvI4ZOYzjLauHNhdeav4BenXOGmxIskxDPEQr5T/sj0EJXz+4eqiC
         gtsrS+BG0z+9EhbSrSLS67ZOzMuSocjxDNriqjAW6CsgCwxWvMgKL0DzNPDObwh05Smu
         TDN5oErWA4TRERWmaam5NPtYZYiDe8qvjwrZf77FXnp6d4FLFL9iANRK1BQIXYehd2Po
         uCUzQ08P7oa9+QixOCJ/v9v+60RCA5bbFmThNN9YLNNe/37Qw0ACoYU9A1fhf+yOX7K+
         4M6/PlPSql64/no5Pb7JvInigghoa2TIbkqrYE6UY31ag4E06ocV3+eju+97nnmrNLp/
         WpGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m14si2640283wrs.257.2019.06.17.12.54.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 12:54:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 306A367358; Mon, 17 Jun 2019 21:54:05 +0200 (CEST)
Date: Mon, 17 Jun 2019 21:54:04 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/25] memremap: validate the pagemap type passed to
 devm_memremap_pages
Message-ID: <20190617195404.GA20275@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-8-hch@lst.de> <CAPcyv4hbGfOawfafqQ-L1CMr6OMFGmnDtdgLTXrgQuPxYNHA2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hbGfOawfafqQ-L1CMr6OMFGmnDtdgLTXrgQuPxYNHA2w@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 12:02:09PM -0700, Dan Williams wrote:
> Need a lead in patch that introduces MEMORY_DEVICE_DEVDAX, otherwise:

Or maybe a MEMORY_DEVICE_DEFAULT = 0 shared by fsdax and p2pdma?

