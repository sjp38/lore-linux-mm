Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 360416B0003
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 15:37:26 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id y131-v6so6770445wmd.5
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 12:37:26 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b11-v6si8595951wmf.161.2018.10.08.12.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 08 Oct 2018 12:37:24 -0700 (PDT)
Date: Mon, 8 Oct 2018 21:37:13 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: x86/mm: Found insecure W+X mapping at address
 (ptrval)/0xc00a0000
In-Reply-To: <74dededa-3754-058b-2291-a349b9f3673e@molgen.mpg.de>
Message-ID: <alpine.DEB.2.21.1810082108570.2455@nanos.tec.linutronix.de>
References: <e75fa739-4bcc-dc30-2606-25d2539d2653@molgen.mpg.de> <alpine.DEB.2.21.1809191004580.1468@nanos.tec.linutronix.de> <0922cc1b-ed51-06e9-df81-57fd5aa8e7de@molgen.mpg.de> <alpine.DEB.2.21.1809210045220.1434@nanos.tec.linutronix.de>
 <c8da5778-3957-2fab-69ea-42f872a5e396@molgen.mpg.de> <alpine.DEB.2.21.1809281653270.2004@nanos.tec.linutronix.de> <20181003212255.GB28361@zn.tnic> <20181004080321.GA3630@8bytes.org> <alpine.DEB.2.21.1810051124320.3960@nanos.tec.linutronix.de>
 <74dededa-3754-058b-2291-a349b9f3673e@molgen.mpg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: =?ISO-8859-15?Q?J=F6rg_R=F6del?= <joro@8bytes.org>, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, x86@kernel.org, lkml <linux-kernel@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>

Paul,

On Fri, 5 Oct 2018, Paul Menzel wrote:
> On 10/05/18 11:27, Thomas Gleixner wrote:
> > If pcibios is enabled and used, need to look at the gory details of that
> > first, then the W+X check has to exclude that region. We can't do much
> > about that.
> 
> That would also explain, why it only happens with the SeaBIOS payload,
> which sets up legacy BIOS calls. Using GRUB directly as payload, no BIOS
> calls are set up.
> 
> Reading the Kconfig description of the PCI access mode, the BIOS should
> only be used last.

Correct. And looking at the dmesg you provided it is initialized:

[    0.441062] PCI: PCI BIOS area is rw and x. Use pci=nobios if you want it NX.
[    0.441062] PCI: PCI BIOS revision 2.10 entry at 0xffa40, last bus=3

Though I assume it's not really required, but this PCI BIOS thing is not
really well documented and there are some obsure usage sites involved.

Bjorn, do you have any insight or did you flush those memories long ago?

Anyway we need to exclude the BIOS area when the kernel sets the W+X on
purpose. Warning about that is bogus. I'll send out a patch soon.

Thanks,

	tglx
