Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1046B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 12:31:02 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y192so15978090pgd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 09:31:02 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0063.outbound.protection.outlook.com. [104.47.36.63])
        by mx.google.com with ESMTPS id m3si8524197pld.655.2017.10.02.09.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 09:31:01 -0700 (PDT)
Subject: Re: Regression: x86/mm: Add Secure Memory Encryption (SME) support
References: <d5c60048-dbb3-0440-d139-ea325621e654@iam.tj>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <c0528ed8-2d00-dedf-4f90-8aa7eead4b5a@amd.com>
Date: Mon, 2 Oct 2017 11:30:57 -0500
MIME-Version: 1.0
In-Reply-To: <d5c60048-dbb3-0440-d139-ea325621e654@iam.tj>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tj <linux@iam.tj>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@suse.de>

On 9/30/2017 5:36 PM, Tj wrote:
> With 4.14.0rc2 on an Intel CPU with an Nvidia GPU the proprietary nvidia
> driver (v340.102) fails to modpost due to:
> 
> FATAL: modpost: GPL-incompatible module nvidia.ko uses GPL-only symbol
> 'sme_me_mask'
> 
> I think this is due to:
> 
> config ARCH_HAS_MEM_ENCRYPT
>         def_bool y
> 

I think this is more likely because of CONFIG_AMD_MEM_ENCRYPT=y. If
CONFIG_AMD_MEM_ENCRYPT=n then sme_me_mask becomes a #define. I'm
assuming that changing the sme_me_mask in arch/x86/mm/mem_encrypt.c
from EXPORT_SYMBOL_GPL to EXPORT_SYMBOL fixes the issue?

Boris, is it a big deal to make this change if that's the issue?

Thanks,
Tom

> 
> I noticed that a grep of the built kernel for "sme_me_mask" shows the
> symbol imported into more than 300 modules on an Ubuntu mainline build
> of 4.14.0-041400rc2-lowlatency.
> 
> Should the new symbol be referenced so widely and how can it be
> prevented from being included in proprietary modules on systems that
> don't have SME even if the kernel is built with it enabled? >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
