Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 425706B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 22:52:51 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xy5so2288236wjc.0
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 19:52:51 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id xw2si32198769wjc.22.2016.12.08.19.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 19:52:49 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id j10so613800wjb.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 19:52:49 -0800 (PST)
Date: Fri, 9 Dec 2016 04:52:46 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/coredump: always use user_regs_struct for
 compat_elf_gregset_t
Message-ID: <20161209035246.GB30637@gmail.com>
References: <20161123181330.10705-1-dsafonov@virtuozzo.com>
 <CALCETrUQDBX_QqHGeozQ3Q+9pF3SeyE9XyPqX4M6k3XOV8Zd=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUQDBX_QqHGeozQ3Q+9pF3SeyE9XyPqX4M6k3XOV8Zd=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Nov 23, 2016 10:16 AM, "Dmitry Safonov" <dsafonov@virtuozzo.com> wrote:
> >
> > From commit 90954e7b9407 ("x86/coredump: Use pr_reg size, rather that
> > TIF_IA32 flag") elf coredump file is constructed according to register
> > set size - and that's good: if binary crashes with 32-bit code selector,
> > generate 32-bit ELF core, otherwise - 64-bit core.
> > That was made for restoring 32-bit applications on x86_64: we want
> > 32-bit application after restore to generate 32-bit ELF dump on crash.
> > All was quite good and recently I started reworking 32-bit applications
> > dumping part of CRIU: now it has two parasites (32 and 64) for seizing
> > compat/native tasks, after rework it'll have one parasite, working in
> > 64-bit mode, to which 32-bit prologue long-jumps during infection.
> >
> > And while it has worked for my work machine, in VM with
> > !CONFIG_X86_X32_ABI during reworking I faced that segfault in 32-bit
> > binary, that has long-jumped to 64-bit mode results in dereference
> > of garbage:
> 
> Can you point to the actual line that's crashing?  I'm wondering if we
> have code that should be made more robust.

Agreed. Note that because it fixes a crash this fix is now upstream:

 Commit-ID:  7b2dd3682896bcf1abbbbe870885728db2832a3c
 Gitweb:     http://git.kernel.org/tip/7b2dd3682896bcf1abbbbe870885728db2832a3c
 Author:     Dmitry Safonov <dsafonov@virtuozzo.com>
 AuthorDate: Wed, 23 Nov 2016 21:13:30 +0300
 Committer:  Ingo Molnar <mingo@kernel.org>
 CommitDate: Thu, 24 Nov 2016 06:01:05 +0100

 x86/coredump: Always use user_regs_struct for compat_elf_gregset_t

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
