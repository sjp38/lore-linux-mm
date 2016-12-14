Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69E3C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 18:50:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so66189741pgc.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 15:50:35 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s15si55007210pfg.96.2016.12.14.15.50.33
        for <linux-mm@kvack.org>;
        Wed, 14 Dec 2016 15:50:34 -0800 (PST)
Date: Thu, 15 Dec 2016 08:50:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: jemalloc testsuite stalls in memset
Message-ID: <20161214235031.GA2912@bbox>
References: <mvmmvfy37g1.fsf@hawking.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <mvmmvfy37g1.fsf@hawking.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mbrugger@suse.de, linux-mm@kvack.org, Jason Evans <je@fb.com>

Hello,

First of all, thanks for the report and sorry I have no time now so maybe
I should investigate the problem next week.

On Wed, Dec 14, 2016 at 03:34:54PM +0100, Andreas Schwab wrote:
> When running the jemalloc-4.4.0 testsuite on aarch64 with glibc 2.24 the
> test/unit/junk test hangs in memset:
> 
> (gdb) r
> Starting program: /tmp/jemalloc/jemalloc-4.4.0/test/unit/junk
> [Thread debugging using libthread_db enabled]
> Using host libthread_db library "/lib64/libthread_db.so.1".
> test_junk_small: pass
> test_junk_large: pass
> ^C
> Program received signal SIGINT, Interrupt.
> memset () at ../sysdeps/aarch64/memset.S:91
> 91              str     q0, [dstin]
> (gdb) x/i $pc
> => 0xffffb7ddf54c <memset+140>: str     q0, [x0]
> 
> x0 is pointing to the start of this mmap'd block:
> 
>       0xffffb7400000     0xffffb7600000   0x200000        0x0
> 
> Any attempt to contine execution or step over the insn still causes the
> process to hang here.  Only after accessing the memory through the
> debugger the test successfully continues to completion.

You mean program itself access the address(ie, 0xffffb7400000) is hang
while access the address from the debugger is OK?

Scratch head. :/

Can you reproduce it easily?
Did you test it in real machine or qemu on x86?
Could you show me how I can reproduce it?
I want to test it in x86 machine, first of all.
Unfortunately, I don't have any aarch64 platform now so maybe I have to
run it on qemu on x86 until I can set up aarch64 platform if it is reproducible
on real machine only.

> 
> The kernel has been configured with transparent hugepages.
> 
> CONFIG_TRANSPARENT_HUGEPAGE=y
> CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> # CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
> CONFIG_TRANSPARENT_HUGE_PAGECACHE=y

What's the exact kernel version?
I don't think it's HUGE_PAGECACHE problem but to narrow down the scope,
could you test it without CONFIG_TRANSPARENT_HUGE_PAGECACHE?

Thanks.

> 
> This issue has been bisected to commit
> b8d3c4c3009d42869dc03a1da0efc2aa687d0ab4 ("mm/huge_memory.c: don't split
> THP page when MADV_FREE syscall is called").
> 
> Andreas.
> 
> -- 
> Andreas Schwab, SUSE Labs, schwab@suse.de
> GPG Key fingerprint = 0196 BAD8 1CE9 1970 F4BE  1748 E4D4 88E3 0EEA B9D7
> "And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
