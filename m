Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8C86B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:18:27 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id g67-v6so3704880otb.10
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:18:27 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id f103-v6si4241279otf.325.2018.04.23.03.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 03:18:26 -0700 (PDT)
Message-ID: <5ADDB2D6.3040703@huawei.com>
Date: Mon, 23 Apr 2018 18:17:58 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] should BIOS change the efi type when we set CONFIG_X86_RESERVE_LOW
 ?
References: <5ACEBB47.3060300@huawei.com>
In-Reply-To: <5ACEBB47.3060300@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: yeyunfeng <yeyunfeng@huawei.com>, Wenan Mao <maowenan@huawei.com>, Linux
 MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/4/12 9:49, Xishi Qiu wrote:

> Hi, I find CONFIG_X86_RESERVE_LOW=64 in my system, so trim_low_memory_range()
> will reserve low 64kb memory. But efi_free_boot_services() will free it to
> buddy system again later because BIOS set the type to EFI_BOOT_SERVICES_CODE.
> 
> Here is the log:
> ...
> efi: mem03: type=3, attr=0xf, range=[0x000000000000e000-0x0000000000010000) (0MB
> ...
> 
> 

When call memblock_is_region_reserved(), it will set md->num_pages = 0 if the
memblock region is reserved. But trim_low_memory_range() reserve the region
after efi, so this breaks the logic, and efi_free_boot_services() will free
the pages(efi code/data). That means trim_low_memory_range() has not reserve
the low memory range.

...
efi_reserve_boot_services()
...
trim_low_memory_range()
...
efi_free_boot_services()
...

Shall we move trim_low_memory_range() before efi_reserve_boot_services()?

Thanks,
Xishi Qiu

> .
> 
