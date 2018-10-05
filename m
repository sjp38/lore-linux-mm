Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id C456E6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 05:27:32 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id 189-v6so745672wme.0
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 02:27:32 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id s10-v6si5886483wrr.177.2018.10.05.02.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Oct 2018 02:27:31 -0700 (PDT)
Date: Fri, 5 Oct 2018 11:27:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address
 (ptrval)/0xc00a0000
In-Reply-To: <20181004080321.GA3630@8bytes.org>
Message-ID: <alpine.DEB.2.21.1810051124320.3960@nanos.tec.linutronix.de>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de> <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de> <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de> <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de> <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de> <20181003212255.GB28361@zn.tnic> <20181004080321.GA3630@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Borislav Petkov <bp@alien8.de>, Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Thu, 4 Oct 2018, Joerg Roedel wrote:

> On Wed, Oct 03, 2018 at 11:22:55PM +0200, Borislav Petkov wrote:
> > On Fri, Sep 28, 2018 at 04:55:19PM +0200, Thomas Gleixner wrote:
> > > Sorry for the delay and thanks for the data. A quick diff did not reveal
> > > anything obvious. I'll have a closer look and we probably need more (other)
> > > information to nail that down.
> 
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

Uurgh. Yes.

If pcibios is enabled and used, need to look at the gory details of that
first, then the W+X check has to exclude that region. We can't do much
about that.

Thanks,

	tglx
