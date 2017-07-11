Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB1666B04DD
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 06:35:53 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 29so28945409lfw.5
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:35:53 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id c26si5917344ljb.88.2017.07.11.03.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 03:35:51 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id f28so13791628lfi.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 03:35:51 -0700 (PDT)
Date: Tue, 11 Jul 2017 13:35:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Message-ID: <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
References: <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com>
 <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
 <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com>
 <20170710141713.7aox3edx6o7lrrie@node.shutemov.name>
 <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
 <20170710184704.realchrhzpblqqlk@node.shutemov.name>
 <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
 <20170710212403.7ycczkhhki3vrgac@node.shutemov.name>
 <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Jul 10, 2017 at 05:30:38PM -0700, Andy Lutomirski wrote:
> On Mon, Jul 10, 2017 at 2:24 PM, Kirill A. Shutemov
> <kirill@shutemov.name> wrote:
> > On Mon, Jul 10, 2017 at 01:07:13PM -0700, Andy Lutomirski wrote:
> >> Can you give the disassembly of the backtrace lines?  Blaming the
> >> .endr doesn't make much sense to me.
> >
> > I don't have backtrace. It's before printk() is functional. I only see
> > triple fault and reboot.
> >
> > I had to rely on qemu tracing and gdb.
> 
> Can you ask GDB or objtool to disassemble around those addresses?  Can
> you also attach the big dump that QEMU throws out that shows register
> state?  In particular, CR2, CR3, and CR4 could be useful.

The last three execptions:

