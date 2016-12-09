Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC1206B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 06:33:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so16459084pfk.3
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 03:33:16 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30137.outbound.protection.outlook.com. [40.107.3.137])
        by mx.google.com with ESMTPS id n3si33452320plb.230.2016.12.09.03.33.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 03:33:15 -0800 (PST)
Subject: Re: [PATCH] x86/coredump: always use user_regs_struct for
 compat_elf_gregset_t
References: <20161123181330.10705-1-dsafonov@virtuozzo.com>
 <CALCETrUQDBX_QqHGeozQ3Q+9pF3SeyE9XyPqX4M6k3XOV8Zd=Q@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <eed6e3e2-f825-2ad8-9175-0c69c52809d9@virtuozzo.com>
Date: Fri, 9 Dec 2016 14:29:55 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrUQDBX_QqHGeozQ3Q+9pF3SeyE9XyPqX4M6k3XOV8Zd=Q@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <0x7f454c46@gmail.com>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>

On 12/09/2016 02:14 AM, Andy Lutomirski wrote:
> On Nov 23, 2016 10:16 AM, "Dmitry Safonov" <dsafonov@virtuozzo.com> wrote:
>>
>> From commit 90954e7b9407 ("x86/coredump: Use pr_reg size, rather that
>> TIF_IA32 flag") elf coredump file is constructed according to register
>> set size - and that's good: if binary crashes with 32-bit code selector,
>> generate 32-bit ELF core, otherwise - 64-bit core.
>> That was made for restoring 32-bit applications on x86_64: we want
>> 32-bit application after restore to generate 32-bit ELF dump on crash.
>> All was quite good and recently I started reworking 32-bit applications
>> dumping part of CRIU: now it has two parasites (32 and 64) for seizing
>> compat/native tasks, after rework it'll have one parasite, working in
>> 64-bit mode, to which 32-bit prologue long-jumps during infection.
>>
>> And while it has worked for my work machine, in VM with
>> !CONFIG_X86_X32_ABI during reworking I faced that segfault in 32-bit
>> binary, that has long-jumped to 64-bit mode results in dereference
>> of garbage:
>
> Can you point to the actual line that's crashing?  I'm wondering if we
> have code that should be made more robust.

Hi Andy,

Here it is:

 > static int fill_thread_core_info(struct elf_thread_core_info *t,
 > 				 const struct user_regset_view *view,
 > 				 long signr, size_t *total)
 > {
 > 	unsigned int i;
 > 	unsigned int regset_size = view->regsets[0].n * view->regsets[0].size;

For now the regset_size is 64-bit registers set's size if 32-bit ELF
crashed with 64-bit CS.

 >
 > 	/*
 > 	 * NT_PRSTATUS is the one special case, because the regset data
 > 	 * goes into the pr_reg field inside the note contents, rather
 > 	 * than being the whole note contents.  We fill the reset in here.
 > 	 * We assume that regset 0 is NT_PRSTATUS.
 > 	 */
 > 	fill_prstatus(&t->prstatus, t->task, signr);
 > 	(void) view->regsets[0].get(t->task, &view->regsets[0], 0, regset_size,
 > 				    &t->prstatus.pr_reg, NULL);

And here is writing to elf_thread_core_info::prstatus::pr_reg,
prstatus member is typed compat_elf_prstatus as binfmt_elf
interpreter that was used to load the program is from
fs/compat_binfmt_elf.c:
 > #define elf_prstatus	compat_elf_prstatus
 > #define elf_prpsinfo	compat_elf_prpsinfo

So, we're overwriting elf_thread_core_info structure's content by
writing bigger regset than it can hold.
(.get() method is genregs_get() from arch/x86/kernel/ptrace.c)

The crash happens afterwards, when we're trying to dereference some
fields of elf_thread_core_info - for me it was as you can see in
writenote():
   [<ffffffff811d6929>] ? writenote+0x19/0xa0
   [<ffffffff811d9479>] elf_core_dump+0x11a9/0x1480
   [<ffffffff811dc70b>] do_coredump+0xa6b/0xe60
   [<ffffffff81065820>] ? signal_wake_up_state+0x20/0x30
   [<ffffffff81065941>] ? complete_signal+0xf1/0x1f0
   [<ffffffff810679e8>] get_signal+0x1a8/0x5c0
   [<ffffffff8101b1a3>] do_signal+0x23/0x660

In my point of view 64-bit regset is generated rightly - otherwise
I couldn't see x86_64 registers in gdb for that kind of crashes.
So, I fixed it as simple as possible - by having one size for
compat_elf_gregset_t independent of CONFIG_X86_X32_ABI option.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
