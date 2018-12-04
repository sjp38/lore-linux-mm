Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D88D96B7063
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 14:48:57 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so13220644plr.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:48:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z14si15813374pgj.73.2018.12.04.11.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 11:48:56 -0800 (PST)
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E5F9D20878
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:48:55 +0000 (UTC)
Received: by mail-wm1-f45.google.com with SMTP id c126so10562561wmh.0
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 11:48:55 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <CALCETrXvddt148fncMJqpjK98uatiK-44knYFWU0-ytf8X+iog@mail.gmail.com> <08141F66-F3E6-4CC5-AF91-1ED5F101A54C@gmail.com>
In-Reply-To: <08141F66-F3E6-4CC5-AF91-1ED5F101A54C@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 4 Dec 2018 11:48:42 -0800
Message-ID: <CALCETrXLrsKDBzDkN7sc9HYPWe9aV3NQzf4vMvM+FD8j6aA6AQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, Network Development <netdev@vger.kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jann Horn <jannh@google.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Dec 4, 2018 at 11:45 AM Nadav Amit <nadav.amit@gmail.com> wrote:
>
> > On Dec 4, 2018, at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
> >
> > On Mon, Dec 3, 2018 at 5:43 PM Nadav Amit <nadav.amit@gmail.com> wrote:
> >>> On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel.c=
om> wrote:
> >>>
> >>> Since vfree will lazily flush the TLB, but not lazily free the underl=
ying pages,
> >>> it often leaves stale TLB entries to freed pages that could get re-us=
ed. This is
> >>> undesirable for cases where the memory being freed has special permis=
sions such
> >>> as executable.
> >>
> >> So I am trying to finish my patch-set for preventing transient W+X map=
pings
> >> from taking space, by handling kprobes & ftrace that I missed (thanks =
again for
> >> pointing it out).
> >>
> >> But all of the sudden, I don=E2=80=99t understand why we have the prob=
lem that this
> >> (your) patch-set deals with at all. We already change the mappings to =
make
> >> the memory writable before freeing the memory, so why can=E2=80=99t we=
 make it
> >> non-executable at the same time? Actually, why do we make the module m=
emory,
> >> including its data executable before freeing it???
> >
> > All the code you're looking at is IMO a very awkward and possibly
> > incorrect of doing what's actually necessary: putting the direct map
> > the way it wants to be.
> >
> > Can't we shove this entirely mess into vunmap?  Have a flag (as part
> > of vmalloc like in Rick's patch or as a flag passed to a vfree variant
> > directly) that makes the vunmap code that frees the underlying pages
> > also reset their permissions?
> >
> > Right now, we muck with set_memory_rw() and set_memory_nx(), which
> > both have very awkward (and inconsistent with each other!) semantics
> > when called on vmalloc memory.  And they have their own flushes, which
> > is inefficient.  Maybe the right solution is for vunmap to remove the
> > vmap area PTEs, call into a function like set_memory_rw() that resets
> > the direct maps to their default permissions *without* flushing, and
> > then to do a single flush for everything.  Or, even better, to cause
> > the change_page_attr code to do the flush and also to flush the vmap
> > area all at once so that very small free operations can flush single
> > pages instead of flushing globally.
>
> Thanks for the explanation. I read it just after I realized that indeed t=
he
> whole purpose of this code is to get cpa_process_alias()
> update the corresponding direct mapping.
>
> This thing (pageattr.c) indeed seems over-engineered and very unintuitive=
.
> Right now I have a list of patch-sets that I owe, so I don=E2=80=99t have=
 the time
> to deal with it.
>
> But, I still think that disable_ro_nx() should not call set_memory_x().
> IIUC, this breaks W+X of the direct-mapping which correspond with the mod=
ule
> memory. Does it ever stop being W+X?? I=E2=80=99ll have another look.
>

Dunno.  I did once chase down a bug where some memory got freed while
it was still read-only, and the results were hilarious and hard to
debug, since the explosion happened long after the buggy code
finished.

--Andy
