Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07AC86B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:03:24 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c13-v6so2800492ede.6
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:03:23 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id e1-v6si2658435eji.64.2018.10.04.01.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:03:22 -0700 (PDT)
Date: Thu, 4 Oct 2018 10:03:21 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: x86/mm: Found insecure W+X mapping at address (ptrval)/0xc00a0000
Message-ID: <20181004080321.GA3630@8bytes.org>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de>
 <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de>
 <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de>
 <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de>
 <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de>
 <20181003212255.GB28361@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003212255.GB28361@zn.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Paul Menzel <pmenzel@molgen.mpg.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>

On Wed, Oct 03, 2018 at 11:22:55PM +0200, Borislav Petkov wrote:
> On Fri, Sep 28, 2018 at 04:55:19PM +0200, Thomas Gleixner wrote:
> > Sorry for the delay and thanks for the data. A quick diff did not reveal
> > anything obvious. I'll have a closer look and we probably need more (other)
> > information to nail that down.

I also triggered this when working in the PTI-x32 code. It always
happens on a 32-bit PAE kernel for me.

Tracking it down I ended up in (iirc) arch/x86/mm/pageattr.c
	function static_protections():

		/*
		 * The BIOS area between 640k and 1Mb needs to be executable for
		 * PCI BIOS based config access (CONFIG_PCI_GOBIOS) support.
		 */
	#ifdef CONFIG_PCI_BIOS
		if (pcibios_enabled && within(pfn, BIOS_BEGIN >> PAGE_SHIFT, BIOS_END >> PAGE_SHIFT))
			pgprot_val(forbidden) |= _PAGE_NX;
	#endif

I think that is the reason we are seeing this in that configuration.


Regards,

	Joerg
