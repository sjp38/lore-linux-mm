Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 949FF6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 04:23:33 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id va2so29002083obc.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 01:23:33 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id h123si3092837oib.28.2015.01.21.01.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 01:23:32 -0800 (PST)
Message-ID: <54BF7007.7050800@ti.com>
Date: Wed, 21 Jan 2015 11:23:19 +0200
From: Peter Ujfalusi <peter.ujfalusi@ti.com>
MIME-Version: 1.0
Subject: Re: [next-20150119]regression (mm)?
References: <54BD33DC.40200@ti.com> <20150119174317.GK20386@saruman> <20150120001643.7D15AA8@black.fi.intel.com> <20150120114555.GA11502@n2100.arm.linux.org.uk> <20150120140546.DDCB8D4@black.fi.intel.com>
In-Reply-To: <20150120140546.DDCB8D4@black.fi.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Felipe Balbi <balbi@ti.com>, Nishanth Menon <nm@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 01/20/2015 04:05 PM, Kirill A. Shutemov wrote:
> Russell King - ARM Linux wrote:
>> On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
>>> Better option would be converting 2-lvl ARM configuration to
>>> <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
>>
>> Well, IMHO the folded approach in asm-generic was done the wrong way
>> which barred ARM from ever using it.
> 
> Okay, I see.
> 
> Regarding the topic bug. Completely untested patch is below. Could anybody
> check if it helps?
> 
> From 34b9182d08ef2b541829e305fcc91ef1d26b27ea Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 20 Jan 2015 15:47:22 +0200
> Subject: [PATCH] arm: define __PAGETABLE_PMD_FOLDED for !LPAE
> 
> ARM uses custom implementation of PMD folding in 2-level page table case.
> Generic code expects to see __PAGETABLE_PMD_FOLDED to be defined if PMD is
> folded, but ARM doesn't do this. Let's fix it.
> 
> Defining __PAGETABLE_PMD_FOLDED will drop out unused __pmd_alloc().
> It also fixes problems with recently-introduced pmd accounting on ARM
> without LPAE.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Nishanth Menon <nm@ti.com>
> ---
>  arch/arm/include/asm/pgtable-2level.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
> index bcc5e300413f..bfd662e49a25 100644
> --- a/arch/arm/include/asm/pgtable-2level.h
> +++ b/arch/arm/include/asm/pgtable-2level.h
> @@ -10,6 +10,8 @@
>  #ifndef _ASM_PGTABLE_2LEVEL_H
>  #define _ASM_PGTABLE_2LEVEL_H
>  
> +#define __PAGETABLE_PMD_FOLDED
> +
>  /*
>   * Hardware-wise, we have a two level page table structure, where the first
>   * level has 4096 entries, and the second level has 256 entries.  Each entry
> 

Among other boards I have my daVinci board (OMAP-L138-EVM) boots fine with
this patch.

Tested-by: Peter Ujfalusi <peter.ujfalusi@ti.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
