Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A4BCC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5F4D21473
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 18:10:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Ok4pi/aW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5F4D21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B8336B0003; Mon, 15 Jul 2019 14:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 566E06B0005; Mon, 15 Jul 2019 14:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42EE26B0006; Mon, 15 Jul 2019 14:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 228836B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:10:25 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b75so14174049ywh.8
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 11:10:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=6wwgTZKS6jiJbEQByxUeIS9VuTtgekUJNWGw3cfIDgA=;
        b=qkSxltzGtD4s1SbKtnYwFTfo7M5/bDzNeP3ttXEk7l9wFW1cr/YrjH7sU3ftWN66/a
         9IuAlEdJFjU7H22W/DDyakAxT41/cD8Byd71osjdzxSeiJEJg4kdn0kbm8v11wByf1CD
         0SaRQipg/R3S7LT9S8zDW4qBwpb7F5/RlTm+uToy/7v70kiNb+co8WSyOoK+NlDxgbPw
         R5e9i4e+8wIh0Fb301mOSQI5N2kk1PSc4QuCHsSTUxvw1cKtLi/diErLeO7pIgolqHaI
         jL0gGqvG+Mf8IvSvq4tIRRgrxme5C8eGkxP3OF2zDIIycsEr6CN73Qg9ENwQO3c7X2xp
         RVFA==
X-Gm-Message-State: APjAAAWNTCHgl26USyO3LFxmmTPaSU35kht1/CvdDq/o8QB+ahUQcMKM
	VkWA37QKzwgc+bVilL6AcFaFH0CJWH4GdDTTiCONpB1HbZSFy+lh2ACAHHKhrYE7cH/eysrrn84
	5EIUcx39w8SAO8evHr5YWf+Yio/LHwOBuIffMCq4e7U2DhI87DxAS6luNaeExwv/eqQ==
X-Received: by 2002:a25:6402:: with SMTP id y2mr6109782ybb.14.1563214224810;
        Mon, 15 Jul 2019 11:10:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQsn8MOCBczFW7bDg0Ws/gegK5Tssho8Ud4MzRym2kqDnbt0Dhl6ysRExwE72/nYbBzxZ8
X-Received: by 2002:a25:6402:: with SMTP id y2mr6109742ybb.14.1563214224106;
        Mon, 15 Jul 2019 11:10:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563214224; cv=none;
        d=google.com; s=arc-20160816;
        b=gyM5aS10uQOCEYj1iX+Y3CuFXe3XjD57+my8QFKvD2hEJYJOr5zeQbRCbCb9JCHbQD
         ox1Cr2S9pZgnNeJTg8tno7BelXxgtZ5rSAzQFkyysEOMbOVlzrZsBEr9gA7C2iPbG5lw
         bOYXzfi84vF3Omc+Y+KQkudhqTrUC2jJH+CStvNrUX2Jyub4SBTrWmPKxETjbbBkBAJB
         8+MibPgSr1oDEkgxgbR30GeE7UJc02Sn9i9DUNFNL3ZmSfvUa6QyVqoZsnJrtEUCzyoU
         wU19FdomdSfeJ++3oXJswWmKMDl0zkj+j/5UjKr75UUa4IbmT80gX+QoVBl1QukBxsOH
         zg1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=6wwgTZKS6jiJbEQByxUeIS9VuTtgekUJNWGw3cfIDgA=;
        b=aqTvFXI6WjhvUSe37dZcNrfebHkqiOGy4IUrBgF0riyzKyC04CaXfg4GaA3ZD9XZRV
         TJpXolH+P6UY6l2/t0YkEUc7qiemRGT+rI5aKOf5dxJyNitYzKnf2A0DT0XdDce+kRuP
         w61wciSS3LG+HnCiseKm7j60CzE/v3/NvrLhlosodHwsXME9GDWWfOMD/2sFGk7T5Ls/
         B3omm1ERCedPzzlBkM/zJIxoiU2Lk0fADip+RUDljKwvt2wjpfbm5jif4PQSSUlMhsLT
         /E7MejDTkjdyxPGGwiEuXicKUifasYLgehPW7LbnVBxbrrx6cgcW4TK/t8+oRD3t6L6M
         MtOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Ok4pi/aW";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u20si7818239ywh.290.2019.07.15.11.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 11:10:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Ok4pi/aW";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2cc18d0000>; Mon, 15 Jul 2019 11:10:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 11:10:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 15 Jul 2019 11:10:22 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 15 Jul
 2019 18:10:21 +0000
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
To: Bharath Vedartham <linux.bhar@gmail.com>
CC: <akpm@linux-foundation.org>, <ira.weiny@intel.com>, Mauro Carvalho Chehab
	<mchehab@kernel.org>, Dimitri Sivanich <sivanich@sgi.com>, Arnd Bergmann
	<arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alex
 Williamson <alex.williamson@redhat.com>, Cornelia Huck <cohuck@redhat.com>,
	Jens Axboe <axboe@kernel.dk>, Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, Magnus Karlsson
	<magnus.karlsson@intel.com>, "David S. Miller" <davem@davemloft.net>, Alexei
 Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jakub
 Kicinski <jakub.kicinski@netronome.com>, Jesper Dangaard Brouer
	<hawk@kernel.org>, John Fastabend <john.fastabend@gmail.com>, Enrico Weigelt
	<info@metux.net>, Thomas Gleixner <tglx@linutronix.de>, Alexios Zavras
	<alexios.zavras@intel.com>, Dan Carpenter <dan.carpenter@oracle.com>, Max
 Filippov <jcmvbkbc@gmail.com>, Matt Sickler <Matt.Sickler@daktronics.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Keith Busch
	<keith.busch@intel.com>, YueHaibing <yuehaibing@huawei.com>,
	<linux-media@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devel@driverdev.osuosl.org>, <kvm@vger.kernel.org>,
	<linux-block@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, <netdev@vger.kernel.org>, <bpf@vger.kernel.org>,
	<xdp-newbies@vger.kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
 <deea584f-2da2-8e1f-5a07-e97bf32c63bb@nvidia.com>
 <20190715065654.GA3716@bharath12345-Inspiron-5559>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1aeb21d9-6dc6-c7d2-58b6-279b1dfc523b@nvidia.com>
