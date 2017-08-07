Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEEB6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:38:16 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id k82so939418oih.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:38:16 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id k84si4925061oia.9.2017.08.07.11.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:38:15 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id 77so943313itj.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:38:15 -0700 (PDT)
Message-ID: <1502131092.1803.8.camel@gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
From: Daniel Micay <danielmicay@gmail.com>
Date: Mon, 07 Aug 2017 14:38:12 -0400
In-Reply-To: <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
References: 
	<CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
	 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
	 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>, Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, eugenis@google.com

> ASan already has the dynamic shadow as an option, and it's default
> mode
> on 64-bit windows, where the kernel is actively hostile to asan. 
> On Linux, we could enable it by
>   clang -fsanitize=address -O dummy.cc -mllvm -asan-force-dynamic-
> shadow=1
> (not heavily tested though). 
> 
> The problem is that this comes at a cost that we are very reluctant to
> pay. 
> Dynamic shadow means one extra load and one extra register stolen per
> function, 
> which increases the CPU usage and code size.

Can libraries compiled with dynamic be mixed with an executable or other
shared objects without it?

It could be the default with -fPIC / -fPIE without changing the default
for position dependent executables. Code isn't really PIC if it can't be
mapped within a large range. The performance hit would be paid by people
using dynamic libraries + PIE by default, but not non-PIE executables
and static libraries (unless they get compiled with -fPIC to allow
linking in a dynamic library, which is uncommon).

I'm sure a fix can be found either in the kernel or the sanitizers for
this specific PIE base move, but the problem isn't limited to this.

There are currently other issues. Try:

sysctl vm.mmap_rnd_bits=32
sysctl vm.mmap_rnd_compat_bits=16

IIRC that breaks some sanitizers at least for 32-bit executables.

Similar issues happen with certain arm64 address space configs since it
offers a bunch of choices (3 vs. 4 level page tables, different page
sizes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
