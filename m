Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 255626B3870
	for <linux-mm@kvack.org>; Sat, 25 Aug 2018 22:23:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v195-v6so8536317pgb.0
        for <linux-mm@kvack.org>; Sat, 25 Aug 2018 19:23:48 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o188-v6si10921131pga.132.2018.08.25.19.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Aug 2018 19:23:47 -0700 (PDT)
Date: Sun, 26 Aug 2018 11:23:41 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: TLB flushes on fixmap changes
Message-Id: <20180826112341.f77a528763e297cbc36058fa@kernel.org>
In-Reply-To: <CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
References: <20180822153012.173508681@infradead.org>
	<20180822154046.823850812@infradead.org>
	<20180822155527.GF24124@hirez.programming.kicks-ass.net>
	<20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
	<CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
	<776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
	<CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
	<20180823133958.GA1496@brain-police>
	<20180824084717.GK24124@hirez.programming.kicks-ass.net>
	<D74A89DF-0D89-4AB6-8A6B-93BEC9A83595@gmail.com>
	<20180824180438.GS24124@hirez.programming.kicks-ass.net>
	<56A9902F-44BE-4520-A17C-26650FCC3A11@gmail.com>
	<CA+55aFzerzTPm94jugheVmWg8dJre94yu+GyZGT9NNZanNx_qw@mail.gmail.com>
	<9A38D3F4-2F75-401D-8B4D-83A844C9061B@gmail.com>
	<CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
	<8E0D8C66-6F21-4890-8984-B6B3082D4CC5@gmail.com>
	<CALCETrWdeKBcEs7zAbpEM1YdYiT2UBXwPtF0mMTvcDX_KRpz1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Fri, 24 Aug 2018 21:23:26 -0700
Andy Lutomirski <luto@kernel.org> wrote:

> On Fri, Aug 24, 2018 at 7:29 PM,  <nadav.amit@gmail.com> wrote:
> >
> >
> > On August 24, 2018 5:58:43 PM PDT, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >>Adding a few people to the cc.
> >>
> >>On Fri, Aug 24, 2018 at 1:24 PM Nadav Amit <nadav.amit@gmail.com>
> >>wrote:
> >>> >
> >>> > Can you actually find something that changes the fixmaps after boot
> >>> > (again, ignoring kmap)?
> >>>
> >>> At least the alternatives mechanism appears to do so.
> >>>
> >>> IIUC the following path is possible when adding a module:
> >>>
> >>>         jump_label_add_module()
> >>>         ->__jump_label_update()
> >>>         ->arch_jump_label_transform()
> >>>         ->__jump_label_transform()
> >>>         ->text_poke_bp()
> >>>         ->text_poke()
> >>>         ->set_fixmap()
> >>
> >>Yeah, that looks a bit iffy.
> >>
> >>But making the tlb flush global wouldn't help.  This is running on a
> >>local core, and if there are other CPU's that can do this at the same
> >>time, then they'd just fight about the same mapping.
> >>
> >>Honestly, I think it's ok just because I *hope* this is all serialized
> >>anyway (jump_label_lock? But what about other users of text_poke?).
> >
> > The users should hold text_mutex.
> >
> >>
> >>But I'd be a lot happier about it if it either used an explicit lock
> >>to make sure, or used per-cpu fixmap entries.
> >
> > My concern is that despite the lock, one core would do a speculative page walk and cache a translation that soon after would become stale.
> >
> >>
> >>And the tlb flush is done *after* the address is used, which is bogus
> >>anyway.
> >
> > It seems to me that it is intended to remove the mapping that might be a security issue.
> >
> > But anyhow, set_fixmap and clear_fixmap perform a local TLB flush, (in __set_pte_vaddr()) so locally things should be fine.
> >
> >>
> >>> And a similar path can happen when static_key_enable/disable() is
> >>called.
> >>
> >>Same comments.
> >>
> >>How about replacing that
> >>
> >>        local_irq_save(flags);
> >>       ... do critical things here ...
> >>        local_irq_restore(flags);
> >>
> >>in text_poke() with
> >>
> >>        static DEFINE_SPINLOCK(poke_lock);
> >>
> >>        spin_lock_irqsave(&poke_lock, flags);
> >>       ... do critical things here ...
> >>        spin_unlock_irqrestore(&poke_lock, flags);
> >>
> >>and moving the local_flush_tlb() to after the set_fixmaps, but before
> >>the access through the virtual address.
> >>
> >>But changing things to do a global tlb flush would just be wrong.
> >
> > As I noted, I think that locking and local flushes as they are right now are fine (besides the redundant flush).
> >
> > My concern is merely that speculative page walks on other cores would cache stale entries.
> >
> >
> 
> This is almost certainly a bug, or even two bugs.  Bug 1:  why on
> Earth do we flush in __set_pte_vaddr()?  We should flush when
> *clearing* or when modifying an existing fixmap entry.  Right now, if
> we do text_poke() after boot, then the TLB entry will stick around and
> will be a nice exploit target.
> 
> Bug 2: what you're describing.  It's racy.
> 
> Couldn't text_poke() use kmap_atomic()?  Or, even better, just change CR3?

No, since kmap_atomic() is only for x86_32 and highmem support kernel.
In x86-64, it seems that returns just a page address. That is not
good for text_poke, since it needs to make a writable alias for RO
code page. Hmm, maybe, can we mimic copy_oldmem_page(), it uses ioremap_cache?

Thank you,

-- 
Masami Hiramatsu <mhiramat@kernel.org>
