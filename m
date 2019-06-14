Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8A91C46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A53D8208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:15:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A53D8208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 451458E0003; Fri, 14 Jun 2019 02:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DAF16B000E; Fri, 14 Jun 2019 02:15:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A19C8E0003; Fri, 14 Jun 2019 02:15:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E46226B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:15:10 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v7so633467wrt.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:15:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=A0D49PuwqtHysKuOghIZiOJnH1SDACOZl8Ke1VddQrc=;
        b=pgtxyZzCNC9Pz7VWRV5ILCydANyNQ62n35nAkrNmWauJfesYsWnTrBf+w4ndlB0swC
         7MAO7PrSXhKViiBNc93onkVipc+Hrx7oCTRp0v0gPuEuveYXWb/gbx1sBvU3jnGpNs1c
         r1BYDlROTh7L2iyXCtBKKnM4O+otrROZ+cvkVBaEAryOWd7XYhgXDFU07npbmgzJGdZH
         ZkMDu/glOlLehHXFPamk4hK1IhFMAJ3mGNglE8cu5Orc0KksS4njXHc0z8tYWkhIlzYn
         04mwAwtyVz6Go1gr8RQ0cjRUKJDzGPb9F4IPrpU0amMHQ4bu+KFdQQErYy9RQEbfKfic
         M6HA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUpSmw+mnAxicgPNVLdwt42CMEjQAJdO5W+NE1jJc5G7dmpcId0
	sr+TxRrKLDNnPT2A/FhOf0yz9V9200MW4ND/VOj8+bYhOPiaxhnkIA17PQvs/lAbiRxvKJNR7YN
	9p0X5s9HnP+6Dt/3ZmH4qd/J93a/Uk3NWCNTpPkggN9ZEDoJb5u/z6MFtUnfcoyG7qA==
X-Received: by 2002:a1c:3d41:: with SMTP id k62mr5739674wma.61.1560492910441;
        Thu, 13 Jun 2019 23:15:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6r108FqUENhB6SGTVWl1gqq1TiO7zXdxDUh3P4xRTpCvRX3/OuK/6J8dRfvyceuuYwTJM
X-Received: by 2002:a1c:3d41:: with SMTP id k62mr5739629wma.61.1560492909739;
        Thu, 13 Jun 2019 23:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560492909; cv=none;
        d=google.com; s=arc-20160816;
        b=kqbXmfQqsR0+T+Cu6Hbx0O/NgJOu/XigX2bQUdfb+H5w2ntWO68Gw4aw0WhnoHbskV
         970Mz1sX2CYuW+WPL0CZLxWB9LeOpC7putzjoRdmmnjyGaQhosgPa/563uRtZrjPLptf
         l7MQFqMYybQS3SkZBzAFCXASxOX2sDmpyXqcEBTqzpEsgL81xnIzWyT9R5SyOPfkXxXh
         PCmmLjGYDESncz5mdCP1TQpwztrSkAD+mUMuDnv2oBMM32xaFjqPoi2EE/Wu+Zzx08qL
         sOCOmRJdsonRoUEOFMp09lSbGnj7Hd6yFPPDlWHhoOEHTXNvY2YtYUwC1StADfYJBj1E
         V9CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=A0D49PuwqtHysKuOghIZiOJnH1SDACOZl8Ke1VddQrc=;
        b=QPmY+yLj5MEPKDZ1QcdltS7Rfi9RS0gyJAsIuy12O2s0JXMHBMTbyWysPBCZafnFW6
         kmQEfF3sYWzg7js80yEYT+3IQptL7HPyXuZxjHQPhYVnnEdScudXdL2WItZ9SymLgmT3
         h2X2iOQD0XHPi0TV8ZtIEcXytVLOE9MUir9jjAGkbRxfQY3QKvHxWb5YlbvQ6uvfmN3m
         gmbRUnOhuZcdaO8SO0HD09ejUhx6ObmArUVdjnCJeqhoeu0CToTZQcEJl2wkuN7OqGIb
         x0u30dJyF2iSvkr2UL6jE6ucbFMrpAMhhlbZfmT5dS1XAHYIqmYwiEEhD0SeiGt+QLEH
         +BTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k11si1186232wmi.102.2019.06.13.23.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:15:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 8D0A068B02; Fri, 14 Jun 2019 08:14:42 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:14:42 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190614061442.GD7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com> <20190613204043.GD22062@mellanox.com> <20190613212101.GA27174@lst.de> <20190613231039.GE22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613231039.GE22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:10:45PM +0000, Jason Gunthorpe wrote:
> Okay, NP then, trivial ones are OK to send to Linus..
> 
> If Andrew gets them into -rc5 then I will get rc5 into hmm.git next
> week.

If I interpret Andrews mails from last night correctly he just sent
them to Linus.

