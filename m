Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 91ECB6B0012
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:25:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w23so11563712pgv.17
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:25:02 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id r7si1211342pgp.212.2018.03.27.11.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 11:25:01 -0700 (PDT)
Subject: Re: dma-mapping: clearing GFP_ZERO flag caused crashes of Ethernet on
 arc/hsdk board.
References: <1522170774.2593.9.camel@synopsys.com>
 <CAHp75VeZSsdR1=ZhOM6jseYCP3m0GyE=8EjJUxWosze9BBw9rQ@mail.gmail.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <a4bc637f-9464-c585-c6d2-663e2e38f18f@synopsys.com>
Date: Tue, 27 Mar 2018 11:24:51 -0700
MIME-Version: 1.0
In-Reply-To: <CAHp75VeZSsdR1=ZhOM6jseYCP3m0GyE=8EjJUxWosze9BBw9rQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>, hch@lst.de
Cc: Evgeniy Didin <Evgeniy.Didin@synopsys.com>, "jesper.nilsson@axis.com" <jesper.nilsson@axis.com>, Alexey Brodkin <Alexey.Brodkin@synopsys.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "dmaengine@vger.kernel.org" <dmaengine@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Christoph, Andy

On 03/27/2018 11:11 AM, Andy Shevchenko wrote:
> On Tue, Mar 27, 2018 at 8:12 PM, Evgeniy Didin
> <Evgeniy.Didin@synopsys.com> wrote:
>> Hello,
>>
>> After commit  57bf5a8963f8 ("dma-mapping: clear harmful GFP_* flags in common code")  we noticed problems with Ethernet controller on one of our platforms (namely ARC HSDK).
>> I
>> n particular we see that removal of __GFP_ZERO flag in function dma_alloc_attrs() was the culprit because in our implementation of arc_dma_alloc() we only allocate zeroed pages if
>> that flag is explicitly set by the caller. Now with unconditional removal of that flag in dma_alloc_attrs() we allocate non-zeroed pages and that seem to cause problems.
>>
>> From
>> mentioned commit message I may conclude that architectural code is supposed to always allocate zeroed pages but I cannot find any requirement of that in kernel's documentation.
>> Coul
>> d you please point me to that requirement if that exists at all, then we'll implement a fix in our arch code like that:

[snip]

> Another question why caller can't ask for zero pages explicitly?

Question to whom ? The caller can ask for it - but the problem here is generic dma 
API code is clearing out GFP_ZERO and expecting arch code to memst unconditionally 
- is that expected of arch code - and is documented ?

That is broken to begin with - arch dma_alloc* simply passes thru gfp flags to 
page allocator and doesn't muck around with them. We could in theory but doesn't 
seem like the right thing to do IMO.

-Vineet
