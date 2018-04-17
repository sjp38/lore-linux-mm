Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7B0E6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 07:47:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 91-v6so12225246plf.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 04:47:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b42-v6si940691pli.224.2018.04.17.04.47.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 04:47:29 -0700 (PDT)
Date: Tue, 17 Apr 2018 04:47:28 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: repeatable boot randomness inside KVM guest
Message-ID: <20180417114728.GA21954@bombadil.infradead.org>
References: <20180414195921.GA10437@avx2>
 <20180414224419.GA21830@thunk.org>
 <20180415004134.GB15294@bombadil.infradead.org>
 <1523956414.3250.5.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1523956414.3250.5.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 17, 2018 at 10:13:34AM +0100, James Bottomley wrote:
> On Sat, 2018-04-14 at 17:41 -0700, Matthew Wilcox wrote:
> > On Sat, Apr 14, 2018 at 06:44:19PM -0400, Theodore Y. Ts'o wrote:
> > > What needs to happen is freelist should get randomized much later
> > > in the boot sequence.  Doing it later will require locking; I don't
> > > know enough about the slab/slub code to know whether the slab_mutex
> > > would be sufficient, or some other lock might need to be added.
> > 
> > Could we have the bootloader pass in some initial randomness?
> 
> Where would the bootloader get it from (securely) that the kernel
> can't?

In this particular case, qemu is booting the kernel, so it can apply to
/dev/random for some entropy.

> For example, if you compile in a TPM driver, the kernel will
> pick up 32 random entropy bytes from the TPM to seed the pool, but I
> think it happens too late to help with this problem currently.  IMA
> also needs the TPM very early in the boot sequence, so I was wondering
> about using the initial EFI driver, which is present on boot, and then
> transitioning to the proper kernel TPM driver later, which would mean
> we could seed the pool earlier.
> 
> As long as you mix it properly and limit the amount, it shouldn't
> necessarily be a source of actual compromise, but having an external
> input to our cryptographically secure entropy pool is an additional
> potential attack vector.

I thought our model was that if somebody had compromised the bootloader,
all bets were off.  And also that we were free to mix in as many
untrustworthy bytes of alleged entropy into the random pool as we liked.
