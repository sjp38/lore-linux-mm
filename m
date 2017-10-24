Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0AE6B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 03:06:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t10so13654068pgo.20
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 00:06:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b25si6012481pgf.689.2017.10.24.00.06.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 00:06:27 -0700 (PDT)
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
References: <20171001093704.GA12626@amd> <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com> <20171002084131.GA24414@amd>
 <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
 <20171002130353.GA25433@amd> <184b3552-851c-7015-dd80-76f6eebc33cc@intel.com>
 <20171023093109.GI32228@amd>
 <CACRpkdaa6qq91+dQ43EZDvDefbM3tjwLX5e+nNZouwXM0xJ=4w@mail.gmail.com>
 <20171023212741.GA12782@amd>
From: Adrian Hunter <adrian.hunter@intel.com>
Message-ID: <a920ce93-5421-003d-6b19-194f8ea3ee5b@intel.com>
Date: Tue, 24 Oct 2017 09:59:33 +0300
MIME-Version: 1.0
In-Reply-To: <20171023212741.GA12782@amd>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, Linus Walleij <linus.walleij@linaro.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On 24/10/17 00:27, Pavel Machek wrote:
> On Mon 2017-10-23 14:16:40, Linus Walleij wrote:
>> On Mon, Oct 23, 2017 at 11:31 AM, Pavel Machek <pavel@ucw.cz> wrote:
>>
>>>>> Thinkpad X220... how do I tell if I was using them? I believe so,
>>>>> because I uncovered bug in them before.
>>>>
>>>> You are certainly using bounce buffers.  What does lspci -knn show?
>>>
>>> Here is the output:
>>> 0d:00.0 System peripheral [0880]: Ricoh Co Ltd PCIe SDXC/MMC Host Controller [1180:e823] (rev 07)
>>>         Subsystem: Lenovo Device [17aa:21da]
>>>         Kernel driver in use: sdhci-pci
>>
>> So that is a Ricoh driver, one of the few that was supposed to benefit
>> from bounce buffers.
>>
>> Except that if you actually turned it on:
>>> [10994.302196] kworker/2:1: page allocation failure: order:4,
>> so it doesn't have enough memory to use these bounce buffers
>> anyway.
> 
> Well, look at archives: driver failed completely when allocation failed. 
> 
>> I'm now feel it was the right thing to delete them.
> 
> Which means I may have been geting benefit -- when it worked. I
> believe solution is to allocate at driver probing time.
> 
> (OTOH ... SPI is slow compared to rest of the system, right? Where
> does the benefit come from?)

Do you mean what is the benefit of the bounce buffer?  With SDMA, only a
single segment is transferred at a time - that can mean just a single page
i.e. 4k.  But the buffer is a single segment so it should enable larger
transfer sizes (i.e. buffer size 64k) which performs better.

You need to compare performance with and without the bounce buffer
(particularly when memory is fragmented) to determine how much benefit you get.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
