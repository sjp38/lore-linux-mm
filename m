Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5177C6B02B4
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:10:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v11so6869381oif.2
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 22:10:14 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id o68si1986150oik.206.2017.08.16.22.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 22:10:13 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id f16so3640151itb.5
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 22:10:13 -0700 (PDT)
Message-ID: <1502946611.3986.48.camel@gmail.com>
Subject: Re: [kernel-hardening] [PATCHv2 2/2] extract early boot entropy
 from the passed cmdline
From: Daniel Micay <danielmicay@gmail.com>
Date: Thu, 17 Aug 2017 01:10:11 -0400
In-Reply-To: <CAGXu5jLyegoCA4cBDyOWvcsV3_wE8BBFRnuhkbORdFHTswGpoA@mail.gmail.com>
References: <20170816224650.1089-1-labbott@redhat.com>
	 <20170816224650.1089-3-labbott@redhat.com>
	 <CAFJ0LnHdAwAHJipwqOHzdLktCL+Ttdywuogk0ORHqn7eauRLkA@mail.gmail.com>
	 <CAGXu5jLyegoCA4cBDyOWvcsV3_wE8BBFRnuhkbORdFHTswGpoA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Nick Kralevich <nnk@google.com>
Cc: Laura Abbott <labbott@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2017-08-16 at 21:58 -0700, Kees Cook wrote:
> On Wed, Aug 16, 2017 at 9:56 PM, Nick Kralevich <nnk@google.com>
> wrote:
> > On Wed, Aug 16, 2017 at 3:46 PM, Laura Abbott <labbott@redhat.com>
> > wrote:
> > > From: Daniel Micay <danielmicay@gmail.com>
> > > 
> > > Existing Android bootloaders usually pass data useful as early
> > > entropy
> > > on the kernel command-line. It may also be the case on other
> > > embedded
> > > systems. Sample command-line from a Google Pixel running
> > > CopperheadOS:
> > > 
> > 
> > Why is it better to put this into the kernel, rather than just rely
> > on
> > the existing userspace functionality which does exactly the same
> > thing? This is what Android already does today:
> > https://android-review.googlesource.com/198113
> 
> That's too late for setting up the kernel stack canary, among other
> things. The kernel will also be generating some early secrets for slab
> cache canaries, etc. That all needs to happen well before init is
> started.
> 
> -Kees
> 

It's also unfortunately the kernel's global stack canary for the entire
boot since unlike x86 there aren't per-task canaries. GCC / Clang access
it via a segment register on x86 vs. a global on other architectures.

In theory it could be task-local elsewhere but doing it efficiently
would imply reserving a register to store the random value. I think that
may actually end up helping performance more than it hurts by not
needing to read the global stack canary value from cache repeatedly. If
stack canaries were augmented into something more (XOR in the retaddr
and offer the option of more coverage than STRONG) it would be more
important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
