Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D55796B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 18:26:22 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id va2so13131261obc.7
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:26:22 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id ic1si8495006obb.104.2015.01.20.15.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 15:26:21 -0800 (PST)
Date: Tue, 20 Jan 2015 17:26:11 -0600
From: Nishanth Menon <nm@ti.com>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150120232611.GA14142@kahuna>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150120140546.DDCB8D4@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linux-omap <linux-omap@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 16:05-20150120, Kirill A. Shutemov wrote:
> Russell King - ARM Linux wrote:
> > On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
> > > Better option would be converting 2-lvl ARM configuration to
> > > <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
> > 
> > Well, IMHO the folded approach in asm-generic was done the wrong way
> > which barred ARM from ever using it.
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
> -- 
> 2.1.4

Above helps the TI platforms
1:                     am335x-evm: BOOT: PASS: am335x-evm.txt
2:                      am335x-sk: BOOT: PASS: am335x-sk.txt
3:                     am3517-evm: BOOT: PASS: am3517-evm.txt
4:                      am37x-evm: BOOT: PASS: am37x-evm.txt
5:                      am437x-sk: BOOT: PASS: am437x-sk.txt
6:                    am43xx-epos: BOOT: PASS: am43xx-epos.txt
7:                   am43xx-gpevm: BOOT: PASS: am43xx-gpevm.txt
8:    BeagleBoard-X15(am57xx-evm): BOOT: PASS: am57xx-evm.txt
9:                 BeagleBoard-XM: BOOT: PASS: beagleboard.txt
10:            beagleboard-vanilla: BOOT: PASS: beagleboard-vanilla.txt
11:               beaglebone-black: BOOT: PASS: beaglebone-black.txt
12:                     beaglebone: BOOT: PASS: beaglebone.txt
13:                     craneboard: BOOT: PASS: craneboard.txt
14:                     dra72x-evm: BOOT: PASS: dra72x-evm.txt
15:                     dra7xx-evm: BOOT: PASS: dra7xx-evm.txt
16:         OMAP3430-Labrador(LDP): BOOT: PASS: ldp.txt
17:                           n900: BOOT: FAIL: n900.txt (legacy issue
with my farm)
18:                      omap5-evm: BOOT: PASS: omap5-evm.txt
19:                  pandaboard-es: BOOT: PASS: pandaboard-es.txt
20:             pandaboard-vanilla: BOOT: PASS: pandaboard-vanilla.txt
21:                        sdp2430: BOOT: PASS: sdp2430.txt
22:                        sdp3430: BOOT: PASS: sdp3430.txt
23:                        sdp4430: BOOT: PASS: sdp4430.txt
TOTAL = 23 boards, Booted Boards = 22, No Boot boards = 1

please feel free to add my
Tested-by: Nishanth Menon <nm@ti.com>

-- 
Regards,
Nishanth Menon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
