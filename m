Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D5B4C76194
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:55:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89D242238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rSA4j7D/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89D242238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 008666B0003; Thu, 25 Jul 2019 20:55:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFC136B0005; Thu, 25 Jul 2019 20:55:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8F78E0002; Thu, 25 Jul 2019 20:55:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9A756B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:55:07 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d18so38231425ywb.19
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:55:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ZQ1jv0UqwPmyi2RPWuaB3X1EU0IchBq6t+yb1fsAdJ4=;
        b=O9LkMSnwkdoHdoseBN68rBheyQxbSiEekVo17c2hIGKrxeeTpbG0bZF08JF9egVfHr
         ty4IsMpyZP/6srq8iRaWP5zfrnPTLyJcYGoEPvdIkswM6ZsfzLtfvzTJxHkiqsyI33Va
         ivefVBoOQVn4lNFKHePrpKclHRPMXv+wfqo749GQh5t7bVzYnrYt+swQtpVnrcuzJLcg
         iry7g4Lmc6uVMrvgMesze8UPlBIooaI0aAMKLAdfnJdW69p1LLiOre+iV45K9b6kjovS
         JBg4Y2ajIS1BYSBI+0mc1gEXiyHmPpkSh7XgVE6GqKLgihSarR+/qfkc0oQYYzxNSH2E
         B/Ng==
X-Gm-Message-State: APjAAAWbG2arOpDSP0+DgeKCMjQHN3A5EORLziALI2Fay7mlMPV7iemM
	ov7Bp8hO3mg9G04MYFse5d3RnPQiHQ3AKI1c1x4cimpI7peg7OnxbzpNZERiuZbmyqk/MqsZxZ1
	KJOhm3FSqnlidcMjAHgtFHnVuWOV341YR2ppD7YXCWlxFCTHVR6xi++1Munfix0uu8A==
X-Received: by 2002:a0d:f144:: with SMTP id a65mr53882060ywf.42.1564102507486;
        Thu, 25 Jul 2019 17:55:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoaodLwu18jFQD0EP3UsgYJJ+kafjye+Cx6XWt2SDAEUkqqxVGlZvf4KzwwVgkbYRs7m1i
X-Received: by 2002:a0d:f144:: with SMTP id a65mr53882043ywf.42.1564102506862;
        Thu, 25 Jul 2019 17:55:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102506; cv=none;
        d=google.com; s=arc-20160816;
        b=lY015MHuI/vRRdKyEs4OmrgRczvBBkM5pF3WrP6durNucizADAroUFQBsUaQpJ+wO5
         x41ArmT7DwWl7veoulXPnEKGk9ST9JA0lu3qpaBjthJa1V3sayIwCruFBW5Yc6xz5TMz
         HJtc71NaQMenZd1h1KjU56NIubQZFckUKT7bun0rXK6j2dlOQ49XyypAU9loWT6XsWOJ
         u8JM5kZh0+Z+Kok3l6hpnhnEfOl8D2s+juBKsuPIqZVYuPnyzm+lAbHp6/+MKdKlwW4L
         TDi8xeXc6LQ+YpXHv4EnwaT4uNFCT2OoWZ0wo7P2/TTbxCtRrZ3DoUrYZ/wgcX5lx8m9
         II/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ZQ1jv0UqwPmyi2RPWuaB3X1EU0IchBq6t+yb1fsAdJ4=;
        b=V/GL/hS3MB2Ql2C0J/js1yEOllMzrUIIzz9Qrl7DR2V6bfyXbLVBDd7NvEwa9YKhq2
         /NiYjT8x908hoxepucofVJJFfBecPPX8ifcMrUAb0WhViK9eCALNshasld8gwNJ2vMPG
         Q2JH2vlcgYm/ptkfAQCnp+nj3EeX7fv8l/5iz7RHGZaqT4875UbY9CGp/2Py9Wbe3C4/
         WKt4OUQeum0X/0NsR24yfDdYXiWRQS8hRkDoWzNnSLIo5UnMZjyz4Q8XXVAAldebnYIx
         wqqlWlG2d+QL3UiapWrDV5QS2xWFaDt9guUywuj1jy1PzH5TE8QK+s8SvnApKyeqGZXr
         juPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="rSA4j7D/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k64si17702739ywb.16.2019.07.25.17.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:55:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="rSA4j7D/";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4f710000>; Thu, 25 Jul 2019 17:55:13 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:55:05 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 25 Jul 2019 17:55:05 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:55:01 +0000
Subject: Re: hmm_range_fault related fixes and legacy API removal v3
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
CC: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <20190724065258.16603-1-hch@lst.de>
 <20190726001622.GL7450@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <a07dbc3b-7a54-e524-944a-b7e4e49b2a93@nvidia.com>
Date: Thu, 25 Jul 2019 17:55:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190726001622.GL7450@mellanox.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102513; bh=ZQ1jv0UqwPmyi2RPWuaB3X1EU0IchBq6t+yb1fsAdJ4=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rSA4j7D/xNb2bkL0Vko/F5CDOw23LnvAQ9X4DTiY7zQS3PiAsqw2fzljmrhRjSyBN
	 4X3+94583ksRVxxOzb4rj3LQNLiQxzqNjNyzesErehEFqBsooYKLAg/6fe8WILNsKM
	 Xr0M1AvN11D0pFDeVa9NIi04J+6Xn9RViB3w/Xj05ZxX6hpsr0f8ZB6QJs2eJXsNN6
	 ttQj2VXTgfGFRU0syqQpO7ddPAhhik56aRFDYDMQRLAVAQ2EnplEBlWLmgGBf7zqPq
	 oMGDywdYOAXCAq0xaRkg8JQMI/T5f0db79g5qEltRtKCCl+kLC+9f5Lq1eyKng0xeq
	 T07CsoiXv06rQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/25/19 5:16 PM, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 08:52:51AM +0200, Christoph Hellwig wrote:
>> Hi J=C3=A9r=C3=B4me, Ben and Jason,
>>
>> below is a series against the hmm tree which fixes up the mmap_sem
>> locking in nouveau and while at it also removes leftover legacy HMM APIs
>> only used by nouveau.
>>
>> The first 4 patches are a bug fix for nouveau, which I suspect should
>> go into this merge window even if the code is marked as staging, just
>> to avoid people copying the breakage.
>>
>> Changes since v2:
>>   - new patch from Jason to document FAULT_FLAG_ALLOW_RETRY semantics
>>     better
>>   - remove -EAGAIN handling in nouveau earlier
>=20
> I don't see Ralph's tested by, do you think it changed enough to
> require testing again? If so, Ralph would you be so kind?
>=20
> In any event, I'm sending this into linux-next and intend to forward
> the first four next week.
>=20
> Thanks,
> Jason
>=20

I have been testing Christoph's v3 with my set of v2 changes so
feel free to add my tested-by.

