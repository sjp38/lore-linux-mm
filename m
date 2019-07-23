Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFE33C76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 01:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABD7E21955
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 01:11:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="WU2eFWp8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABD7E21955
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E06B6B0007; Mon, 22 Jul 2019 21:11:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26A446B0008; Mon, 22 Jul 2019 21:11:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1097C8E0001; Mon, 22 Jul 2019 21:11:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF3246B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 21:11:06 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id p20so31694787yba.17
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:11:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=kscjS9D5ks2yd1t6YQtphh4j4hyaf8nJbzsPpcUAaRc=;
        b=lh3VtDgXvsJPE7y39gAIX9r4m/4PlNI1/lhMewNevd4ql/Y88M4A6HU6oWsMpUeCCE
         gfq0eTyKeGPsz/93R4kVTgv7e+rkCPpE1tmI1zN4Yqt1y5fzxqvyqVUtgBSnLIc8T5d+
         LhLaCeuNtck2Gyw7biD49bcyDUy930n4UQPIShceEo06yKu7aSQljL4jl13yAny4N7oP
         NTtif119I+ASn0RODa3RTc5mKehPltvExovO5Rl+f8QGvi1q5FIoIyS310AzoIJpdjm9
         j7oNcwhM2Y+2EABZ5aWEZhfr4kPIKLKRx3eQh2OIwyp+x+XLK35GJh9SMEylEyUYxUPi
         NGRg==
X-Gm-Message-State: APjAAAW6XGoVhi16XwGXh/c94MeRfRPZ8wTjJ0mg7p1IMLOA29OZx4zK
	MEhUMyi3xqmOCiKZaPqJxNBWbbMkadgV/96nX+x93ncZoUG4o3hGf/EvvBkcDJrRf2CxMrhq/50
	zk2upDOmPuKfLrIlocsTgIRu5wUEo+0bSr6UgKiu6G4VVAyfV2B3WHA7vIqOfxrmtaw==
X-Received: by 2002:a81:2355:: with SMTP id j82mr42429512ywj.167.1563844266593;
        Mon, 22 Jul 2019 18:11:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRpmynRk9ugizKN5FW1PjpBc9zgky01h7dVcyCSS5FjXyTsLp1eFHShmSnuc4vjCE7owZ6
X-Received: by 2002:a81:2355:: with SMTP id j82mr42429487ywj.167.1563844265997;
        Mon, 22 Jul 2019 18:11:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563844265; cv=none;
        d=google.com; s=arc-20160816;
        b=dXak/1Od31HTr79ODOv768Gs3hCl04fqIflW3hMyIXFIuyR3hqVnm4vnIBsFaE/58g
         holXRtrjLKpCWqnYCop/F5+E6EIPbG/3VHR+AgEx6PEfJNYESVbhNmyAlaH9VDBgb28D
         /mt972Zg8f6MYR9SAtLoK81MFdH+A0Gtt0BJwUt5bSXGjTG//M8zCF9RTARyrV3U0CSk
         kU7FJQ437yV36trC3G+mOH5OjpOynzLy+iPAmopNqQ5Vr5PSVkWjWFCzMdR6mXld3PYD
         J12ukZ7v/GZFsnFCGNq1/XkuCCD6rwTj0a6KhmcaVi4R9cL7YNTIpMSSsSDlL2r3Wglk
         3laQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=kscjS9D5ks2yd1t6YQtphh4j4hyaf8nJbzsPpcUAaRc=;
        b=ChBV4l7MyDi+NGgwwDr5ry8jKPHt9LLdD4MfNSuktPHLfCNM7+GfV++YC+ELTXXzn8
         GhT9cZDFsyi4A7fxTFNkBhaob78Ru9cBmrXDxVA07m0s0WJpdJzLwt86SHp3Zw5l16On
         KEuSb6B0jhPgZTB7s2t/6seApH6tmahozWsZNpJMDWcOHurEfqti9i3f0Cajf3vZw+ev
         7UIiSHkUQ/bkm25mnlbNIbAThzd8QpcRGrSUwZlU8G9HsPo1qfVhpsFvpi14t358WCMM
         RRJwBtTNv328EbKW9FwLYb3GG+1yxUpejEhwQpjP6DgnXYroXGvSuSHGfJB/b7QXbrlL
         X4xw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WU2eFWp8;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id s127si2418779ybc.254.2019.07.22.18.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 18:11:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WU2eFWp8;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d365ea90001>; Mon, 22 Jul 2019 18:11:05 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 22 Jul 2019 18:11:05 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 22 Jul 2019 18:11:05 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 01:11:04 +0000
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: <linux-mm@kvack.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>
References: <20190722094426.18563-1-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <7e1f33d4-4d3b-7927-38d1-b98b22ed4d78@nvidia.com>
Date: Mon, 22 Jul 2019 18:11:04 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190722094426.18563-1-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563844265; bh=kscjS9D5ks2yd1t6YQtphh4j4hyaf8nJbzsPpcUAaRc=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=WU2eFWp8VxG3UTGHueSY5tPs9QU3Wq1Nhlz7guFIcl97+4qhR5QlTL95yfCf6KxaI
	 zvG+wvbWkdeVrOlsvcu9YwOHFT+WhYBVxi0yTHTWJWeWbv6TU9qyGLhWAtsIkPPaUh
	 awR6kqifuiaeIQAF50GonIw3mX+YkzyT++89VwOOVQISWEr4pkMmJrnIHmsaUNvtoH
	 2zoQh8J+5RREkogqGWoKWu0eSqZGrb3UTIfWNNhJ6ZMui5fwrfv3d5fUl6WLQXvfdN
	 gouWM4XU2Cp0eWulPvR6IKD/vQGHTorAA3LK19GR8gPJFxIuXdMCgf+trx2P/b7oT/
	 xtykT8kHaBN4Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/22/19 2:44 AM, Christoph Hellwig wrote:
> Hi J=C3=A9r=C3=B4me, Ben and Jason,
>=20
> below is a series against the hmm tree which fixes up the mmap_sem
> locking in nouveau and while at it also removes leftover legacy HMM APIs
> only used by nouveau.
>=20
> The first 4 patches are a bug fix for nouveau, which I suspect should
> go into this merge window even if the code is marked as staging, just
> to avoid people copying the breakage.
>=20
> Changes since v1:
>   - don't return the valid state from hmm_range_unregister
>   - additional nouveau cleanups
>=20

I ran some OpenCL tests from Jerome with nouveau and this series,
5.3.0-rc1, and my two HMM fixes:
("mm/hmm: fix ZONE_DEVICE anon page mapping reuse")
("mm/hmm: Fix bad subpage pointer in try_to_unmap_one")

You can add for the series:
Tested-by: Ralph Campbell <rcampbell@nvidia.com>

