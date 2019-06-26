Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 520AFC48BD7
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9EF02146E
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:15:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="JWS56c7L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9EF02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DE896B0003; Tue, 25 Jun 2019 23:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4912C8E0003; Tue, 25 Jun 2019 23:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 358398E0002; Tue, 25 Jun 2019 23:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16F276B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:15:33 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b63so2018910ywc.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mFKCj/TnJw3viqoDN0No22dYQzshEvjZPsHuzsScphE=;
        b=oIOgeXVgabsrPya2Em1TqQC5AVqtEr8LarmOtoiADAjjWP1TnbQE+LcU5HkmxtMP6j
         hax35QE+pJp1dchG7aU/260jMzjGCNYK1QZ5ntF9Keb+7NLqM64YiszLWRAlvniG8uVH
         Wl1jeChxiBibBi697/ByfWGtujlq1sWl43/+GTYwuLNlH68SI+HN9rehUWrBwVj2Q0AA
         59Z8yV3j9fmiV5+u1pXbhUoSN7oyCoDWyuZp6Gj7F1CaZQ1jg0kDm7EEzNknFLMFqUQ7
         2Gua9W81cEceeColLcQb6Q405ujcqcd4DsWvJXa7MM5cxkl17IsjKBPq9VEq3twinLaT
         QQDg==
X-Gm-Message-State: APjAAAVJAYsq7PzHF9nddULSD+33kJIDH425G5oLNjpc27BOORDAY/kU
	hC10e2iwtnk4MKBFx9tAXfxL1yJzJyj/AsWSynBoWsPtTPCxRY/p20XpAcxdwCSZzNqjyRksQMB
	jtJMYE6tu4/HptiffEVRgn/ztLCJ1kfDwp1Kag+fgTBFv4q/EtnjmNKBwDZIWAwXOLQ==
X-Received: by 2002:a81:2981:: with SMTP id p123mr1185202ywp.430.1561518932844;
        Tue, 25 Jun 2019 20:15:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbfRvLDw9rSsaYF/WWzDac+VX7Bzia9ILDFOKDrEMBCJy96HzxqSDpgganjk9pif+Zj1SV
X-Received: by 2002:a81:2981:: with SMTP id p123mr1185172ywp.430.1561518932090;
        Tue, 25 Jun 2019 20:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561518932; cv=none;
        d=google.com; s=arc-20160816;
        b=uxtXtDvVNbRmddXVLk/aPmYKqQHGm0alU3YUG2fi3Rkb5gWf9JfBTLxrexS9PeqKMV
         K3aGkWOdjrci+tJ2tWDx2Ovzd0m2CK8jtKgtTv0eekzG9z9R9x9LJfaiPkMcbLoG5jAA
         2Z+XMCYn/6J8BomO4sx+nRUXDq+boCgvJpf3a/uhfz1pgzmZluaqZWlLjcU+XQwQXwEq
         vaQH0CokAnWA/JYWDPxEgbtUmn3jXe+XjXArOH6aEPM0PvHoJLtkTV6EBZ3vni1XzN0m
         SGEPyYHfCJRP0ewtIVl7E3U0Ng/6cEaXFNwF55EQD05txEbmuoDKSEKit5FdzytbPWsp
         zYiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mFKCj/TnJw3viqoDN0No22dYQzshEvjZPsHuzsScphE=;
        b=gNq0e3BjUMXkqfAoztf1axoRpjjBrJuNJMbguUUINN3gxyiEIUp8k1qYu6a01rQETG
         okFEvDtCz6mZrKKfFA+ce5NWGykrNXDiyXXPkuPYLQFTGxVoDDAnNx3sxO6I0IkPqucq
         9B4WTcMaRNMsJ4JgSKBL83MfdkFUhl3oicuqwndj+epcFc37sRONIa0++5wvnHq11LGO
         rGWo+Hbdc77tFsQMLmVYhMoqvnnn1ps8/5m1xy2lzXYk8NafDiOJ2wTjstnQYBisGTb2
         H7P5ngdG3B8YcFj/yi3zROKINknc4uJeM1LHUzeEQPvFgdzYTuRdCONTMcOCPG2XkeLg
         bOqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JWS56c7L;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 10si2192785ybj.166.2019.06.25.20.15.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 20:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=JWS56c7L;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d12e3520000>; Tue, 25 Jun 2019 20:15:30 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 25 Jun 2019 20:15:31 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 25 Jun 2019 20:15:31 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 26 Jun
 2019 03:15:29 +0000
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
To: Jason Gunthorpe <jgg@mellanox.com>
CC: Ira Weiny <ira.weiny@intel.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Christoph Hellwig
	<hch@lst.de>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
 <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
 <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com>
 <20190619192719.GO9374@mellanox.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <29f43c79-b454-0477-a799-7850e6571bd3@nvidia.com>
Date: Tue, 25 Jun 2019 20:15:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190619192719.GO9374@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1561518930; bh=mFKCj/TnJw3viqoDN0No22dYQzshEvjZPsHuzsScphE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=JWS56c7LDNZO2C+L8KR37PAJV/JNwy2VsATo0Y9o97x2OREZOXY1kW16CqdsdCF3p
	 h75heFhKUb3QKsr9tb1bJDlBPd+kZrKl1GNfPhJxKLLAVmTvovjBcLyjGppIJCVNJz
	 e/bL0Uz9WCABzn+s82NDbBpQtU8Quft0swt7Nfb9yv1tVnj/v8mVsJUeumTOsJqbpo
	 ejbFTmycRLy12cjephJ1Av4haOtY2fOQCECnDpWB4huqII/lRxMlc4SxDkKG4nThLq
	 s7yoeCAPZH4BEFoJuCbXa874ODwp/FlzUTE8v3eEQjQt1UYj/uSTcnPhWHZ0P2eSt5
	 drw5jV+XaTi+A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 12:27 PM, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 06:23:04PM -0700, John Hubbard wrote:
>> On 6/13/19 5:43 PM, Ira Weiny wrote:
>>> On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
>>>> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
>>>>>
>> ...
>>> So I think it is ok.  Frankly I was wondering if we should remove the public
>>> type altogether but conceptually it seems ok.  But I don't see any users of it
>>> so...  should we get rid of it in the code rather than turning the config off?
>>>
>>> Ira
>>
>> That seems reasonable. I recall that the hope was for those IBM Power 9
>> systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
>> memory, and so the memory really is visible to the CPU. And the IBM team
>> was thinking of taking advantage of it. But I haven't seen anything on
>> that front for a while.
> 
> Does anyone know who those people are and can we encourage them to
> send some patches? :)
> 

I asked about this, and it seems that the idea was: DEVICE_PUBLIC was there
in order to provide an alternative way to do things (such as migrate memory
to and from a device), in case the combination of existing and near-future
NUMA APIs was insufficient. This probably came as a follow-up to the early
2017-ish conversations about NUMA, in which the linux-mm recommendation was
"try using HMM mechanisms, and if those are inadequate, then maybe we can
look at enhancing NUMA so that it has better handling of advanced (GPU-like)
devices".

In the end, however, _PUBLIC was never used, nor does anyone in the local
(NVIDIA + IBM) kernel vicinity seem to have plans to use it.  So it really
does seem safe to remove, although of course it's good to start with 
BROKEN and see if anyone pops up and complains.

thanks,
-- 
John Hubbard
NVIDIA

