Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C838C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:07:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC30C2085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:07:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MeEaNoyu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC30C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 634A18E0003; Wed, 26 Jun 2019 02:07:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E47D8E0002; Wed, 26 Jun 2019 02:07:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AC8E8E0003; Wed, 26 Jun 2019 02:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28AAD8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:07:20 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k10so2771775ywb.18
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lOYN6Xujx0qgVx2R2grB9rnpAuC+tRlCUn6fhuHNVBw=;
        b=jtIJTuWdaRfeKDQIMOdVz1ziEtH8oR+iIFNniWpUQp6oI9hDtsE2FJfs0R5uv/M6KH
         dk5QEQsuNpr/AeEEOSoj7OheuQ/7hZ/xyJxJ7CRjnwr5yxFCH5Wj1HgTVDpfd4nCVpum
         Mjc8FWNRaqvwsm+fJu11gc+Rvrh3+V8EKv8iuvWpNKf0LkEHm5BTaeUFgUr+MEjb+TTe
         Xl40SBVYsF+7jYn67qz0NqSBJCDPVIaAUxIKnwXRhqTtmhnjnU9c8B49viOsNb9A7QCI
         igdOkqPtxV8jCtddwJTz+VXC8pBiPxDbZR7lnvvwPpPbqQPfEP7Kb85ojrG3EFIhtnHZ
         nkeA==
X-Gm-Message-State: APjAAAVsikrgjDzddhr7z/RXAjO5lY6jCRD6LrlqXURuFi849gmFFTQm
	tbVIDi7f7tx2vbLjOgzYzuGrH8Srrz98plX7EeL/u3LfEdEfpuLCnJGer8yb3r26ek0LsJLJghu
	vPUOe/bHyU81ucQCQ958lm7gzYBgYXUCey0feD22sGRrmPzdYrWPuSR9mat8tfI9OnA==
X-Received: by 2002:a81:23d1:: with SMTP id j200mr1542646ywj.475.1561529239898;
        Tue, 25 Jun 2019 23:07:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLVjaPuYdnvsCd8LWcLAtjvw02f5qyYj1L5Q03jCdD6FHTbcVB7qY88DH/YRW1QP0xGprh
X-Received: by 2002:a81:23d1:: with SMTP id j200mr1542615ywj.475.1561529239133;
        Tue, 25 Jun 2019 23:07:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561529239; cv=none;
        d=google.com; s=arc-20160816;
        b=DdHO2kfnkGnv/9J/t/VDRqdkVU8+5/I4C6Qe1MkCJ2/92duJ9u03f5FxwNgBuSBWpn
         VG0dgZVIvr+/98M3YZk2dQeJSmp1Enow/o+KSnZ92UvKG3upiLVvDWmX5U5aap/8R14p
         xq8V4m987uJCs2BugmwCZuf2pBmZfGZK3kSnqakjLHkaPVzGEDcMPigOIP/2vF3zWM9/
         c1CthszMakqukXlUQyRonMcmhLDCC+o1lU0nfS7FZs63SdViMpZN7JL2Js61+4MmXz8I
         Np9UP/FWM9pkSOkqbPv1mwm508rkO2yUpPSDv5w1LfBuPPMCz3pp4Y3GUV6B6E+YlPN1
         0DDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lOYN6Xujx0qgVx2R2grB9rnpAuC+tRlCUn6fhuHNVBw=;
        b=RLo6csPjCTcNlFyZWkiT5B5qNOraU3sll070ZM+3IzGONKRyxBks+7l0YZXdroOLrg
         Oe58D6BIpijoZJKkW7jV8GkENT1YSLyLLB0PcI624ppsQYjWLX8NrzrVNHLkVphCBUqq
         m9ctinRPklZp03GUSsjWgnNkLxBYOZeiKU9YpR/wOFbNe5NHVMtxpCT7Vt7ynlBkp0O2
         AiH+bezbltYLqA4VOPkgsnD24OMiBGPpGvCCQ9a/7ICTfDi07nFkbHPWNxljsFMLj4yM
         YyLLmXyR0AT7VVtFuiQFLY8x3GOwMF8e15jIJswSHDOuqW+G9hF8k//HpxL1S65e4yoM
         CMpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MeEaNoyu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f8si5970633ywc.267.2019.06.25.23.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:07:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=MeEaNoyu;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d130b940000>; Tue, 25 Jun 2019 23:07:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 25 Jun 2019 23:07:18 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 25 Jun 2019 23:07:18 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 26 Jun
 2019 06:07:14 +0000
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
To: Michal Hocko <mhocko@kernel.org>
CC: Jason Gunthorpe <jgg@mellanox.com>, Ira Weiny <ira.weiny@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, Christoph Hellwig <hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
 <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
 <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
 <20190619192719.GO9374@mellanox.com>
 <29f43c79-b454-0477-a799-7850e6571bd3@nvidia.com>
 <20190626054554.GA17798@dhcp22.suse.cz>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f71f16a4-d411-a540-fc71-34d15f4f02d6@nvidia.com>
