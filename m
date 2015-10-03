Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id AEDAE44030A
	for <linux-mm@kvack.org>; Sat,  3 Oct 2015 02:46:42 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so54975386wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 23:46:42 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id si6si3139452wic.33.2015.10.02.23.46.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 23:46:41 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so58504106wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 23:46:40 -0700 (PDT)
Date: Sat, 3 Oct 2015 08:46:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Message-ID: <20151003064637.GA23054@gmail.com>
References: <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com>
 <56044A88.7030203@sr71.net>
 <20151001111718.GA25333@gmail.com>
 <CAGXu5j+j92EPEwv9O4cX92zJDTyBEz3WtQ2CDHT0KmqJ6bCmGQ@mail.gmail.com>
 <560DB4A6.6050107@sr71.net>
 <CA+55aFwUAY01QC8A3mCOoq5aYjT7Lw-gVx6DvqYBr0UMZ9kZEQ@mail.gmail.com>
 <560E6F5C.4040302@redhat.com>
 <CA+55aFxsVt+r+ErK55K=L9gOHLRMHChfPSYfOm0bq+jHv4rbQw@mail.gmail.com>
 <560E7508.6080006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560E7508.6080006@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Kees Cook <keescook@google.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>


* Paolo Bonzini <pbonzini@redhat.com> wrote:

> 
> 
> On 02/10/2015 13:58, Linus Torvalds wrote:
> > On Fri, Oct 2, 2015 at 7:49 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> >> On 02/10/2015 00:48, Linus Torvalds wrote:
> >>> It's quite likely that you will find that compilers put read-only
> >>> constants in the text section, knowing that executable means readable.
> >>
> >> Not on x86 (because it has large immediates; RISC machines and s390 do
> >> put large constants in the text section).
> >>
> >> But at the very least jump tables reside in the .text seection.
> > 
> > Yes, at least traditionally gcc put things like the jump tables for
> > switch() statements immediately next to the code. That caused lots of
> > pain on the P4, where the L1 I$ and D$ were exclusive. I think that
> > caused gcc to then put the jump tables further away, and it might be
> > in a separate section these days - but it might also just be
> > "sufficiently aligned" that the L1 cache issue isn't in play any more.
> > 
> > Anyway, because of the P4 exclusive L1 I/D$ issue we can pretty much
> > rest easy knowing that the data accesses and text accesses should be
> > separated by at least one cacheline (maybe even 128 bytes - I think
> > the L4 used 64-byte line size, but it was sub-sections of a 128-byte
> > bigger line - but that might have been in the L2 only).
> > 
> > But I could easily see the compiler/linker still putting them in the
> > same ELF segment.
> 
> You're entirely right, it puts them in .rodata actually.  But .rodata is
> in the same segment as .text:
> 
> $ readelf --segments /bin/true
> ...
>  Section to Segment mapping:
>   Segment Sections...
>    00     
>    01     .interp 
>    02     .interp .note.ABI-tag .note.gnu.build-id .gnu.hash .dynsym
>           .dynstr .gnu.version .gnu.version_r .rela.dyn .rela.plt .init
>           .plt .text .fini .rodata .eh_frame_hdr .eh_frame 
>    03     .init_array .fini_array .jcr .data.rel.ro .dynamic .got .data .bss 
>    04     .dynamic 
>    05     .note.ABI-tag .note.gnu.build-id 
>    06     .eh_frame_hdr 
>    07     
>    08     .init_array .fini_array .jcr .data.rel.ro .dynamic .got 

Is there an easy(-ish) way (i.e. using compiler/linker flags, not linker scripts) 
to build the ELF binary in such a way so that non-code data:

          .rodata .eh_frame_hdr .eh_frame 

... gets put into a separate (readonly and non-executable) segment? That would 
enable things from the distro side AFAICS, right?

(assuming I'm reading the ELF dump right.)

Or does this need binutils surgery?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
