Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1592C282DA
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 16:49:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4397E21773
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 16:49:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="MPBZskVj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4397E21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A16CF8E0028; Sun,  3 Feb 2019 11:49:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ED7C8E001C; Sun,  3 Feb 2019 11:49:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 903798E0028; Sun,  3 Feb 2019 11:49:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 396028E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 11:49:10 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w4so3895794wrt.21
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 08:49:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=B6q2ei1aHR9lzl0hOvwoWBIVmVDE9nFvmFewblIeLYs=;
        b=JlMVBviIcvztqzICWsAwq7xrIBpVynICkvMnxO31mHdn1CAd5Qy48oqYmlR2CHXzRW
         ah9r/o4w4zePeEUexo/RbUcJMo5Tl13RZOMVEh1AprggDtHJWI3J3kSDwOisjDqOUQU0
         M/vJ147ldnTadb+2pN7R37wxf37kI73kDaLiAV6QBMjZ5J7OQHnS7YOGJgLFtL09w8y6
         oQLqxPToXfQLv5Cfa9wl7MXn5oywusJAVxqooLfhy2rRDyn+NGmX3tcdBLmJhH/mivjY
         LnlTHhX+q4Ps4zt0xtCNlAP1rCMBDqQKtWnKsLxESGI+U4BATHUE0MBJ4YdgdHqmHXzq
         aCkA==
X-Gm-Message-State: AHQUAuYmD2rtxA2xD4A1X2Xfkr+wSm6cAXTZtGuJ0FVOeHpkDdHkWTOa
	0CaX6QwhgjF3C2mAE+a17O0fEoF0KEZqsQnIA2JWsi/fUZql5lVdYktKaADbSFKwgOkPdVNZbLw
	YxTf2icXFK2mwFWc33w1A/eD9lMMsw4fQNiQdNbm0oDbpFTQiOW42UUQe4eWTth0BvA==
X-Received: by 2002:a5d:5004:: with SMTP id e4mr2583389wrt.59.1549212549573;
        Sun, 03 Feb 2019 08:49:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZWrkFm7/K//Of7FyTNDU27HYX+Y8372klp2znd7sz/rIjpu8OyWVa1DNJu62pxWMkWK70G
X-Received: by 2002:a5d:5004:: with SMTP id e4mr2583358wrt.59.1549212548655;
        Sun, 03 Feb 2019 08:49:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549212548; cv=none;
        d=google.com; s=arc-20160816;
        b=SWNcl47Yq8q1qqEcedBMLNiJ+B/SSeVpRknb2Fw/p4NP9FU67A5aBygV/ZQOWnTqEd
         0G8VnuTwUOyN+qh15R2O1L0vdwHCSgZP1cp++szEQisf35CBJETvpGC9ezaX7D24O++s
         Kx+OibKWBEQqAMtw8FbwnNAMMWoU3EGGZFIkZmIIZCtDA0yN+7xFS/rc4gM4G3tGRLYe
         F1xcbCOe74GUmSoIpmLRp1VahzhvUEssOOYebhv5/6uU6NJVaYWIS+PUlhGajQufLWK1
         yh0Owt/DNgPfb7Q+BFL4ADMjaPZCKcBTJSzpYMVBXEMESHti85AvSxEjqTsTgtdmUYMb
         YPiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=B6q2ei1aHR9lzl0hOvwoWBIVmVDE9nFvmFewblIeLYs=;
        b=L/K+f8Zow66Xrb7BN0KDkv1McXij8+hVXXCMfUrjy67dc9gjTQs/EvT0rLn/5OA9xp
         Ixvh0KK23jbcoX9reFMN7TjeeAmIL63ilhCZGHJJhK4L1k3Qe5PGLz0uwho1zRKqTj+0
         oMdb4U2FQ8i5MvArFkpVtL5Cn+d7gaEbcA0qR102cBfUoib/Fsqjnv6Rn1zFNJbTijrJ
         AAaE0EljOyuw5P0mVjI76Jl6p6oWlIDeptSO3ejbfPxM2cKCe8LLmgBTu/gt5QoUDAnH
         JaQGZmBE+S10WRanWwGEl2wR/NPPk0tdZpwpp9ZJfG5CiBejoQ3Acet7xOLS2Arzu89v
         S4ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=MPBZskVj;
       spf=neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::6])
        by mx.google.com with ESMTPS id u11si4883474wrn.0.2019.02.03.08.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 08:49:08 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::6;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=MPBZskVj;
       spf=neutral (google.com: 2a01:238:20a:202:5301::6 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549212547;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:References:Cc:To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=B6q2ei1aHR9lzl0hOvwoWBIVmVDE9nFvmFewblIeLYs=;
	b=MPBZskVjkyWGbKVWvCOa4qqUamRK/et+pO9NJhxwClNgRGF9TWw7GgY88DkHFiqSK8
	Ri4ieUPV7F+EPpQriz5L2cwEI0qz6pFf7VnoYDES42uJA8YM4UnOvD7yGfBETPrGn88j
	K5vWYN7wgkAYb3AMjEY1ZYHgByQGkXeWvW/ir5O5il7HkV73I8UzJsogwEr1JIui2Vh5
	S23+zp0F3AyPdDz6As5TDjIxWi0+4KQ5ER/roMSEkD9TzopX3eKdwETnYP80iT5vvnlN
	faDOcKTxYuzcR8a26i0arZex9LhYEqOHipqun0yfLZ2d9PeHTaMxsmwwG16SWsOio8vY
	vbxA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CkH3W0cWmG9fyXgS4bddBxLVsnYjg=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:8c9a:b0b5:e3d3:9527]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv13Gn2cCf
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Sun, 3 Feb 2019 17:49:02 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de>
 <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de>
 <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de>
 <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
 <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
 <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de>
 <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
 <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
 <20190201080456.GA15456@lst.de>
 <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
Message-ID: <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
Date: Sun, 3 Feb 2019 17:49:02 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

OK, next step: b50f42f0fe12965ead395c76bcb6a14f00cdf65b (powerpc/dma: 
use the dma_direct mapping routines)

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

git checkout b50f42f0fe12965ead395c76bcb6a14f00cdf65b

Results: The X1000 and X5000 boot but unfortunately the P.A. Semi 
Ethernet doesn't work.

-- Christian


On 01 February 2019 at 5:54PM, Christian Zigotzky wrote:
> Hi Christoph,
>
> I will try it at the weekend.
>
> Thanks,
> Christian
>
> Sent from my iPhone
>
>> On 1. Feb 2019, at 09:04, Christoph Hellwig <hch@lst.de> wrote:
>>
>>> On Thu, Jan 31, 2019 at 01:48:26PM +0100, Christian Zigotzky wrote:
>>> Hi Christoph,
>>>
>>> I compiled kernels for the X5000 and X1000 from your branch 'powerpc-dma.6'
>>> today.
>>>
>>> Gitweb:
>>> http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>>
>>> git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a
>>>
>>> The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet doesn't
>>> work.
>> Oh.  Can you try with just the next one and then two patches applied
>> over the working setup?  That is first:
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/b50f42f0fe12965ead395c76bcb6a14f00cdf65b
>>
>> then also with:
>>
>> http://git.infradead.org/users/hch/misc.git/commitdiff/21fe52470a483afbb1726741118abef8602dde4d


