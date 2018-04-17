Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2860E6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 05:13:51 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id w6-v6so3257465otj.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 02:13:51 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id g195-v6si1882466oic.150.2018.04.17.02.13.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 02:13:50 -0700 (PDT)
Message-ID: <1523956414.3250.5.camel@HansenPartnership.com>
Subject: Re: repeatable boot randomness inside KVM guest
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 17 Apr 2018 10:13:34 +0100
In-Reply-To: <20180415004134.GB15294@bombadil.infradead.org>
References: <20180414195921.GA10437@avx2> <20180414224419.GA21830@thunk.org>
	 <20180415004134.GB15294@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, "Theodore Y. Ts'o" <tytso@mit.edu>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2018-04-14 at 17:41 -0700, Matthew Wilcox wrote:
> On Sat, Apr 14, 2018 at 06:44:19PM -0400, Theodore Y. Ts'o wrote:
> > What needs to happen is freelist should get randomized much later
> > in the boot sequence.A A Doing it later will require locking; I don't
> > know enough about the slab/slub code to know whether the slab_mutex
> > would be sufficient, or some other lock might need to be added.
> 
> Could we have the bootloader pass in some initial randomness?

Where would the bootloader get it from (securely) that the kernel
can't?  For example, if you compile in a TPM driver, the kernel will
pick up 32 random entropy bytes from the TPM to seed the pool, but I
think it happens too late to help with this problem currently.  IMA
also needs the TPM very early in the boot sequence, so I was wondering
about using the initial EFI driver, which is present on boot, and then
transitioning to the proper kernel TPM driver later, which would mean
we could seed the pool earlier.

As long as you mix it properly and limit the amount, it shouldn't
necessarily be a source of actual compromise, but having an external
input to our cryptographically secure entropy pool is an additional
potential attack vector.

James
