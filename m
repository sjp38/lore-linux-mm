Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8338EC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41FCA20659
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:50:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ndoC/wHw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41FCA20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CECAB6B0007; Wed, 24 Jul 2019 15:50:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9CFB6B000A; Wed, 24 Jul 2019 15:50:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8B606B000C; Wed, 24 Jul 2019 15:50:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 933286B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:50:12 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id t18so36462456ybp.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:50:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=o1DvH7PppcliFCYzQ16HV/ZAX4qVLsHxUniBpxQa/jY=;
        b=iz097MYTx51lR8IBxMYuzp5B3Rlb9jR8LGLZLdiB/DVks5wl/qmV0dSr1FKSMkBJP4
         2d2WFb7WP3YJnaz44iQ6Vl8X5albt/pDo/jH+/7QTihhQWh3ogZBLZTKfqXqTLija7zi
         mJz3ldM8YO5SUuu3mtryY2WyMvQ9+SHVOaXG0Ma4cBLXLKhHADu6oN9EMqoWglsZyHjj
         qlCAnDl5nw+KrClfbKlhEr7uEYiZMLf5dRglIxCPivN8JQ00QkrS3NyZ71eYveSvz6WO
         izStzDLrsYRmnUIbnMtYHWAMMIutaydVRV5x67wJKwsIin4ain8pNAW+jKzsPEL18Ni3
         wVLQ==
X-Gm-Message-State: APjAAAXM5WwD4T1Eqm3RqsQphGNUT/4G8yIVU/Bmva2MSSdeRLI3gp7H
	bfvSyxvmLeZdwcaBawBGoNYZ+4gedUJCLa7UCXOHz06gEu/HtB0AyDQO4dAvjRKefDBMLo8jCT2
	ZSMWz4jIDshBXj8ZOswwXQH6rld+9kZIoHfmYKOXGpMocZC4bKTHwnsiHdvy52dvSEA==
X-Received: by 2002:a81:3457:: with SMTP id b84mr44252524ywa.313.1563997812342;
        Wed, 24 Jul 2019 12:50:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdMYtT0z8sW95KGr8HHW+gwCmgKQfn2X+fm2u6LXzMpq5yNXqw4mc42D6PZAvwrRaYIny7
X-Received: by 2002:a81:3457:: with SMTP id b84mr44252486ywa.313.1563997811643;
        Wed, 24 Jul 2019 12:50:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563997811; cv=none;
        d=google.com; s=arc-20160816;
        b=m1NgWBdsipFHkVGU74U5i+25l6XlgQy89dTN3VqijYioz4joFcZhwZ4nEiYJwXaMYc
         3ttdR3lKtRGgyprsGL54RRmYvkJaPWGrrODEELklBewLfOz+fXCrl+dJhpTgav2pUKlH
         /KcTIm19r3NZrL5H0nrteL9gRfv99fNetBcdcdhoG9sedU4Y5q1fyLmgNDCUO2P4kY+1
         qqQafBZJ889+R1t70himhtMZyF26kSokjCvzlFKk077oQXqVBbJigLcH/OuvFb2cNWSb
         TV52vK8CVzlnUonvNmmPsUOJN/TlfGGAS9WOl8TR6S7mXkNyi1DOp+o9VfvHfcruUQtw
         NCCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=o1DvH7PppcliFCYzQ16HV/ZAX4qVLsHxUniBpxQa/jY=;
        b=1GOuN3HKWTBhpOOa/XVYkZwt+V7hvbgZkqZpaY0mmS9SzGrm7jjNICwd+TwdN4sdps
         R9yrzCrLB/toYRI3qqePGEsP7xCCUeQiA6/PRffgZXmZFUi/y3N6OaBPIGEvNTBpQ23O
         FsH5E8N9NNvn85Ydm3KxktBCV9oXDyxRZhyHBdyu5HHLzs5spSHBbEdxQTuJJAtdFkX9
         P2upeGIhEsgc0XS4txCYq0/ozX7d/rf/tVx2W+ooPaE+rLJm1vf942/7coxkLyTmavLp
         wh9/ZKD2hie7D7GjSa3/5Fp1HwWwj1SjB5rrGF4NtjTmXPUVAx4yRSLgHn1rsibeEQu8
         Q1Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="ndoC/wHw";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id g5si3014379ybc.327.2019.07.24.12.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 12:50:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="ndoC/wHw";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d38b6730000>; Wed, 24 Jul 2019 12:50:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 24 Jul 2019 12:50:10 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 24 Jul 2019 12:50:10 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 24 Jul
 2019 19:50:10 +0000
Subject: Re: [PATCH 2/2] mm/hmm: make full use of walk_page_range()
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>
References: <20190723233016.26403-1-rcampbell@nvidia.com>
 <20190723233016.26403-3-rcampbell@nvidia.com> <20190724065146.GA2061@lst.de>
 <20190724115338.GA30264@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <098df586-0713-1aaa-e546-5dc39ec30341@nvidia.com>
Date: Wed, 24 Jul 2019 12:50:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190724115338.GA30264@mellanox.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563997811; bh=o1DvH7PppcliFCYzQ16HV/ZAX4qVLsHxUniBpxQa/jY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ndoC/wHwyfVcpAyH7LNSBQ5MX2jPUvphaKjtuXWIn8VrEDengx2WT/DuMJm+WRXZ3
	 PiR4+0PG/Pz7ee56d8OyGQsZxJrZ5A2V7MZNvqZFis7ml6ohw5wa2st0Jos9Y5kzNg
	 g7l59/dvj6EoVy3z/aqFWJkaHBONxVgSCLNiVzM1kbOQVnxb90IhOdJwRwq7tIF3Nz
	 VTUbGNfNBtyYlE2MTJQqJo5UKSiGbulBDq2IqNDlhVCGvx3Zaw1r9V4fRXoJzXuuX4
	 XQ0Dj9tUsa6iuS/8rbbUIOWUSVWpCP9NT4pEBjYNLvTsPg7WnHGyQ1yAE8U20LnIxq
	 qc3g1j1fB5DSg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 4:53 AM, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 08:51:46AM +0200, Christoph Hellwig wrote:
>> On Tue, Jul 23, 2019 at 04:30:16PM -0700, Ralph Campbell wrote:
>>> hmm_range_snapshot() and hmm_range_fault() both call find_vma() and
>>> walk_page_range() in a loop. This is unnecessary duplication since
>>> walk_page_range() calls find_vma() in a loop already.
>>> Simplify hmm_range_snapshot() and hmm_range_fault() by defining a
>>> walk_test() callback function to filter unhandled vmas.
>>
>> I like the approach a lot!
>>
>> But we really need to sort out the duplication between hmm_range_fault
>> and hmm_range_snapshot first, as they are basically the same code.  I
>> have patches here:
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/a34ccd30ee8a8a3111d9e91711c12901ed7dea74
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/81f442ebac7170815af7770a1efa9c4ab662137e
> 
> Yeah, that is a straightforward improvement, maybe Ralph should grab
> these two as part of his series?

Sure, no problem.
I'll add them in v2 when I fix the other issues in the series.

>> That being said we don't really have any users for the snapshot mode
>> or non-blocking faults, and I don't see any in the immediate pipeline
>> either.
> 
> If this code was production ready I'd use it in ODP right away.
> 
> When we first create a ODP MR we'd want to snapshot to pre-load the
> NIC tables with something other than page fault, but not fault
> anything.
> 
> This would be a big performance improvement for ODP.
> 
> Jason
> 

