Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A455B6B78BC
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 02:29:16 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p66so19101425itc.0
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 23:29:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14sor20944526jac.7.2018.12.05.23.29.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 23:29:15 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com> <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
In-Reply-To: <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 6 Dec 2018 08:29:03 +0100
Message-ID: <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, nadav.amit@gmail.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, kristen@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, anil.s.keshavamurthy@intel.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, naveen.n.rao@linux.vnet.ibm.com, "David S. Miller" <davem@davemloft.net>, "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, 6 Dec 2018 at 00:16, Andy Lutomirski <luto@kernel.org> wrote:
>
> On Wed, Dec 5, 2018 at 3:41 AM Will Deacon <will.deacon@arm.com> wrote:
> >
> > On Tue, Dec 04, 2018 at 12:09:49PM -0800, Andy Lutomirski wrote:
> > > On Tue, Dec 4, 2018 at 12:02 PM Edgecombe, Rick P
> > > <rick.p.edgecombe@intel.com> wrote:
> > > >
> > > > On Tue, 2018-12-04 at 16:03 +0000, Will Deacon wrote:
> > > > > On Mon, Dec 03, 2018 at 05:43:11PM -0800, Nadav Amit wrote:
> > > > > > > On Nov 27, 2018, at 4:07 PM, Rick Edgecombe <rick.p.edgecombe=
@intel.com>
> > > > > > > wrote:
> > > > > > >
> > > > > > > Since vfree will lazily flush the TLB, but not lazily free th=
e underlying
> > > > > > > pages,
> > > > > > > it often leaves stale TLB entries to freed pages that could g=
et re-used.
> > > > > > > This is
> > > > > > > undesirable for cases where the memory being freed has specia=
l permissions
> > > > > > > such
> > > > > > > as executable.
> > > > > >
> > > > > > So I am trying to finish my patch-set for preventing transient =
W+X mappings
> > > > > > from taking space, by handling kprobes & ftrace that I missed (=
thanks again
> > > > > > for
> > > > > > pointing it out).
> > > > > >
> > > > > > But all of the sudden, I don=E2=80=99t understand why we have t=
he problem that this
> > > > > > (your) patch-set deals with at all. We already change the mappi=
ngs to make
> > > > > > the memory wrAcked-by: Ard Biesheuvel <ard.biesheuvel@linaro.or=
g>
itable before freeing the memory, so why can=E2=80=99t we make it
> > > > > > non-executable at the same time? Actually, why do we make the m=
odule memory,
> > > > > > including its data executable before freeing it???
> > > > >
> > > > > Yeah, this is really confusing, but I have a suspicion it's a com=
bination
> > > > > of the various different configurations and hysterical raisins. W=
e can't
> > > > > rely on module_alloc() allocating from the vmalloc area (see nios=
2) nor
> > > > > can we rely on disable_ro_nx() being available at build time.
> > > > >
> > > > > If we *could* rely on module allocations always using vmalloc(), =
then
> > > > > we could pass in Rick's new flag and drop disable_ro_nx() altoget=
her
> > > > > afaict -- who cares about the memory attributes of a mapping that=
's about
> > > > > to disappear anyway?
> > > > >
> > > > > Is it just nios2 that does something different?
> > > > >
> > > > Yea it is really intertwined. I think for x86, set_memory_nx everyw=
here would
> > > > solve it as well, in fact that was what I first thought the solutio=
n should be
> > > > until this was suggested. It's interesting that from the other thre=
ad Masami
> > > > Hiramatsu referenced, set_memory_nx was suggested last year and wou=
ld have
> > > > inadvertently blocked this on x86. But, on the other architectures =
I have since
> > > > learned it is a bit different.
> > > >
> > > > It looks like actually most arch's don't re-define set_memory_*, an=
d so all of
> > > > the frob_* functions are actually just noops. In which case allocat=
ing RWX is
> > > > needed to make it work at all, because that is what the allocation =
is going to
> > > > stay at. So in these archs, set_memory_nx won't solve it because it=
 will do
> > > > nothing.
> > > >
> > > > On x86 I think you cannot get rid of disable_ro_nx fully because th=
ere is the
> > > > changing of the permissions on the directmap as well. You don't wan=
t some other
> > > > caller getting a page that was left RO when freed and then trying t=
o write to
> > > > it, if I understand this.
> > > >
> > >
> > > Exactly.
> >
> > Of course, I forgot about the linear mapping. On arm64, we've just queu=
ed
> > support for reflecting changes to read-only permissions in the linear m=
ap
> > [1]. So, whilst the linear map is always non-executable, we will need t=
o
> > make parts of it writable again when freeing the module.
> >
> > > After slightly more thought, I suggest renaming VM_IMMEDIATE_UNMAP to
> > > VM_MAY_ADJUST_PERMS or similar.  It would have the semantics you want=
,
> > > but it would also call some arch hooks to put back the direct map
> > > permissions before the flush.  Does that seem reasonable?  It would
> > > need to be hooked up that implement set_memory_ro(), but that should
> > > be quite easy.  If nothing else, it could fall back to set_memory_ro(=
)
> > > in the absence of a better implementation.
> >
> > You mean set_memory_rw() here, right? Although, eliding the TLB invalid=
ation
> > would open up a window where the vmap mapping is executable and the lin=
ear
> > mapping is writable, which is a bit rubbish.
> >
>
> Right, and Rick pointed out the same issue.  Instead, we should set
> the direct map not-present or its ARM equivalent, then do the flush,
> then make it RW.  I assume this also works on arm and arm64, although
> I don't know for sure.  On x86, the CPU won't cache not-present PTEs.

If we are going to unmap the linear alias, why not do it at vmalloc()
time rather than vfree() time?
