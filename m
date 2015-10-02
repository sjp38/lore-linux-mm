Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5F36C4402EE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 07:58:59 -0400 (EDT)
Received: by ioii196 with SMTP id i196so116923187ioi.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 04:58:59 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id b2si5783214igb.24.2015.10.02.04.58.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 04:58:58 -0700 (PDT)
Received: by iow1 with SMTP id 1so80040079iow.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 04:58:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <560E6F5C.4040302@redhat.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
	<20150916174913.AF5FEA6D@viggo.jf.intel.com>
	<20150920085554.GA21906@gmail.com>
	<55FF88BA.6080006@sr71.net>
	<20150924094956.GA30349@gmail.com>
	<56044A88.7030203@sr71.net>
	<20151001111718.GA25333@gmail.com>
	<CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
	<560DB4A6.6050107@sr71.net>
	<CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
	<560E6F5C.4040302@redhat.com>
Date: Fri, 2 Oct 2015 07:58:58 -0400
Message-ID: <CA+55aFxsVt+r+ErK55K=L9gOHLRMHChfPSYfOm0bq+jHv4rbQw@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Dave Hansen <dave@sr71.net>, Kees Cook <keescook@google.com>, Ingo Molnar <mingo@kernel.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>

On Fri, Oct 2, 2015 at 7:49 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> On 02/10/2015 00:48, Linus Torvalds wrote:
>> It's quite likely that you will find that compilers put read-only
>> constants in the text section, knowing that executable means readable.
>
> Not on x86 (because it has large immediates; RISC machines and s390 do
> put large constants in the text section).
>
> But at the very least jump tables reside in the .text seection.

Yes, at least traditionally gcc put things like the jump tables for
switch() statements immediately next to the code. That caused lots of
pain on the P4, where the L1 I$ and D$ were exclusive. I think that
caused gcc to then put the jump tables further away, and it might be
in a separate section these days - but it might also just be
"sufficiently aligned" that the L1 cache issue isn't in play any more.

Anyway, because of the P4 exclusive L1 I/D$ issue we can pretty much
rest easy knowing that the data accesses and text accesses should be
separated by at least one cacheline (maybe even 128 bytes - I think
the L4 used 64-byte line size, but it was sub-sections of a 128-byte
bigger line - but that might have been in the L2 only).

But I could easily see the compiler/linker still putting them in the
same ELF segment.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
