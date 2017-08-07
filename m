Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 948436B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:49:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v11so959595oif.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:49:02 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id o82si4882460oif.180.2017.08.07.11.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:49:01 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id r9so958167ita.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:49:01 -0700 (PDT)
Message-ID: <1502131739.1803.12.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 14:48:59 -0400
In-Reply-To: <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
	 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
	 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
	 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>, Kostya Serebryany <kcc@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

On Mon, 2017-08-07 at 11:39 -0700, Kees Cook wrote:
> On Mon, Aug 7, 2017 at 11:26 AM, Kostya Serebryany <kcc@google.com>
> wrote:
> > +eugenis@ for msan
> > 
> > On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook <keescook@google.com>
> > wrote:
> > > 
> > > On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com
> > > > wrote:
> > > > The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> > > > 
> > > > https://github.com/torvalds/linux/commit/eab09532d40090698b05a07
> > > > c1c87f39fdbc5fab5
> > > > breaks user-space AddressSanitizer. AddressSanitizer makes
> > > > assumptions
> > > > about address space layout for substantial performance gains.
> > > > There
> > > > are multiple people complaining about this already:
> > > > https://github.com/google/sanitizers/issues/837
> > > > https://twitter.com/kayseesee/status/894594085608013825
> > > > https://bugzilla.kernel.org/show_bug.cgi?id=196537
> > > > AddressSanitizer maps shadow memory at [0x00007fff7000-
> > > > 0x10007fff7fff]
> > > > expecting that non-pie binaries will be below 2GB and pie
> > > > binaries/modules will be at 0x55 or 0x7f. This is not the first
> > > > time
> > > > kernel address space shuffling breaks sanitizers. The last one
> > > > was the
> > > > move to 0x55.
> > > 
> > > What are the requirements for 32-bit and 64-bit memory layouts for
> > > ASan currently, so we can adjust the ET_DYN base to work with
> > > existing
> > > ASan?
> > 
> > 
> > 32-bit asan shadow is 0x20000000 - 0x40000000
> > 
> > % clang -fsanitize=address dummy.c -m32 && ASAN_OPTIONS=verbosity=1
> > ./a.out
> > 2>&1 | grep '||'
> > > > `[0x40000000, 0xffffffff]` || HighMem    ||
> > > > `[0x28000000, 0x3fffffff]` || HighShadow ||
> > > > `[0x24000000, 0x27ffffff]` || ShadowGap  ||
> > > > `[0x20000000, 0x23ffffff]` || LowShadow  ||
> > > > `[0x00000000, 0x1fffffff]` || LowMem     ||
> > 
> > %
> 
> For 32-bit, it looks like the new PIE base is fine, yes? 0x000400000UL

Need to consider the ASLR shift which is up to 1M with a default kernel
configuration but up to 256M with the maximum configurable entropy.

On 64-bit, it's a lot larger... and the goal is also tying the stack
base to that so that's a further significant change, increasing the
address space used when the maximum configurable entropy is used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