check_exception old: 0xffffffff new 0xe, cr2: 0xffffffff7ffffff8, rip: 0xffffffff84bb3036
RAX=00000000ffffffff RBX=ffffffff800000d8 RCX=ffffffff84be4021 RDX=dffffc0000000000
RSI=0000000000000006 RDI=ffffffff84c57000 RBP=ffffffff800000c8 RSP=ffffffff80000000
R8 =6d756e2032616476 R9 =2f7665642f3d746f R10=6f72203053797474 R11=3d656c6f736e6f63
R12=0000000000000006 R13=000000003fffb000 R14=ffffffff82a07ed8 R15=000000000140008e
RIP=ffffffff84bb3036 RFL=00000006 [-----P-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0000 0000000000000000 00000000 00000000
CS =0010 0000000000000000 ffffffff 00af9b00 DPL=0 CS64 [-RA]
SS =0000 0000000000000000 ffffffff 00c09300 DPL=0 DS   [-WA]
DS =0000 0000000000000000 00000000 00000000
FS =0000 0000000000000000 00000000 00000000
GS =0000 ffffffff84b8f000 00000000 00000000
LDT=0000 0000000000000000 0000ffff 00008200 DPL=0 LDT
TR =0000 0000000000000000 0000ffff 00008b00 DPL=0 TSS64-busy
GDT=     ffffffff84ba1000 0000007f
IDT=     ffffffff84d92000 00000fff
CR0=80050033 CR2=ffffffff7ffffff8 CR3=0000000009c58000 CR4=000010a0
DR0=0000000000000000 DR1=0000000000000000 DR2=0000000000000000 DR3=0000000000000000
DR6=00000000ffff0ff0 DR7=0000000000000400
EFER=0000000000000d01

check_exception old: 0xe new 0xe, cr2: 0xffffffff7ffffff8, rip: 0xffffffff84bb3141
RAX=00000000ffffffff RBX=ffffffff800000d8 RCX=ffffffff84be4021 RDX=dffffc0000000000
RSI=0000000000000006 RDI=ffffffff84c57000 RBP=ffffffff800000c8 RSP=ffffffff80000000
R8 =6d756e2032616476 R9 =2f7665642f3d746f R10=6f72203053797474 R11=3d656c6f736e6f63
R12=0000000000000006 R13=000000003fffb000 R14=ffffffff82a07ed8 R15=000000000140008e
RIP=ffffffff84bb3141 RFL=00000006 [-----P-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0000 0000000000000000 00000000 00000000
CS =0010 0000000000000000 ffffffff 00af9b00 DPL=0 CS64 [-RA]
SS =0000 0000000000000000 ffffffff 00c09300 DPL=0 DS   [-WA]
DS =0000 0000000000000000 00000000 00000000
FS =0000 0000000000000000 00000000 00000000
GS =0000 ffffffff84b8f000 00000000 00000000
LDT=0000 0000000000000000 0000ffff 00008200 DPL=0 LDT
TR =0000 0000000000000000 0000ffff 00008b00 DPL=0 TSS64-busy
GDT=     ffffffff84ba1000 0000007f
IDT=     ffffffff84d92000 00000fff
CR0=80050033 CR2=ffffffff7ffffff8 CR3=0000000009c58000 CR4=000010a0
DR0=0000000000000000 DR1=0000000000000000 DR2=0000000000000000 DR3=0000000000000000
DR6=00000000ffff0ff0 DR7=0000000000000400
EFER=0000000000000d01

check_exception old: 0x8 new 0xe, cr2: 0xffffffff7ffffff8, rip: 0xffffffff84bb3141
RAX=00000000ffffffff RBX=ffffffff800000d8 RCX=ffffffff84be4021 RDX=dffffc0000000000
RSI=0000000000000006 RDI=ffffffff84c57000 RBP=ffffffff800000c8 RSP=ffffffff80000000
R8 =6d756e2032616476 R9 =2f7665642f3d746f R10=6f72203053797474 R11=3d656c6f736e6f63
R12=0000000000000006 R13=000000003fffb000 R14=ffffffff82a07ed8 R15=000000000140008e
RIP=ffffffff84bb3141 RFL=00000006 [-----P-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0000 0000000000000000 00000000 00000000
CS =0010 0000000000000000 ffffffff 00af9b00 DPL=0 CS64 [-RA]
SS =0000 0000000000000000 ffffffff 00c09300 DPL=0 DS   [-WA]
DS =0000 0000000000000000 00000000 00000000
FS =0000 0000000000000000 00000000 00000000
GS =0000 ffffffff84b8f000 00000000 00000000
LDT=0000 0000000000000000 0000ffff 00008200 DPL=0 LDT
TR =0000 0000000000000000 0000ffff 00008b00 DPL=0 TSS64-busy
GDT=     ffffffff84ba1000 0000007f
IDT=     ffffffff84d92000 00000fff
CR0=80050033 CR2=ffffffff7ffffff8 CR3=0000000009c58000 CR4=000010a0
DR0=0000000000000000 DR1=0000000000000000 DR2=0000000000000000 DR3=0000000000000000
DR6=00000000ffff0ff0 DR7=0000000000000400
EFER=0000000000000d01
Triple fault

Dump of assembler code for function early_idt_handler_array:
   0xffffffff84bb3000 <+0>:     pushq  $0x0
   0xffffffff84bb3002 <+2>:     pushq  $0x0
   0xffffffff84bb3004 <+4>:     jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb3009 <+9>:     pushq  $0x0
   0xffffffff84bb300b <+11>:    pushq  $0x1
   0xffffffff84bb300d <+13>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb3012 <+18>:    pushq  $0x0
   0xffffffff84bb3014 <+20>:    pushq  $0x2
   0xffffffff84bb3016 <+22>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb301b <+27>:    pushq  $0x0
   0xffffffff84bb301d <+29>:    pushq  $0x3
   0xffffffff84bb301f <+31>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb3024 <+36>:    pushq  $0x0
   0xffffffff84bb3026 <+38>:    pushq  $0x4
   0xffffffff84bb3028 <+40>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb302d <+45>:    pushq  $0x0
   0xffffffff84bb302f <+47>:    pushq  $0x5
   0xffffffff84bb3031 <+49>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
=> 0xffffffff84bb3036 <+54>:    pushq  $0x0
   0xffffffff84bb3038 <+56>:    pushq  $0x6
   0xffffffff84bb303a <+58>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb303f <+63>:    pushq  $0x0
   0xffffffff84bb3041 <+65>:    pushq  $0x7
   0xffffffff84bb3043 <+67>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb3048 <+72>:    pushq  $0x8
   0xffffffff84bb304a <+74>:    jmpq   0xffffffff84bb3120 <early_idt_handler_common>
   0xffffffff84bb304f <+79>:    int3
   0xffffffff84bb3050 <+80>:    int3
...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
