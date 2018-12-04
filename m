Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02B146B707A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 15:10:05 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id k125so9674344pga.5
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:10:04 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u25si16811554pgm.532.2018.12.04.12.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 12:10:03 -0800 (PST)
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 35FA820879
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:10:03 +0000 (UTC)
Received: by mail-wr1-f52.google.com with SMTP id x10so17302317wrs.8
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 12:10:03 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
In-Reply-To: <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 4 Dec 2018 12:09:49 -0800
Message-ID: <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Will Deacon <will.deacon@arm.com>, Nadav Amit <nadav.amit@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, jeyu@kernel.org, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Dec 4, 2018 at 12:02 PM Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
>
> On Tue, 2018-12-04 at 16:03 +0000, Will Deacon wrote:
> > On Mon, Dec 03, 2018 at 05:43:11PM -0800, Nadav Amit wrote:
> > > > On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe@intel=
.com>
> > > > wrote:
> > > >
> > > > Since vfree will lazily flush the TLB, but not lazily free the unde=
rlying
> > > > pages,
> > > > it often leaves stale TLB entries to freed pages that could get re-=
used.
> > > > This is
> > > > undesirable for cases where the memory being freed has special perm=
issions
> > > > such
> > > > as executable.
> > >
> > > So I am trying to finish my patch-set for preventing transient W+X ma=
ppings
> > > from taking space, by handling kprobes & ftrace that I missed (thanks=
 again
> > > for
> > > pointing it out).
> > >
> > > But all of the sudden, I don=E2=80=99t understand why we have the pro=
blem that this
> > > (your) patch-set deals with at all. We already change the mappings to=
 make
> > > the memory writable before freeing the memory, so why can=E2=80=99t w=
e make it
> > > non-executable at the same time? Actually, why do we make the module =
memory,
> > > including its data executable before freeing it???
> >
> > Yeah, this is really confusing, but I have a suspicion it's a combinati=
on
> > of the various different configurations and hysterical raisins. We can'=
t
> > rely on module_alloc() allocating from the vmalloc area (see nios2) nor
> > can we rely on disable_ro_nx() being available at build time.
> >
> > If we *could* rely on module allocations always using vmalloc(), then
> > we could pass in Rick's new flag and drop disable_ro_nx() altogether
> > afaict -- who cares about the memory attributes of a mapping that's abo=
ut
> > to disappear anyway?
> >
> > Is it just nios2 that does something different?
> >
> > Will
>
> Yea it is really intertwined. I think for x86, set_memory_nx everywhere w=
ould
> solve it as well, in fact that was what I first thought the solution shou=
ld be
> until this was suggested. It's interesting that from the other thread Mas=
ami
> Hiramatsu referenced, set_memory_nx was suggested last year and would hav=
e
> inadvertently blocked this on x86. But, on the other architectures I have=
 since
> learned it is a bit different.
>
> It looks like actually most arch's don't re-define set_memory_*, and so a=
ll of
> the frob_* functions are actually just noops. In which case allocating RW=
X is
> needed to make it work at all, because that is what the allocation is goi=
ng to
> stay at. So in these archs, set_memory_nx won't solve it because it will =
do
> nothing.
>
> On x86 I think you cannot get rid of disable_ro_nx fully because there is=
 the
> changing of the permissions on the directmap as well. You don't want some=
 other
> caller getting a page that was left RO when freed and then trying to writ=
e to
> it, if I understand this.
>

Exactly.

After slightly more thought, I suggest renaming VM_IMMEDIATE_UNMAP to
VM_MAY_ADJUST_PERMS or similar.  It would have the semantics you want,
but it would also call some arch hooks to put back the direct map
permissions before the flush.  Does that seem reasonable?  It would
need to be hooked up that implement set_memory_ro(), but that should
be quite easy.  If nothing else, it could fall back to set_memory_ro()
in the absence of a better implementation.
