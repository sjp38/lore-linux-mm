Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAA5B6B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:41:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o52so13392879qto.3
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:41:03 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id s81si19151195qkl.208.2018.04.17.14.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Apr 2018 14:41:02 -0700 (PDT)
Date: Tue, 17 Apr 2018 17:40:59 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: repeatable boot randomness inside KVM guest
Message-ID: <20180417214059.GA23194@thunk.org>
References: <20180414195921.GA10437@avx2>
 <20180414224419.GA21830@thunk.org>
 <20180415004134.GB15294@bombadil.infradead.org>
 <1523956414.3250.5.camel@HansenPartnership.com>
 <20180417114728.GA21954@bombadil.infradead.org>
 <1523966232.3250.15.camel@HansenPartnership.com>
 <20180417151650.GA16738@thunk.org>
 <1523979759.3310.7.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1523979759.3310.7.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Matthew Wilcox <willy@infradead.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Apr 17, 2018 at 04:42:39PM +0100, James Bottomley wrote:
> Depends how the parameter is passed.  If it can be influenced from the
> command line then a large class of "trusted boot" systems actually
> don't verify the command line, so you can boot a trusted system and
> still inject bogus command line parameters.  This is definitely true of
> PC class secure boot.  Not saying it will always be so, just
> illustrating why you don't necessarily want to expand the attack
> surface.

Sure, this is why I don't really like the scheme of relying on the
command line.  For one thing, the command-line is public, so if the
attacker can read /proc/cmdline, they'll have access to the entropy.

What I would prefer is an extension to the boot protocol so that some
number of bytes would be passed to the kernel as a separate bag of
bytes alongside the kernel command line and the initrd.

The kernel would mix that into the random driver (which is written so
the basic input pool and primary_crng can accept input in super-early
boot).  This woud be done *before* we relocate the kernel, so that
kernel ASLR code can relocate the kernel test to a properly
unpredictable number --- so this really is quite super-early boot.

> OK, in the UEFI ideal world where every component is a perfectly
> written OS, perhaps you're right.  In the more real world, do you trust
> the people who wrote the bootloader to understand and correctly
> implement the cryptographically secure process of obtaining a random
> input?

In the default setup, I would expect the bootloader (such as grub)
would read the random initialization data from disk.  So it would work
much like systemd reading from /var/lib/systemd/random-seed.  And I
would trust the bootloader implementors to be able to do this about as
well as I would trust the systemd implementors.  :-)  It's not that
hard, after all....

						- Ted
