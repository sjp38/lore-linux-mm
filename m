Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 717A344030A
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 02:59:35 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so59060595wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 23:59:34 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id gc14si3161939wic.73.2015.10.02.23.59.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 23:59:34 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so58710960wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 23:59:34 -0700 (PDT)
Date: Sat, 3 Oct 2015 08:59:06 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151003065906.GA23206@gmail.com>
References: <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com>
 <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
 <20151002070943.GA1623@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002070943.GA1623@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Ingo Molnar <mingo@kernel.org> wrote:

> > It's quite likely that you will find that compilers put read-only constants in 
> > the text section, knowing that executable means readable.
> 
> At least with pkeys enabling true --x mappings, that compiler practice becomes a 
> (mild) security problem: it provides a readable and executable return target for 
> stack/buffer overflow attacks - FWIIW. (It's a limited concern because the true 
> code areas are executable already.)

Btw., it's not just security, there will also a robustness advantage to creating 
true PROT_EXEC mappings: right now if buggy user-space code accidentally 
references into an executable section: say uses a negative index in a table put 
into .rodata, the code will not crash, it will happily read from the .text area.

But if we mapped .text with true PROT_EXEC (and the CPU enforced that) then we'd 
get a nice segfault.

This has additional security benefits as well, beyond not providing readable ROP 
sites - which in fact look more significant than the ROP readability angle I 
mentioned initially.

So to sum it up, if we use true --x (non-readable PROT_EXEC) mappings using pkeys, 
we get the following benefits:

 - Overflows and other out of bounds accesses from .rodata (and other data
   sections near .text) will be caught by the CPU instead of silent data flow 
   corruption. This has robustness (and thus security) advantages.

 - True --x code is not readable, thus not 'soft-discoverable' via information 
   leaks for ROP purposes.

 - The version fingerprinting of unknown remote target binaries via information 
   leaks becomes harder as well.

 - The local (and remote) guessing of ASLR offsets via information leaks gets
   harder as well.

 - We get to test pkeys much more seriously than the opt-in special uses! :-)

Intel sent me pkeys test hardware, so I can give it a go in practice as well and 
see how well it works.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
