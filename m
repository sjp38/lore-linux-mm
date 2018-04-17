Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9FAC6B0009
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:42:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m4-v6so10976172oim.17
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:42:46 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id p187-v6si5344861oih.368.2018.04.17.08.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 08:42:45 -0700 (PDT)
Message-ID: <1523979759.3310.7.camel@HansenPartnership.com>
Subject: Re: repeatable boot randomness inside KVM guest
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 17 Apr 2018 16:42:39 +0100
In-Reply-To: <20180417151650.GA16738@thunk.org>
References: <20180414195921.GA10437@avx2> <20180414224419.GA21830@thunk.org>
	 <20180415004134.GB15294@bombadil.infradead.org>
	 <1523956414.3250.5.camel@HansenPartnership.com>
	 <20180417114728.GA21954@bombadil.infradead.org>
	 <1523966232.3250.15.camel@HansenPartnership.com>
	 <20180417151650.GA16738@thunk.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Matthew Wilcox <willy@infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2018-04-17 at 11:16 -0400, Theodore Y. Ts'o wrote:
> On Tue, Apr 17, 2018 at 12:57:12PM +0100, James Bottomley wrote:
> > 
> > You don't have to compromise the bootloader to influence this, you
> > merely have to trick it into providing the random number you
> > wanted.A  The bigger you make the attack surface (the more inputs)
> > the more likelihood of finding a trick that works.
> 
> There is a large class of devices where the bootloader can be
> considered trusted.A A For example, all modern Chrome and Android
> devices have signed bootloaders by default.A A And if you are using an
> Amazon or Chrome VM, you are generally started it with a known,
> trusted boot image.

Depends how the parameter is passed.  If it can be influenced from the
command line then a large class of "trusted boot" systems actually
don't verify the command line, so you can boot a trusted system and
still inject bogus command line parameters.  This is definitely true of
PC class secure boot.  Not saying it will always be so, just
illustrating why you don't necessarily want to expand the attack
surface.

> The reason why it's useful to have the bootloader get the entropy is
> because it may device-specific access and be able to leverage
> whatever infrastructure was used to load the kernel and/or
> intialramfs to also load the equivalent of /var/lib/systemd/random-
> seed (or /var/lib/urandom, et. al) --- and do this early enough that
> we can have truely secure randomness for those kernel faciliteis that
> need access to real randomness to initialize the stack canary, or
> initializing the slab cache.

OK, in the UEFI ideal world where every component is a perfectly
written OS, perhaps you're right.  In the more real world, do you trust
the people who wrote the bootloader to understand and correctly
implement the cryptographically secure process of obtaining a random
input?

> There are other ways that this could be done, of course.A A If the UEFI
> boot services are still available, you might be able to ask the UEFI
> services to give you randomness.A A And yes, the hardware might be
> backdoored to the fare-the-well by the MSS (for devices manufactured
> in China) or by an NSA Tailored Access Operations intercepting a
> computer shipment in transit.A A But my vision was that this wouldn't
> necessarily bump the entropy accounting or mark the CRNG as fully
> intialized.A A (If you work for the NSA and you're sure you won't do an
> own-goal, you could enable a kernel boot option which marks the CRNG
> initialized from entropy coming from UEFI or RDRAND or a TPM.A A But I
> don't think it should be the default.)
> 
> The only goal was to get enough uncertainty so we can secure early
> kernel users of entropy for security features such as kernel ASLR,
> the kernel stack canary, SLAB freelist randomization, etc.
> 
> And by the way --- if you think it is easy / possible to get secure
> random numbers easily from either a TPMv1 or TPMv2 w/o any early boot
> services (e.g., no interrupts, no DMA, no page tables, no memory
> allocation) that would be really good to know.

Well, as I said, I was planning to use the EFI driver (actually for
IMA, but it works here too) which should be present to the kernel on
boot.  We also don't have quite the severe restrictions you say.  The
bootmem interface is usable for allocations (even ones that persist
beyond init discard) and, although most TPMs are actually polled
devices, it is possible to use interrupt drivers that do DMA via UEFI
in early boot provided you know what you're doing.

James
