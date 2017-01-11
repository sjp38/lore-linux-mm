Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F19D6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 14:31:27 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id q20so1660347ioi.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:31:27 -0800 (PST)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id m20si16343013ita.119.2017.01.11.11.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 11:31:26 -0800 (PST)
Received: by mail-io0-x244.google.com with SMTP id m98so158203iod.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:31:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrXDbkotCZ1WEbhNeYGt0zyKT42agzsFxT2SZJ4wadEnQA@mail.gmail.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com> <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com> <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com> <20170111142904.GD4895@node.shutemov.name>
 <CALCETrUn=KNdOnoRYd8GcnXPNDHAhGkaMaHRTAri4o92FSC1qg@mail.gmail.com>
 <20170111183750.GE4895@node.shutemov.name> <0a6f1ee4-e260-ae7b-3d39-c53f6bed8102@intel.com>
 <CALCETrXDbkotCZ1WEbhNeYGt0zyKT42agzsFxT2SZJ4wadEnQA@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Jan 2017 11:31:25 -0800
Message-ID: <CA+55aFyhva9bw48G669z4QfJXjjJA5s+necfWmYoAB6eyzea=A@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 11, 2017 at 11:20 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> Taking a step back, I think it would be fantastic if we could find a
> way to make this work without any inheritable settings at all.
> Perhaps we could have a per-mm value that is initialized to 2^47-1 on
> execve() and can be raised by ELF note or by prctl()?

I definitely think this is the right model. No inheritable settings,
no suid issues, no worries. Make people who want the large address
space (and there aren't going to be a lot of them) just mark their
binaries at compile time.

And as to the stack location: I think it should just be the same
regardless - up in "high" virtual memory in the 47-bit model. Because
as you say, if you actually end up having 57 bits of address space,
that still gives you basically the whole VM for data mappings -
they'll just be up above the stack.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
