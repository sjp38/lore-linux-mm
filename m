Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D95916B0271
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:27:38 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i38so2577724iod.10
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:27:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r187sor1720468ith.57.2017.10.31.16.27.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 16:27:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
References: <20171031223146.6B47C861@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Oct 2017 16:27:36 -0700
Message-ID: <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

Inconveniently, the people you cc'd on the actual patches did *not*
get cc'd with this 00/23 cover letter email.

Also, the documentation was then hidden in patch 07/23, which wasn't
exactly obvious.

So I'd like this to be presented a bit differently.

That said, a couple of comments/questions on this version of the patch series..

 (a) is this on top of Andy's entry cleanups?

     If not, that probably needs to be sorted out.

 (b) the TLB global bit really is nastily done. You basically disable
_PAGE_GLOBAL entirely.

     I can see how/why that would make things simpler, but it's almost
certainly the wrong approach. The small subset of kernel pages that
are always mapped should definitely retain the global bit, so that you
don't always take a TLB miss on those! Those are probably some of the
most latency-critical pages, since there's generally no prefetching
for the kernel entry code or for things like IDT/GDT accesses..

     So even if you don't want to have global pages for normal kernel
entries, you don't want to just make _PAGE_GLOBAL be defined as zero.
You'd want to just use _PAGE_GLOBAL conditionally.

     Hmm?

 (c) am I reading the code correctly, and the shadow page tables are
*completely* duplicated?

     That seems insane. Why isn't only tyhe top level shadowed, and
then lower levels are shared between the shadowed and the "kernel"
page tables?

     But I may be mis-reading the code completely.

Apart from those three questions, I don't see any huge downside to the
patch series, apart from the obvious performance/complexity issues.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
