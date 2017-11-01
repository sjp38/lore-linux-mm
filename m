Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 802046B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 14:27:34 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 189so9614159iow.8
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 11:27:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11sor613765iod.341.2017.11.01.11.27.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 11:27:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com> <CA+55aFypdyt+3-JyD3U1da5EqznncxKZZKPGn4ykkD=4Q4rdvw@mail.gmail.com>
 <8bacac66-7d3e-b15d-a73b-92c55c0b1908@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Nov 2017 11:27:32 -0700
Message-ID: <CA+55aFxssHiO4f52UUCPXoxx+NOu5Epf6HhwsjUH8Ua+BP6Y=A@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 1, 2017 at 10:31 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> I assume that you're really worried about having to go two places to do
> one thing, like clearing a dirty bit, or unmapping a PTE, especially
> when we have to do that for userspace.  Thankfully, the sharing of the
> page tables (under the PGD) for userspace gets rid of most of this
> nastiness.

Right. That's the primary thing, and just clarifying that this is for
kernel addresses only will help at least some.

But even for the kernel case, it worries me a bit. We have much fewer
coherency issues for the kernel, but we do end up having some cases
that modify kernel mappings too. Most notably there are the
cacheability things where we've had machine check exceptions when the
same page is mapped non-cachable in user space and cacheable in kernel
space, which ends up causing  all that pain we have in
arch/x86/mm/pageattr.c.

I very much think you limit the pages that get mapped in the shadow
page tables to the point where this shouldn't be an issue, but at the
same time, I very much do want people to be aware of it and this be
commented very clearly in the code.

Honestly, the code looks like it is designed to, and can, map
arbitrary physical pages at arbitrary virtual addresses. And that is
NOT RIGHT.

So I'd like to see not just the comments about this, but I'd like to
see the code itself actually making that very clear. Have *code* that
verifies that nobody ever tries to use this on a user address (because
that would *completely* screw up all coherency), but also I don't see
why the code possibly looks up the old physical address in ther page
table. Is there _any_ possible reason why you'd want to look up a page
from an old page table? As far as I can tell, we should always know
the physical page we are mapping a priori - we've never re-mapping
random virtual addresses or a highmem page or anything like that.
We're mapping the 1:1 kernel mapping only.

So the code really looks much too generic to me. It seems to be
designed to be used for cases where it simply could not *possibly* be
valid to use.

There's a disease in computer science that thinks that "generic code"
is somehow better code. That's not the case. We aren't mapping generic
pages, and must not map them or let make people make that mistake. I'd
*much* rather the code make it very clear that it's not generic code
in any way shape or form.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
