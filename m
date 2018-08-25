Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id CB2726B32C7
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 22:16:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j17-v6so9138078oii.8
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 19:16:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w132-v6sor3053188oiw.3.2018.08.24.19.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 19:16:29 -0700 (PDT)
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
In-Reply-To: <CA+55aFz1KYT7fRRG98wei24spiVg7u1Ec66piWY5359ykFmezw@mail.gmail.com>
From: Nadav Amit <nadav.amit@gmail.com>
Date: Fri, 24 Aug 2018 19:16:10 -0700
Message-ID: <CAKLkAJ7zB7U5TZCXR5FKwou91uONtX41e-FXV=c9Ram=VwxcGQ@mail.gmail.com>
Subject: Re: TLB flushes on fixmap changes
Content-Type: multipart/alternative; boundary="00000000000075c9d605743914a2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Masami Hiramatsu <mhiramat@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

--00000000000075c9d605743914a2
Content-Type: text/plain; charset="UTF-8"

On Fri, Aug 24, 2018, 5:58 PM Linus Torvalds <torvalds@linux-foundation.org>
wrote:

> Adding a few people to the cc.
>
> On Fri, Aug 24, 2018 at 1:24 PM Nadav Amit <nadav.amit@gmail.com> wrote:
> > >
> > > Can you actually find something that changes the fixmaps after boot
> > > (again, ignoring kmap)?
> >
> > At least the alternatives mechanism appears to do so.
> >
> > IIUC the following path is possible when adding a module:
> >
> >         jump_label_add_module()
> >         ->__jump_label_update()
> >         ->arch_jump_label_transform()
> >         ->__jump_label_transform()
> >         ->text_poke_bp()
> >         ->text_poke()
> >         ->set_fixmap()
>
> Yeah, that looks a bit iffy.
>
> But making the tlb flush global wouldn't help.  This is running on a
> local core, and if there are other CPU's that can do this at the same
> time, then they'd just fight about the same mapping.
>
> Honestly, I think it's ok just because I *hope* this is all serialized
> anyway (jump_label_lock? But what about other users of text_poke?).
>

The users should hold text_mutex.



> But I'd be a lot happier about it if it either used an explicit lock
> to make sure, or used per-cpu fixmap entries.
>

My concern is that despite the lock, one core would do a speculative page
walk and cache a translation that soon after would become stale.



> And the tlb flush is done *after* the address is used, which is bogus
> anyway.
>

It seems to me that it is intended to remove the mapping that might be a
security issue.

But anyhow, set_fixmap and clear_fixmap perform a local TLB flush, (in
__set_pte_vaddr()) so locally things should be fine.



>
> > And a similar path can happen when static_key_enable/disable() is called.
>
> Same comments.
>
> How about replacing that
>
>         local_irq_save(flags);
>        ... do critical things here ...
>         local_irq_restore(flags);
>
> in text_poke() with
>
>         static DEFINE_SPINLOCK(poke_lock);
>
>         spin_lock_irqsave(&poke_lock, flags);
>        ... do critical things here ...
>         spin_unlock_irqrestore(&poke_lock, flags);
>
> and moving the local_flush_tlb() to after the set_fixmaps, but before
> the access through the virtual address.
>
> But changing things to do a global tlb flush would just be wrong.



As I noted, I think that locking and local flushes as they are right now
are fine (besides the redundant flush).
My concern is merely that speculative page walks on other cores would cache
stale entries.

--00000000000075c9d605743914a2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Fri, Aug 24, 2018, 5:58 PM Linus Torvalds &lt;<a href=3D"mailto:torvalds=
@linux-foundation.org" target=3D"_blank" rel=3D"noreferrer">torvalds@linux-=
foundation.org</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Addin=
g a few people to the cc.<br>
<br>
On Fri, Aug 24, 2018 at 1:24 PM Nadav Amit &lt;<a href=3D"mailto:nadav.amit=
@gmail.com" rel=3D"noreferrer noreferrer" target=3D"_blank">nadav.amit@gmai=
l.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; Can you actually find something that changes the fixmaps after bo=
ot<br>
&gt; &gt; (again, ignoring kmap)?<br>
&gt;<br>
&gt; At least the alternatives mechanism appears to do so.<br>
&gt;<br>
&gt; IIUC the following path is possible when adding a module:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0jump_label_add_module()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;__jump_label_update()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;arch_jump_label_transform()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;__jump_label_transform()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;text_poke_bp()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;text_poke()<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-&gt;set_fixmap()<br>
<br>
Yeah, that looks a bit iffy.<br>
<br>
But making the tlb flush global wouldn&#39;t help.=C2=A0 This is running on=
 a<br>
local core, and if there are other CPU&#39;s that can do this at the same<b=
r>
time, then they&#39;d just fight about the same mapping.<br>
<br>
Honestly, I think it&#39;s ok just because I *hope* this is all serialized<=
br>
anyway (jump_label_lock? But what about other users of text_poke?).<br></bl=
ockquote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">The user=
s should hold text_mutex.</div><div dir=3D"auto"><br></div><div dir=3D"auto=
"><br></div><div dir=3D"auto"><div class=3D"gmail_quote"><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">
<br>
But I&#39;d be a lot happier about it if it either used an explicit lock<br=
>
to make sure, or used per-cpu fixmap entries.<br></blockquote></div></div><=
div dir=3D"auto"><br></div><div dir=3D"auto">My concern is that despite the=
 lock, one core would do a speculative page walk and cache a translation th=
at soon after would become stale.</div><div dir=3D"auto"><br></div><div dir=
=3D"auto"><br></div><div dir=3D"auto"><div class=3D"gmail_quote"><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex">
<br>
And the tlb flush is done *after* the address is used, which is bogus anywa=
y.<br></blockquote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto=
">It seems to me that it is intended to remove the mapping that might be a =
security issue.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"auto">Bu=
t anyhow, set_fixmap and clear_fixmap perform a local TLB flush, (in __set_=
pte_vaddr()) so locally things should be fine.</div><div dir=3D"auto"><br><=
/div><div dir=3D"auto"><br></div><div dir=3D"auto"><div class=3D"gmail_quot=
e"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex"><br><br>
&gt; And a similar path can happen when static_key_enable/disable() is call=
ed.<br>
<br>
Same comments.<br>
<br>
How about replacing that<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 local_irq_save(flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0... do critical things here ...<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 local_irq_restore(flags);<br>
<br>
in text_poke() with<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 static DEFINE_SPINLOCK(poke_lock);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&amp;poke_lock, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0... do critical things here ...<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&amp;poke_lock, flags);<=
br>
<br>
and moving the local_flush_tlb() to after the set_fixmaps, but before<br>
the access through the virtual address.<br>
<br>
But changing things to do a global tlb flush would just be wrong.</blockquo=
te></div></div><div dir=3D"auto"><br></div><div dir=3D"auto"><br></div><div=
 dir=3D"auto">As I noted, I think that locking and local flushes as they ar=
e right now are fine (besides the redundant flush).</div><div dir=3D"auto">=
My concern is merely that speculative page walks on other cores would cache=
 stale entries.</div></div>

--00000000000075c9d605743914a2--
