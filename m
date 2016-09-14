Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01B4F6B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 05:36:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ex14so16923378pac.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 02:36:52 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s4si5799850pfi.286.2016.09.14.02.36.52
        for <linux-mm@kvack.org>;
        Wed, 14 Sep 2016 02:36:52 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:36:34 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [kernel-hardening] [RFC PATCH v2 0/3] Add support for eXclusive
 Page Frame Ownership (XPFO)
Message-ID: <20160914093634.GB13121@leverpostej>
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160914071901.8127-1-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org, juerg.haefliger@hpe.com, vpk@cs.columbia.edu

Hi,

On Wed, Sep 14, 2016 at 09:18:58AM +0200, Juerg Haefliger wrote:

> This patch series adds support for XPFO which protects against 'ret2dir'
> kernel attacks. The basic idea is to enforce exclusive ownership of page
> frames by either the kernel or userspace, unless explicitly requested by
> the kernel. Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.

> Known issues/limitations:
>   - Only supports x86-64 (for now)
>   - Only supports 4k pages (for now)
>   - There are most likely some legitimate uses cases where the kernel needs
>     to access userspace which need to be made XPFO-aware
>   - Performance penalty
> 
> Reference paper by the original patch authors:
>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

Just to check, doesn't DEBUG_RODATA ensure that the linear mapping is
non-executable on x86_64 (as it does for arm64)?

For both arm64 and x86_64, DEBUG_RODATA is mandatory (or soon to be so).
Assuming that implies a lack of execute permission for x86_64, that
should provide a similar level of protection against erroneously
branching to addresses in the linear map, without the complexity and
overhead of mapping/unmapping pages.

So to me it looks like this approach may only be useful for
architectures without page-granular execute permission controls.

Is this also intended to protect against erroneous *data* accesses to
the linear map?

Am I missing something?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
