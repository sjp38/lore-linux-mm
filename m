Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E68636B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:44:57 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id j17so4365743iod.18
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:44:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c126sor2710666iof.55.2017.10.26.06.44.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Oct 2017 06:44:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171023212741.GA12782@amd>
References: <20171001093704.GA12626@amd> <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com> <20171002084131.GA24414@amd>
 <CACRpkdbatrt0Uxf8653iiV-OKkgcc0Ziog_L4oDVTJVNqtNN0Q@mail.gmail.com>
 <20171002130353.GA25433@amd> <184b3552-851c-7015-dd80-76f6eebc33cc@intel.com>
 <20171023093109.GI32228@amd> <CACRpkdaa6qq91+dQ43EZDvDefbM3tjwLX5e+nNZouwXM0xJ=4w@mail.gmail.com>
 <20171023212741.GA12782@amd>
From: Linus Walleij <linus.walleij@linaro.org>
Date: Thu, 26 Oct 2017 15:44:55 +0200
Message-ID: <CACRpkdbKuEA6d8647xYP8pWFAdZ92vTM-2WmWZ24ABkZ=bhYZA@mail.gmail.com>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Adrian Hunter <adrian.hunter@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-mm@kvack.org

On Mon, Oct 23, 2017 at 11:27 PM, Pavel Machek <pavel@ucw.cz> wrote:
> On Mon 2017-10-23 14:16:40, Linus Walleij wrote:
>> On Mon, Oct 23, 2017 at 11:31 AM, Pavel Machek <pavel@ucw.cz> wrote:
>>
>> >> > Thinkpad X220... how do I tell if I was using them? I believe so,
>> >> > because I uncovered bug in them before.
>> >>
>> >> You are certainly using bounce buffers.  What does lspci -knn show?
>> >
>> > Here is the output:
>> > 0d:00.0 System peripheral [0880]: Ricoh Co Ltd PCIe SDXC/MMC Host Controller [1180:e823] (rev 07)
>> >         Subsystem: Lenovo Device [17aa:21da]
>> >         Kernel driver in use: sdhci-pci
>>
>> So that is a Ricoh driver, one of the few that was supposed to benefit
>> from bounce buffers.
>>
>> Except that if you actually turned it on:
>> > [10994.302196] kworker/2:1: page allocation failure: order:4,
>> so it doesn't have enough memory to use these bounce buffers
>> anyway.
>
> Well, look at archives: driver failed completely when allocation failed.

What I mean is that the allocation probably failed if you
explicitly turned on the bounce buffer also *before*
my patches (like if you were shopping for performance with
the Ricoh driver and turn on bounce buffers) but I haven't tested
it so what do I know.

You could check out b5b6a5f4f06c0624886b2166e2e8580327f0b943
and enable MMC_BLOCK_BOUNCE and see what happens.
And/or benchmark to see if it was actually improving your
system or not.

>> I'm now feel it was the right thing to delete them.
>
> Which means I may have been geting benefit -- when it worked. I
> believe solution is to allocate at driver probing time.

I think the right way to get this benefit is to enhance the
Ricoh SDMA path with something similar to:
commit 0ccd76d4c236 ("omap_hsmmc: Implement scatter-gather
       emulation")

What it does is loop over the sglist and smatter out one DMA
transfer per sg index.

It's likely faster than copying back and forth to a bounce
buffer even if there is a deal of HW talk back and forth.

> (OTOH ... SPI is slow compared to rest of the system, right? Where
> does the benefit come from?)

I do not think you will see much performance improvement
on an SPI-based host. Pierre just vaguely remembered "some
Ricoh controllers" would get a benefit from bounce buffers,
no specifics, sorry...

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
