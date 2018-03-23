Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACB936B0023
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 23:51:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y82-v6so2383078lfc.7
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:51:15 -0700 (PDT)
Received: from forward106p.mail.yandex.net (forward106p.mail.yandex.net. [77.88.28.109])
        by mx.google.com with ESMTPS id z4si2805444ljz.315.2018.03.22.20.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 20:51:10 -0700 (PDT)
Message-ID: <1521777055.1510.9.camel@flygoat.com>
Subject: Re: [PATCH V3] ZBOOT: fix stack protector in compressed boot phase
From: Jiaxun Yang <jiaxun.yang@flygoat.com>
Date: Fri, 23 Mar 2018 11:50:55 +0800
In-Reply-To: <20180322222107.GJ13126@saruman>
References: <1521186916-13745-1-git-send-email-chenhc@lemote.com>
	 <20180322222107.GJ13126@saruman>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, stable@vger.kernel.org

a?? 2018-03-22a??c?? 22:21 +0000i 1/4 ?James Hogana??e??i 1/4 ?
> On Fri, Mar 16, 2018 at 03:55:16PM +0800, Huacai Chen wrote:
> > diff --git a/arch/mips/boot/compressed/decompress.c
> > b/arch/mips/boot/compressed/decompress.c
> > index fdf99e9..5ba431c 100644
> > --- a/arch/mips/boot/compressed/decompress.c
> > +++ b/arch/mips/boot/compressed/decompress.c
> > @@ -78,11 +78,6 @@ void error(char *x)
> >  
> >  unsigned long __stack_chk_guard;
> 
> ...
> 
> > diff --git a/arch/mips/boot/compressed/head.S
> > b/arch/mips/boot/compressed/head.S
> > index 409cb48..00d0ee0 100644
> > --- a/arch/mips/boot/compressed/head.S
> > +++ b/arch/mips/boot/compressed/head.S
> > @@ -32,6 +32,10 @@ start:
> >  	bne	a2, a0, 1b
> >  	 addiu	a0, a0, 4
> >  
> > +	PTR_LA	a0, __stack_chk_guard
> > +	PTR_LI	a1, 0x000a0dff
> > +	sw	a1, 0(a0)
> 

Hi James

Huacai Can't reply this mail. His chenhc@lemote.com is blcoked by
Linux-MIPS mailing list while his Gmail didn't receive this email, so
I'm replying for him.

> Should that not be LONG_S? Otherwise big endian MIPS64 would get a
> word-swapped canary (which is probably mostly harmless, but still).

Yes, he said it's considerable.

> 
> Also I think it worth mentioning in the commit message the MIPS
> configuration you hit this with, presumably a Loongson one? For me
> decompress_kernel() gets a stack guard on loongson3_defconfig, but
> not
> malta_defconfig or malta_defconfig + 64-bit. I presume its sensitive
> to
> the compiler inlining stuff into decompress_kernel() or something
> such
> that it suddenly qualifies for a stack guard.

Have you tested with CONFIG_CC_STACKPROTECTOR_STRONG=y ?
Huacai reproduced the issue by this[1] config with GCC 4.9.

[1] https://github.com/loongson-community/linux-stable/blob/rebase-4.14
/arch/mips/configs/loongson3_defconfig

> 
> Cheers
> James