Date: Mon, 15 Jul 2019 11:10:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190715065654.GA3716@bharath12345-Inspiron-5559>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563214222; bh=6wwgTZKS6jiJbEQByxUeIS9VuTtgekUJNWGw3cfIDgA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Ok4pi/aW8U3yjBXqydhqyft24fqK5kLZb9vqN2v2ZscUA+LO0TUEntZeQFXwWM9mI
	 LSrTQjPbgBURTVuTHsTSQsCgjCENvKuaFyzKLw2XoaWgUj+WvDafd8mw0VAnM6FcQ+
	 +2MQLOvD9ImnAuT4gp9Ms08kG21euR6h30TCsuEWJ6lWOGD9RwjSXqHq846/IAB2oQ
	 2xzmb3rUlMkYnUIwMFCjvBWCfVAdsKWykA4pdAEfJW4vFSKPaT2m4A9YAlaep+ltqs
	 dnlEdJPni78MkMkdBjFMKskTkkSUDUGV5x/f03KwhrKwKXSc4NX56A3yXabbvoTqDL
	 9Z2efhUFKhX1Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/14/19 11:56 PM, Bharath Vedartham wrote:
> On Sun, Jul 14, 2019 at 04:33:42PM -0700, John Hubbard wrote:
>> On 7/14/19 12:08 PM, Bharath Vedartham wrote:
[...]
>> 1. Pull down https://github.com/johnhubbard/linux/commits/gup_dma_core
>> and find missing conversions: look for any additional missing 
>> get_user_pages/put_page conversions. You've already found a couple missing 
>> ones. I haven't re-run a search in a long time, so there's probably even more.
>> 	a) And find more, after I rebase to 5.3-rc1: people probably are adding
>> 	get_user_pages() calls as we speak. :)
> Shouldn't this be documented then? I don't see any docs for using
> put_user_page*() in v5.2.1 in the memory management API section?

Yes, it needs documentation. My first try (which is still in the above git
repo) was reviewed and found badly wanting, so I'm going to rewrite it. Meanwhile,
I agree that an interim note would be helpful, let me put something together.

[...]
>>     https://github.com/johnhubbard/linux/commits/gup_dma_core
>>
>>     a) gets rebased often, and
>>
>>     b) has a bunch of commits (iov_iter and related) that conflict
>>        with the latest linux.git,
>>
>>     c) has some bugs in the bio area, that I'm fixing, so I don't trust
>>        that's it's safely runnable, for a few more days.
> I assume your repo contains only work related to fixing gup issues and
> not the main repo for gup development? i.e where gup changes are merged?

Correct, this is just a private tree, not a maintainer tree. But I'll try to
keep the gup_dma_core branch something that is usable by others, during the
transition over to put_user_page(), because the page-tracking patches are the
main way to test any put_user_page() conversions.

As Ira said, we're using linux-mm as the real (maintainer) tree.


thanks,
-- 
John Hubbard
NVIDIA