Date: Tue, 25 Jun 2019 23:07:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190626054554.GA17798@dhcp22.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1561529236; bh=lOYN6Xujx0qgVx2R2grB9rnpAuC+tRlCUn6fhuHNVBw=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=MeEaNoyuI3afmGIgQqaUlcM8mWD4HE/GKCjf1kgZqenkygdQ6iZn8Y+wMfzhJF87I
	 vYo21C+56S9Bvta+WE93xqp1yxRd+0aF795hDv05MxYNL3r+vvAmMHm4YgF+fZ9DDF
	 07zGzHtLnrEybnAKwTuVgiU1Di+G2xgjzSwCSSceljuW82qT60fZLO+EJoH4v/ubsD
	 NyaUlJ4MlpZ0Et6J1Gg+pmaLUo/LH/zF/aaAcoZbyC51AIUa7VWPEd94fdesxNrSAi
	 U72HjlF1/+oo9PUKkvNA5wckZf7S8p+OANEJ3IUYXElXVcyRJ79Q5H9Zy/HqtbvLbl
	 uJqmTWhXrGX7Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/25/19 10:45 PM, Michal Hocko wrote:
> On Tue 25-06-19 20:15:28, John Hubbard wrote:
>> On 6/19/19 12:27 PM, Jason Gunthorpe wrote:
>>> On Thu, Jun 13, 2019 at 06:23:04PM -0700, John Hubbard wrote:
>>>> On 6/13/19 5:43 PM, Ira Weiny wrote:
>>>>> On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
>>>>>> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
>>>>>>>
>>>> ...
>>>>> So I think it is ok.  Frankly I was wondering if we should remove the public
>>>>> type altogether but conceptually it seems ok.  But I don't see any users of it
>>>>> so...  should we get rid of it in the code rather than turning the config off?
>>>>>
>>>>> Ira
>>>>
>>>> That seems reasonable. I recall that the hope was for those IBM Power 9
>>>> systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
>>>> memory, and so the memory really is visible to the CPU. And the IBM team
>>>> was thinking of taking advantage of it. But I haven't seen anything on
>>>> that front for a while.
>>>
>>> Does anyone know who those people are and can we encourage them to
>>> send some patches? :)
>>>
>>
>> I asked about this, and it seems that the idea was: DEVICE_PUBLIC was there
>> in order to provide an alternative way to do things (such as migrate memory
>> to and from a device), in case the combination of existing and near-future
>> NUMA APIs was insufficient. This probably came as a follow-up to the early
>> 2017-ish conversations about NUMA, in which the linux-mm recommendation was
>> "try using HMM mechanisms, and if those are inadequate, then maybe we can
>> look at enhancing NUMA so that it has better handling of advanced (GPU-like)
>> devices".
> 
> Yes that was the original idea. It sounds so much better to use a common
> framework rather than awkward special cased cpuless NUMA nodes with
> a weird semantic. User of the neither of the two has shown up so I guess
> that the envisioned HW just didn't materialized. Or has there been a
> completely different approach chosen?

The HW showed up, alright: it's the IBM Power 9, which provides HW-based
memory coherency between its CPUs and GPUs. So on this system, the CPU is
allowed to access GPU memory, which *could* be modeled as DEVICE_PUBLIC.

However, what happened was that the system worked well enough with a combination
of the device driver, plus NUMA APIs, plus heaven knows what sort of /proc tuning
might have also gone on. :) No one saw the need to reach for the DEVICE_PUBLIC
functionality.

> 
>> In the end, however, _PUBLIC was never used, nor does anyone in the local
>> (NVIDIA + IBM) kernel vicinity seem to have plans to use it.  So it really
>> does seem safe to remove, although of course it's good to start with 
>> BROKEN and see if anyone pops up and complains.
> 
> Well, I do not really see much of a difference. Preserving an unused
> code which doesn't have any user in sight just adds a maintenance burden
> whether the code depends on BROKEN or not. We can always revert patches
> which remove the code once a real user shows up.

Sure, I don't see much difference either. Either way seems fine.

thanks,
-- 
John Hubbard
NVIDIA

