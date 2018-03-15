Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C03EF6B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 13:08:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q2so3153636pgn.22
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 10:08:38 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t2-v6si4121226plo.130.2018.03.15.10.08.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Mar 2018 10:08:37 -0700 (PDT)
Date: Thu, 15 Mar 2018 10:08:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: rfc: remove print_vma_addr ? (was Re: [PATCH 00/16] remove eight
 obsolete architectures)
Message-ID: <20180315170830.GA17574@bombadil.infradead.org>
References: <20180314143529.1456168-1-arnd@arndb.de>
 <2929.1521106970@warthog.procyon.org.uk>
 <CAMuHMdXcxuzCOnFCNm4NXDv-wfYJDO5GQpB_ECu7j=2BjMhNpA@mail.gmail.com>
 <1521133006.22221.35.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521133006.22221.35.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Linux-Arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, Linux PWM List <linux-pwm@vger.kernel.org>, linux-rtc@vger.kernel.org, linux-spi <linux-spi@vger.kernel.org>, USB list <linux-usb@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux Fbdev development list <linux-fbdev@vger.kernel.org>, Linux Watchdog Mailing List <linux-watchdog@vger.kernel.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Mar 15, 2018 at 09:56:46AM -0700, Joe Perches wrote:
> I have a patchset that creates a vsprintf extension for
> print_vma_addr and removes all the uses similar to the
> print_symbol() removal.
> 
> This now avoids any possible printk interleaving.
> 
> Unfortunately, without some #ifdef in vsprintf, which
> I would like to avoid, it increases the nommu kernel
> size by ~500 bytes.
> 
> Anyone think this is acceptable?
> 
> Here's the overall patch, but I have it as a series
> ---
>  Documentation/core-api/printk-formats.rst |  9 +++++
>  arch/arm64/kernel/traps.c                 | 13 +++----
>  arch/mips/mm/fault.c                      | 16 ++++-----
>  arch/parisc/mm/fault.c                    | 15 ++++----
>  arch/riscv/kernel/traps.c                 | 11 +++---
>  arch/s390/mm/fault.c                      |  7 ++--
>  arch/sparc/mm/fault_32.c                  |  8 ++---
>  arch/sparc/mm/fault_64.c                  |  8 ++---
>  arch/tile/kernel/signal.c                 |  9 ++---
>  arch/um/kernel/trap.c                     | 13 +++----
>  arch/x86/kernel/signal.c                  | 10 ++----
>  arch/x86/kernel/traps.c                   | 18 ++++------
>  arch/x86/mm/fault.c                       | 12 +++----
>  include/linux/mm.h                        |  1 -
>  lib/vsprintf.c                            | 58 ++++++++++++++++++++++++++-----
>  mm/memory.c                               | 33 ------------------
>  16 files changed, 112 insertions(+), 129 deletions(-)

This doesn't feel like a huge win since it's only called ~once per
architecture.  I'd be more excited if it made the printing of the whole
thing standardised; eg we have a print_fault() function in mm/memory.c
which takes a suitable set of arguments.
