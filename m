Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C83A6B0670
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 17:01:58 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h5-v6so11030099wrt.7
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 14:01:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v3-v6sor4027987wrw.43.2018.11.08.14.01.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 14:01:56 -0800 (PST)
MIME-Version: 1.0
References: <20181011151523.27101-1-yu-cheng.yu@intel.com> <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com> <20181108213126.GD13195@uranus.lan>
In-Reply-To: <20181108213126.GD13195@uranus.lan>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 8 Nov 2018 14:01:42 -0800
Message-ID: <CALCETrXNt6nEMu9bbK7GizoeC+rphi8ZK0dDsHiVgOCQj1eQEA@mail.gmail.com>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Thu, Nov 8, 2018 at 1:31 PM Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>
> On Thu, Nov 08, 2018 at 01:22:54PM -0800, Andy Lutomirski wrote:
> > > >
> > > > Why are these __packed?  It seems like it'll generate bad code for no
> > > > obvious purpose.
> > >
> > > That prevents any possibility that the compiler will insert padding, although in
> > > 64-bit kernel this should not happen to either struct.  Also all xstate
> > > components here are packed.
> > >
> >
> > They both seem like bugs, perhaps.  As I understand it, __packed
> > removes padding, but it also forces the compiler to expect the fields
> > to be unaligned even if they are actually aligned.
>
> How is that? Andy, mind to point where you get that this
> attribute forces compiler to make such assumption?

It's from memory.  But gcc seems to agree with me I compiled this:

struct foo {
    int x;
} __attribute__((packed));

int read_foo(struct foo *f)
{
    return f->x;
}

int align_of_foo_x(struct foo *f)
{
    return __alignof__(f->x);
}

Compiling with -O2 gives:

    .globl    read_foo
    .type    read_foo, @function
read_foo:
    movl    (%rdi), %eax
    ret
    .size    read_foo, .-read_foo

    .p2align 4,,15
    .globl    align_of_foo_x
    .type    align_of_foo_x, @function
align_of_foo_x:
    movl    $1, %eax
    ret
    .size    align_of_foo_x, .-align_of_foo_x

So gcc thinks that the x field is one-byte-aligned, but the code is
okay (at least in this instance) on x86.
Building for armv5 gives:

    .type    read_foo, %function
read_foo:
    @ args = 0, pretend = 0, frame = 0
    @ frame_needed = 0, uses_anonymous_args = 0
    @ link register save eliminated.
    ldrb    r3, [r0]    @ zero_extendqisi2
    ldrb    r1, [r0, #1]    @ zero_extendqisi2
    ldrb    r2, [r0, #2]    @ zero_extendqisi2
    orr    r3, r3, r1, lsl #8
    ldrb    r0, [r0, #3]    @ zero_extendqisi2
    orr    r3, r3, r2, lsl #16
    orr    r0, r3, r0, lsl #24
    bx    lr
    .size    read_foo, .-read_foo
    .align    2
    .global    align_of_foo_x
    .syntax unified
    .arm
    .fpu vfpv3-d16
    .type    align_of_foo_x, %function

So I'm pretty sure I'm right.
