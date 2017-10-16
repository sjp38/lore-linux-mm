Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF5A56B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 09:12:40 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m81so13078532ioi.3
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 06:12:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor4201662itr.90.2017.10.16.06.12.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 06:12:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171016085540.tn2tf4hgpeotvvon@node.shutemov.name>
References: <20171013122345.86304-1-kirill.shutemov@linux.intel.com>
 <CAMzpN2iU07o8rBzZMpDv1gB00HUc2CRR1o3m=EuiQ6E16QcPFg@mail.gmail.com> <20171016085540.tn2tf4hgpeotvvon@node.shutemov.name>
From: Brian Gerst <brgerst@gmail.com>
Date: Mon, 16 Oct 2017 09:12:38 -0400
Message-ID: <CAMzpN2hLiyoAMXQFcDR2OuADoSzjo+TWQQSUmYsSJQtt81H8rA@mail.gmail.com>
Subject: Re: [PATCHv2, RFC] x86/boot/compressed/64: Handle 5-level paging boot
 if kernel is above 4G
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, the arch/x86 maintainers <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Oct 16, 2017 at 4:55 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sat, Oct 14, 2017 at 01:19:08PM -0400, Brian Gerst wrote:
>> From what we've seen with the TLB flush rework, having potential
>> garbage in the page tables that speculative reads can see can cause
>> bad things like machine checks.  It would be best to have a second
>> temporary page just for the page table (and properly cleared).
>
> Hm. Interesting. Is there a place where I can read more about this?

I believe this thread was where it was first reported:
https://lkml.org/lkml/2017/9/5/152

>> The trampoline also needs its own stack, in case the stack pointer was
>> above 4G.
>
> You are right, we need new stack. I've missed that.
>
>> That could be at the end of the code page, since you only need 8 bytes.
>
> When I wrote about 8 bytes, I referred the usage of page table, not code.
> We use more than 8 bytes of code, but this should enough in the page.

What I meant was, on one page, have the code at the start of the page,
and the stack at the end.  You only need 8 bytes of stack to push the
far pointer to return to 64-bit mode.  The page table would be on the
second page.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
