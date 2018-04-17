Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1EBF6B005A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:20:50 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id v20-v6so12380388otd.10
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:20:50 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id n17-v6si5664346otj.271.2018.04.17.08.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 08:20:49 -0700 (PDT)
Message-ID: <1523978443.3310.3.camel@HansenPartnership.com>
Subject: Re: repeatable boot randomness inside KVM guest
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 17 Apr 2018 16:20:43 +0100
In-Reply-To: <20180417140722.GC21954@bombadil.infradead.org>
References: <20180414195921.GA10437@avx2> <20180414224419.GA21830@thunk.org>
	 <20180415004134.GB15294@bombadil.infradead.org>
	 <1523956414.3250.5.camel@HansenPartnership.com>
	 <20180417114728.GA21954@bombadil.infradead.org>
	 <1523966232.3250.15.camel@HansenPartnership.com>
	 <20180417140722.GC21954@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2018-04-17 at 07:07 -0700, Matthew Wilcox wrote:
> On Tue, Apr 17, 2018 at 12:57:12PM +0100, James Bottomley wrote:
> > On Tue, 2018-04-17 at 04:47 -0700, Matthew Wilcox wrote:
> > > On Tue, Apr 17, 2018 at 10:13:34AM +0100, James Bottomley wrote:
> > > > On Sat, 2018-04-14 at 17:41 -0700, Matthew Wilcox wrote:
> > > > > On Sat, Apr 14, 2018 at 06:44:19PM -0400, Theodore Y. Ts'o
> > > > > wrote:
> > > > > > What needs to happen is freelist should get randomized much
> > > > > > later in the boot sequence.A A Doing it later will require
> > > > > > locking; I don't know enough about the slab/slub code to
> > > > > > know whether the slab_mutex would be sufficient, or some
> > > > > > other lock might need to be added.
> > > > > 
> > > > > Could we have the bootloader pass in some initial randomness?
> > > > 
> > > > Where would the bootloader get it from (securely) that the
> > > > kernel can't?
> > > 
> > > In this particular case, qemu is booting the kernel, so it can
> > > apply to /dev/random for some entropy.
> > 
> > Well, yes, but wouldn't qemu virtualize /dev/random anyway so the
> > guest A kernel can get it from the HWRNG provided by qemu?
> 
> The part of Ted's mail that I snipped explained that virtio-rng
> relies on being able to kmalloc memory, so by definition it can't
> provide entropy before kmalloc is initialised.

That sounds fixable ...

> > > I thought our model was that if somebody had compromised the
> > > bootloader, all bets were off.
> > 
> > You don't have to compromise the bootloader to influence this, you
> > merely have to trick it into providing the random number you
> > wanted.A  The bigger you make the attack surface (the more inputs)
> > the more likelihood of finding a trick that works.
> > 
> > > A A And also that we were free to mix in as many untrustworthy
> > > bytes of alleged entropy into the random pool as we liked.
> > 
> > No, entropy mixing ensures that all you do with bad entropy is
> > degrade the quality, but if the quality degrades to zero (as it
> > might at boot when you've no other entropy sources so you feed in
> > 100% bad entropy), then the random sequences become predictable.
> 
> I don't understand that.A A If I estimate that I have 'k' bytes of
> entropy in my pool, and then I mix in 'n' entirely predictable bytes,
> I should still have k bytes of entropy in the pool.A A If I withdraw k
> bytes from the pool, then yes the future output from the pool may be
> entirely predictable, but I have to know what those k bytes were.

If that were true, why are we debating this?  I thought the problem was
the alleged random sequences for slub placement were repeating on
subsequent VM boots meaning there's effectively no entropy in the pool
and we need to add some.

James
