Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB7D16B3D3F
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 18:48:41 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p11-v6so12999311oih.17
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 15:48:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e22-v6sor8113027oib.39.2018.08.26.15.48.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Aug 2018 15:48:40 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net> <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police> <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com> <20180824180438.GS24124@hirez.programming.kicks-ass.net>
 <56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com> <CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
 <9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com> <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
 <8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com> <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
 <20180826112341.f77a528763e297cbc36058fa@kernel.org> <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
In-Reply-To: <CALCETrXPaX-+R6Z9LqZp0uOVmq-TUX_ksPbUL7mnfbdqo6z2AA@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 27 Aug 2018 00:48:13 +0200
Message-ID: <CAG48ez1cYsa+5Grbzp0oGTFyjqE4pR-Qe9gb=0TKc9Q5HuOpmA@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: mhiramat@kernel.org, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, jkosina@suse.cz, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, benh@au1.ibm.com, npiggin@gmail.com, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Sun, Aug 26, 2018 at 6:21 AM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Sat, Aug 25, 2018 at 7:23 PM, Masami Hiramatsu <mhiramat@kernel.org> wrote:
> > On Fri, 24 Aug 2018 21:23:26 -0700
> > Andy Lutomirski <luto@kernel.org> wrote:
> >> Couldn't text_poke() use kmap_atomic()?  Or, even better, just change CR3?
> >
> > No, since kmap_atomic() is only for x86_32 and highmem support kernel.
> > In x86-64, it seems that returns just a page address. That is not
> > good for text_poke, since it needs to make a writable alias for RO
> > code page. Hmm, maybe, can we mimic copy_oldmem_page(), it uses ioremap_cache?
> >
>
> I just re-read text_poke().  It's, um, horrible.  Not only is the
> implementation overcomplicated and probably buggy, but it's SLOOOOOW.
> It's totally the wrong API -- poking one instruction at a time
> basically can't be efficient on x86.  The API should either poke lots
> of instructions at once or should be text_poke_begin(); ...;
> text_poke_end();.
>
> Anyway, the attached patch seems to boot.  Linus, Kees, etc: is this
> too scary of an approach?  With the patch applied, text_poke() is a
> fantastic exploit target.  On the other hand, even without the patch
> applied, text_poke() is every bit as juicy.

Twiddling CR0.WP is incompatible with Xen PV, right? It can't let you
do it because you're not actually running in ring 0 (but in ring 1 or
3), so CR0.WP has no influence on what you can access; and it must not
let you bypass write protection because you have read-only access to
host page tables. I think this code has to be compatible with Xen PV,
right?

In theory Xen PV could support this by emulating X86 instructions, but
I don't see anything related to CR0.WP in their emulation code. From
xen/arch/x86/pv/emul-priv-op.c:

    case 0: /* Write CR0 */
        if ( (val ^ read_cr0()) & ~X86_CR0_TS )
        {
            gdprintk(XENLOG_WARNING,
                     "Attempt to change unmodifiable CR0 flags\n");
            break;
        }
        do_fpu_taskswitch(!!(val & X86_CR0_TS));
        return X86EMUL_OKAY;

Having a special fallback path for "patch kernel code while running
under Xen PV" would be kinda ugly.
