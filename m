Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2777E6B0262
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 19:45:06 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so47379381pab.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 16:45:06 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gv1si15959258pac.69.2016.11.04.16.45.04
        for <linux-mm@kvack.org>;
        Fri, 04 Nov 2016 16:45:04 -0700 (PDT)
Date: Fri, 4 Nov 2016 23:44:59 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
Message-ID: <20161104234459.GA18760@remoulade>
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Russell King <rmk+kernel@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Wed, Nov 02, 2016 at 12:15:50PM -0700, Dave Hansen wrote:
> On 10/31/2016 05:08 PM, Mark Rutland wrote:
> > When an architecture does not select CONFIG_ARCH_HAS_PKEYS, the pkey_alloc
> > syscall will return -ENOSPC for all (otherwise well-formed) requests, as the
> > generic implementation of mm_pkey_alloc() returns -1. The other pkey syscalls
> > perform some work before always failing, in a similar fashion.
> > 
> > This implies the absence of keys, but otherwise functional pkey support. This
> > is odd, since the architecture provides no such support. Instead, it would be
> > preferable to indicate that the syscall is not implemented, since this is
> > effectively the case.
> 
> This makes the behavior of an x86 cpu without pkeys and an arm cpu
> without pkeys differ.  Is that what we want?

My rationale was that we have no idea whether architectures will have pkey
support in future, and if/when they do, we may have to apply additional checks
anyhow. i.e. in cases we'd return -ENOSPC today, we might want to return
another error code.

Returning -ENOSYS retains the current behaviour, and allows us to handle that
ABI issue when we know what architecture support looks like.

Other architectures not using the generic syscalls seem to handle this with
-ENOSYS, e.g. parisc with commit 18088db042dd9ae2, so there's differing
behaviour regardless of arm specifically.

> An application that _wants_ to use protection keys but can't needs to handle
> -ENOSPC anyway.

Sure, and that application *also* has to handle -ENOSYS, given current kernels.

> On an architecture that will never support pkeys, it makes sense to do
> -ENOSYS, but that's not the case for arm, right?

I don't know whether arm or other architectures will have (user-accessible)
pkey-like suport.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
