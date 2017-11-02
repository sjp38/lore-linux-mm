Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3216B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 05:42:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so4743749pff.18
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:42:10 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f7si2923456pgq.406.2017.11.02.02.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 02:42:09 -0700 (PDT)
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0FEE821949
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:42:09 +0000 (UTC)
Received: by mail-io0-f173.google.com with SMTP id h70so12523780ioi.4
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:42:09 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 2 Nov 2017 02:41:47 -0700
Message-ID: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com>
Subject: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce
 user-mapped percpu areas)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>

On Tue, Oct 31, 2017 at 3:31 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> These patches are based on work from a team at Graz University of
> Technology posted here: https://github.com/IAIK/KAISER
>

I think we're far enough along here that it may be time to nail down
the memory layout for real.  I propose the following:

The user tables will contain the following:

 - The GDT array.
 - The IDT.
 - The vsyscall page.  We can make this be _PAGE_USER.
 - The TSS.
 - The per-cpu entry stack.  Let's make it one page with guard pages
on either side.  This can replace rsp_scratch.
 - cpu_current_top_of_stack.  This could be in the same page as the TSS.
 - The entry text.
 - The percpu IST (aka "EXCEPTION") stacks.

That's it.

We can either try to move all of the above into the fixmap or we can
have the user tables be sparse a la Dave's current approach.  If we do
it the latter way, I think we'll want to add a mechanism to have holes
in the percpu space to give the entry stack a guard page.

I would *much* prefer moving everything into the fixmap, but that's a
wee bit awkward because we can't address per-cpu data in the fixmap
using %gs, which makes the SYSCALL code awkward.  But we could alias
the SYSCALL entry text itself per-cpu into the fixmap, which lets us
use %rip-relative addressing, which is quite nice.

So I guess my preference is to actually try the fixmap approach.  We
give the TSS the same aliasing treatment we gave the GDT, and I can
try to make the entry trampoline work through the fixmap and thus not
need %gs-based addressing until CR3 gets updated.  (This actually
saves several cycles of latency.)

What do you all think?

I'll deal with the LDT separately.  It will either live in the
fixmap-like region or it will live at the top of the user address
space.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=x86/entry_consolidation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
