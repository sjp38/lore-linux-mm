Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81BDC6B027F
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 07:55:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e3-v6so2460197pld.13
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 04:55:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x2-v6si4443487pgr.432.2018.10.24.04.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 04:55:01 -0700 (PDT)
Date: Wed, 24 Oct 2018 04:54:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181024115447.GE25444@bombadil.infradead.org>
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
 <20181023163157.41441-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023163157.41441-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 23, 2018 at 07:31:56PM +0300, Kirill A. Shutemov wrote:
> -ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
> +ffff888000000000 - ffff887fffffffff (=39 bits) LDT remap for PTI

I'm a little bit cross-eyed at this point, but I think the above '888'
should be '880'.

> @@ -14,7 +15,6 @@ ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
>  ... unused hole ...
>  				    vaddr_end for KASLR
>  fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
> -fffffe8000000000 - fffffeffffffffff (=39 bits) LDT remap for PTI

... and the line above this one should be adjusted to finish at
fffffeffffffffff (also it's now 40 bits).  Or should there be something
else here?

>  ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
>  ... unused hole ...
>  ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
> @@ -30,8 +30,8 @@ Virtual memory map with 5 level page tables:
>  0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
>  hole caused by [56:63] sign extension
>  ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
> -ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
> -ff90000000000000 - ff9fffffffffffff (=52 bits) LDT remap for PTI
> +ff10000000000000 - ff10ffffffffffff (=48 bits) LDT remap for PTI
> +ff11000000000000 - ff90ffffffffffff (=55 bits) direct mapping of all phys. memory

What's at ff910..0 to ff9f..f ?

Is there any way we can generate this part of this file to prevent human
error from creeping in over time?  ;-)
