Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98349C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59FE021721
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="THHxjtsg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59FE021721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECCAE6B0003; Mon, 15 Jul 2019 18:04:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7BA06B0006; Mon, 15 Jul 2019 18:04:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6B136B0007; Mon, 15 Jul 2019 18:04:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B88DE6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:04:13 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b188so14628654ywb.10
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:04:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=7F+lrioE5/qbngjXwfnCWvzn3KWHU4WQV3R2Uk1MWm8=;
        b=TZEgQagOEfLDIN/FGto4q1Ja3iLV8bjIh9GIM+yKBdJACGrlvLiYXFFEAUhJvvzzrK
         8kDiMAhE0cY0AndI99qzSYPuCN8IxanD+1eNKHjTySflu5V5RZm3zWybX2taVOhZqdmO
         nY3fTD0asF5asrphcx8XKa0JRiJybxrIbIVlRw/Bq2nrSk/t5BCkMf0GHiZf3JsA4r6a
         rSPgVPIfpsHQ3mNYbDPnFbMXAFwmZJubLlv4m0QPyQ68MbGrdrwOc4BsrTtFSTixXnYD
         nq2W/EZ2/7FpqHQVE0lDLHpNU9G6NHupiiOrUGghEtLRs5/Wcleb/Dfilu0MLJmIZhq9
         /RvQ==
X-Gm-Message-State: APjAAAVuNM8p9xRjXjWREbkO8F1jC0oIgRvNWhQ+TqWvtvG/dlTMw0JL
	VxaqSk9Rocii40vpbCHlN0XN1U4zcOdcugkQQiuPNN//Xg5/b0g4XHAegoImroRKPRB5b713vAD
	TebF2+bybSDcBoetkTcywdpm46RT2VPYhgek3VpL3F+SoMXqAH9XfuujW5Ixn6gKUJg==
X-Received: by 2002:a25:5d0f:: with SMTP id r15mr17407934ybb.59.1563228253507;
        Mon, 15 Jul 2019 15:04:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2LEwdYEWBoP9hX+tkZgaw72KfG/jWThm4jDT10yZf5hW+nhTmMOmf7AaIJyL1O8URhreM
X-Received: by 2002:a25:5d0f:: with SMTP id r15mr17407910ybb.59.1563228253016;
        Mon, 15 Jul 2019 15:04:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563228253; cv=none;
        d=google.com; s=arc-20160816;
        b=gkheDrM3iz0efplcnnR1JNobPi38LDf0lXwWwgNzL8i8jBTK/dNuVunQ8MkAcbVdej
         xOiNpXuQARq0JCO1hY42W/0F6033rnOeKSaQAq6R6oaZ19fdWIhHIjHwJrD16QYCju6M
         OFM3hNp3wwYGHkG2bdNS93Y2wz2wpDiAzJgpsVyPDs/xHLtJqgSJ9kmX//ZNGuzKnk33
         MSsbg77xQz//Sd+kszxWcEn/ET1MQvwkrRhPcQeJiXXM5hCYOeiDPQj5R8itsWEGfzHm
         VafnQ3WumzqAR+OVMtcb63jhiGnjHLsNLYrJ+oNxKfDqLenS2kx+g40eu4kPcNncfcJ8
         XRuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=7F+lrioE5/qbngjXwfnCWvzn3KWHU4WQV3R2Uk1MWm8=;
        b=NDjrS0Rgwe8sXHwSMOmyzIsKXXKq1kEqeQLvtHQcrEBtatxOfD756BE53zcmBVgx7o
         4+xrwTxlAxPrN5v/Bp02zsme0xvuSOtZdnXt9OLM2nhK/3SYRrXc0fvIIyYe8jUzh6d5
         rki1oLGpwd0kw1zuguj4bjYc7PR8/ePmZz/m29gHCA5dLQfIzeya1ZzmH+xYcpeIGVc8
         S7BNyER7O1WVBApjrOJkQNyomaBf6r4KIO8IjR32ZNszva6clbbKDj5diMQ4//sQh6Vf
         YGDhI2pDqgFvV71tsEvFUKmmvHLYG0oEokha0zJCGbCXkwWOvmlF2U77W1DxWFC2P+9Y
         AfKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=THHxjtsg;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 129si1397566ybb.144.2019.07.15.15.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 15:04:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=THHxjtsg;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2cf85a0000>; Mon, 15 Jul 2019 15:04:10 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 15 Jul 2019 15:04:12 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 15 Jul 2019 15:04:12 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 15 Jul
 2019 22:04:11 +0000
Subject: Re: [PATCH] staging: kpc2000: Convert put_page() to put_user_page*()
From: John Hubbard <jhubbard@nvidia.com>
To: Matt Sickler <Matt.Sickler@daktronics.com>, Bharath Vedartham
	<linux.bhar@gmail.com>, "ira.weiny@intel.com" <ira.weiny@intel.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jglisse@redhat.com" <jglisse@redhat.com>
CC: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
References: <20190715195248.GA22495@bharath12345-Inspiron-5559>
 <2604fcd1-4829-d77e-9f7c-d4b731782ff9@nvidia.com>
 <SN6PR02MB4016687B605E3D97D699956EEECF0@SN6PR02MB4016.namprd02.prod.outlook.com>
 <82441723-f30e-5811-ab1c-dd9a4993d7df@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <2278975b-6ea5-5417-eb0c-9d7debdf68ce@nvidia.com>
Date: Mon, 15 Jul 2019 15:04:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <82441723-f30e-5811-ab1c-dd9a4993d7df@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563228250; bh=7F+lrioE5/qbngjXwfnCWvzn3KWHU4WQV3R2Uk1MWm8=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=THHxjtsgf8LosY3HKog1RQ/BDV+9F/bTT64YX2I6T2AHWxoBAi0RLmklmhwM3ewuk
	 OX2zlNOoGNrmox7hKvIBOIFmnJslo5CUp7RmxvNgFJCavNuCywtZwx9qel9OqBItAE
	 P+rc1zZKXVbY8PZlPHkgV6xctZUI4ye2lqS+p5KgZRSDRw5AD1lZR4UfhS+ZKvl/jS
	 hMQKOx3zzmXt5XuNUXh7mBFZcc4Z8kxcr7xPK49Hx+ate4QIV3mr/eky3l1SzDrtKS
	 KSOMqk9cAXNlVUBhj/Q6LAOAOQVrgKk0xs5pROzdtxNCjzIBEvMLG7MeGOuyRaGQVd
	 RMPff+4MqyInQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/15/19 3:01 PM, John Hubbard wrote:
> On 7/15/19 2:47 PM, Matt Sickler wrote:
...
> I agree: the PageReserved check looks unnecessary here, from my outside-the-kpc_2000-team
> perspective, anyway. Assuming that your analysis above is correct, you could collapse that
> whole think into just:
> 
> @@ -211,17 +209,8 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
>         BUG_ON(acd->ldev == NULL);
>         BUG_ON(acd->ldev->pldev == NULL);
>  
> -       for (i = 0 ; i < acd->page_count ; i++) {
> -               if (!PageReserved(acd->user_pages[i])) {
> -                       set_page_dirty(acd->user_pages[i]);
> -               }
> -       }
> -
>         dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
> -
> -       for (i = 0 ; i < acd->page_count ; i++) {
> -               put_page(acd->user_pages[i]);
> -       }
> +       put_user_pages_dirty(&acd->user_pages[i], acd->page_count);

Ahem, I typed too quickly. :) Please make that:

    put_user_pages_dirty(acd->user_pages, acd->page_count);

thanks,
-- 
John Hubbard
NVIDIA

