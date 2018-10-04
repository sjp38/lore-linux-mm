Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9186A6B026B
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:14:46 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v1-v6so6224008wmh.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:14:46 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id l74-v6si3579167wmd.35.2018.10.04.01.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:14:45 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:14:38 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004081429.GB1864@zn.tnic>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
 <20181004080321.GA3630@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181004080321.GA3630@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, Oct 04, 2018 at 10:03:21AM +0200, Joerg Roedel wrote:
> I also triggered this when working in the PTI-x32 code. It always
> happens on a 32-bit PAE kernel for me.
> 
> Tracking it down I ended up in (iirc) arch/x86/mm/pageattr.c
> 	function static_protections():
> 
> 		/*
> 		 * The BIOS area between 640k and 1Mb needs to be executable for
> 		 * PCI BIOS based config access (CONFIG_PCI_GOBIOS) support.
> 		 */
> 	#ifdef CONFIG_PCI_BIOS
> 		if (pcibios_enabled && within(pfn, BIOS_BEGIN >> PAGE_SHIFT, BIOS_END >> PAGE_SHIFT))
> 			pgprot_val(forbidden) |= _PAGE_NX;
> 	#endif
> 
> I think that is the reason we are seeing this in that configuration.

So looking at this, BIOS_BEGIN and BIOS_END is the same range as the ISA
range:

#define ISA_START_ADDRESS       0x000a0000
#define ISA_END_ADDRESS         0x00100000

#define BIOS_BEGIN              0x000a0000
#define BIOS_END                0x00100000


and I did try marking the ISA range RO in mark_rodata_ro() but the
machine wouldn't boot after. So I'm guessing BIOS needs to write there
some crap.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
