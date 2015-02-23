Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6401B6B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 15:22:27 -0500 (EST)
Received: by padfb1 with SMTP id fb1so30165765pad.8
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 12:22:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id np10si10928778pbc.145.2015.02.23.12.22.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 12:22:25 -0800 (PST)
Date: Mon, 23 Feb 2015 12:22:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/7] Kernel huge I/O mapping support
Message-Id: <20150223122224.c55554325cc4dadeca067234@linux-foundation.org>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Mon,  9 Feb 2015 15:45:28 -0700 Toshi Kani <toshi.kani@hp.com> wrote:

> ioremap() and its related interfaces are used to create I/O
> mappings to memory-mapped I/O devices.  The mapping sizes of
> the traditional I/O devices are relatively small.  Non-volatile
> memory (NVM), however, has many GB and is going to have TB soon.
> It is not very efficient to create large I/O mappings with 4KB. 

The changelogging is very good - thanks for taking the time to do this.

> This patchset extends the ioremap() interfaces to transparently
> create I/O mappings with huge pages whenever possible.

I'm wondering if this is prudent.  Existing code which was tested with
4k mappings will magically start to use huge tlb mappings.  I don't
know what could go wrong, but I'd prefer not to find out!  Wouldn't it
be safer to make this an explicit opt-in?

What operations can presently be performed against an ioremapped area? 
Can kernel code perform change_page_attr() against individual pages? 
Can kernel code run iounmap() against just part of that region (I
forget).  There does seem to be potential for breakage if we start
using hugetlb mappings for such things?

>  ioremap()
> continues to use 4KB mappings when a huge page does not fit into
> a requested range.  There is no change necessary to the drivers
> using ioremap().  A requested physical address must be aligned by
> a huge page size (1GB or 2MB on x86) for using huge page mapping,
> though.  The kernel huge I/O mapping will improve performance of
> NVM and other devices with large memory, and reduce the time to
> create their mappings as well.
> 
> On x86, the huge I/O mapping may not be used when a target range is
> covered by multiple MTRRs with different memory types.  The caller
> must make a separate request for each MTRR range, or the huge I/O
> mapping can be disabled with the kernel boot option "nohugeiomap".
> The detail of this issue is described in the email below, and this
> patch takes option C) in favor of simplicity since MTRRs are legacy
> feature.
>  https://lkml.org/lkml/2015/2/5/638

How is this mtrr clash handled?

- The iomap call will fail if there are any MTRRs covering the region?

- The iomap call will fail if there are more than one MTRRs covering
  the region?

- If the ioremap will succeed if a single MTRR covers the region,
  must that MTRR cover the *entire* region?

- What happens if userspace tried fiddling the MTRRs after the region
  has been established?

<reads the code>

Oh.  We don't do any checking at all.  We're just telling userspace
programmers "don't do that".  hrm.  What are your thoughts on adding
the overlap checks to the kernel?

This adds more potential for breaking existing code, doesn't it?  If
there's code which is using 4k ioremap on regions which are covered by
mtrrs, the transparent switch to hugeptes will cause that code to enter
the "undefined behaviour" space?

> The patchset introduces the following configs:
>  HUGE_IOMAP - When selected (default Y), enable huge I/O mappings.
>               Require HAVE_ARCH_HUGE_VMAP set.
>  HAVE_ARCH_HUGE_VMAP - Indicate arch supports huge KVA mappings.
>                        Require X86_PAE set on X86_32.
> 
> Patch 1-4 changes common files to support huge I/O mappings.  There
> is no change in the functinalities until HUGE_IOMAP is set in patch 7.
> 
> Patch 5,6 implement HAVE_ARCH_HUGE_VMAP and HUGE_IOMAP funcs on x86,
> and set HAVE_ARCH_HUGE_VMAP on x86.
> 
> Patch 7 adds HUGE_IOMAP to Kconfig, which is set to Y by default on
> x86.

What do other architectures need to do to utilize this?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
