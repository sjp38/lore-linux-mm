Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16BF28E0001
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 21:33:26 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 199-v6so668427wme.1
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 18:33:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j6-v6sor2893981wru.33.2018.09.25.18.33.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 18:33:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180925153011.15311-1-josef@toxicpanda.com> <20180925153011.15311-2-josef@toxicpanda.com>
 <20180926002217.GA18567@dastard>
In-Reply-To: <20180926002217.GA18567@dastard>
From: Josef Bacik <josef@toxicpanda.com>
Date: Tue, 25 Sep 2018 21:33:12 -0400
Message-ID: <CAEzrpqeakEVhKz16=7m6RXCvdqHaTvZ-6j89vt1Zn9vLMwHhkg@mail.gmail.com>
Subject: Re: [PATCH 1/8] mm: push vm_fault into the page fault handlers
Content-Type: multipart/alternative; boundary="00000000000045c2c70576bc3536"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, tj@kernel.org

--00000000000045c2c70576bc3536
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

(Only have my iPhone, sorry)

Hey it compiled on x86 and passed xfstests, good enough for an RFC.  I
thought kbuild testbot did these and since it hadn=E2=80=99t emailed me yet=
 I
assumed I didn=E2=80=99t break anything (a bad assumption I know). I=E2=80=
=99ll go through
more thoroughly, but it for sure compiles on x86.  Thanks,

Josef

On Tue, Sep 25, 2018 at 8:22 PM Dave Chinner <david@fromorbit.com> wrote:

> On Tue, Sep 25, 2018 at 11:30:04AM -0400, Josef Bacik wrote:
> > In preparation for caching pages during filemap faults we need to push
> > the struct vm_fault up a level into the arch page fault handlers, since
> > they are the ones responsible for retrying if we unlock the mmap_sem.
> >
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > ---
> >  arch/alpha/mm/fault.c         |  4 ++-
> >  arch/arc/mm/fault.c           |  2 ++
> >  arch/arm/mm/fault.c           | 18 ++++++++-----
> >  arch/arm64/mm/fault.c         | 18 +++++++------
> >  arch/hexagon/mm/vm_fault.c    |  4 ++-
> >  arch/ia64/mm/fault.c          |  4 ++-
> >  arch/m68k/mm/fault.c          |  5 ++--
> >  arch/microblaze/mm/fault.c    |  4 ++-
> >  arch/mips/mm/fault.c          |  4 ++-
> >  arch/nds32/mm/fault.c         |  5 ++--
> >  arch/nios2/mm/fault.c         |  4 ++-
> >  arch/openrisc/mm/fault.c      |  5 ++--
> >  arch/parisc/mm/fault.c        |  5 ++--
> >  arch/powerpc/mm/copro_fault.c |  4 ++-
> >  arch/powerpc/mm/fault.c       |  4 ++-
> >  arch/riscv/mm/fault.c         |  2 ++
> >  arch/s390/mm/fault.c          |  4 ++-
> >  arch/sh/mm/fault.c            |  4 ++-
> >  arch/sparc/mm/fault_32.c      |  6 ++++-
> >  arch/sparc/mm/fault_64.c      |  2 ++
> >  arch/um/kernel/trap.c         |  4 ++-
> >  arch/unicore32/mm/fault.c     | 17 +++++++-----
> >  arch/x86/mm/fault.c           |  4 ++-
> >  arch/xtensa/mm/fault.c        |  4 ++-
> >  drivers/iommu/amd_iommu_v2.c  |  4 ++-
> >  drivers/iommu/intel-svm.c     |  6 +++--
> >  include/linux/mm.h            | 16 +++++++++---
> >  mm/gup.c                      |  8 ++++--
> >  mm/hmm.c                      |  4 ++-
> >  mm/ksm.c                      | 10 ++++---
> >  mm/memory.c                   | 61
> +++++++++++++++++++++----------------------
> >  31 files changed, 157 insertions(+), 89 deletions(-)
> >
> > diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
> > index d73dc473fbb9..3c98dfef03a9 100644
> > --- a/arch/alpha/mm/fault.c
> > +++ b/arch/alpha/mm/fault.c
> > @@ -84,6 +84,7 @@ asmlinkage void
> >  do_page_fault(unsigned long address, unsigned long mmcsr,
> >             long cause, struct pt_regs *regs)
> >  {
> > +     struct vm_fault vmf =3D {};
> >       struct vm_area_struct * vma;
> >       struct mm_struct *mm =3D current->mm;
> >       const struct exception_table_entry *fixup;
> > @@ -148,7 +149,8 @@ do_page_fault(unsigned long address, unsigned long
> mmcsr,
> >       /* If for any reason at all we couldn't handle the fault,
> >          make sure we exit gracefully rather than endlessly redo
> >          the fault.  */
> > -     fault =3D handle_mm_fault(vma, address, flags);
> > +     vm_fault_init(&vmfs, vma, flags, address);
> > +     fault =3D handle_mm_fault(&vmf);
>
> Doesn't compile.
>
> > --- a/arch/arm/mm/fault.c
> > +++ b/arch/arm/mm/fault.c
> > @@ -225,17 +225,17 @@ static inline bool access_error(unsigned int fsr,
> struct vm_area_struct *vma)
> >  }
> >
> >  static vm_fault_t __kprobes
> > -__do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int
> fsr,
> > -             unsigned int flags, struct task_struct *tsk)
> > +__do_page_fault(struct mm_struct *mm, struct vm_fault *vm, unsigned in=
t
> fsr,
>
> vm_fault is *vm....
>
> > +             struct task_struct *tsk)
> >  {
> >       struct vm_area_struct *vma;
> >       vm_fault_t fault;
> >
> > -     vma =3D find_vma(mm, addr);
> > +     vma =3D find_vma(mm, vmf->address);
>
> So this doesn't compile.
>
> >
> >  check_stack:
> > -     if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
> > +     if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma,
> vmf->address))
> >               goto good_area;
> >  out:
> >       return fault;
> > @@ -424,6 +424,7 @@ static bool is_el0_instruction_abort(unsigned int
> esr)
> >  static int __kprobes do_page_fault(unsigned long addr, unsigned int es=
r,
> >                                  struct pt_regs *regs)
> >  {
> > +     struct vm_fault vmf =3D {};
> >       struct task_struct *tsk;
> >       struct mm_struct *mm;
> >       struct siginfo si;
> > @@ -493,7 +494,8 @@ static int __kprobes do_page_fault(unsigned long
> addr, unsigned int esr,
> >  #endif
> >       }
> >
> > -     fault =3D __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
> > +     vm_fault_init(&vmf, NULL, addr, mm_flags);
> > +     fault =3D __do_page_fault(mm, vmf, vm_flags, tsk);
>
> I'm betting this doesn't compile, either.
>
> /me stops looking.
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com
>

--00000000000045c2c70576bc3536
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div><div dir=3D"auto">(Only have my iPhone, sorry)</div><div dir=3D"auto">=
<br></div><div dir=3D"auto">Hey it compiled on x86 and passed xfstests, goo=
d enough for an RFC.=C2=A0 I thought kbuild testbot did these and since it =
hadn=E2=80=99t emailed me yet I assumed I didn=E2=80=99t break anything (a =
bad assumption I know). I=E2=80=99ll go through more thoroughly, but it for=
 sure compiles on x86.=C2=A0 Thanks,</div></div><div dir=3D"auto"><br></div=
><div dir=3D"auto">Josef</div><div><br><div class=3D"gmail_quote"><div dir=
=3D"ltr">On Tue, Sep 25, 2018 at 8:22 PM Dave Chinner &lt;<a href=3D"mailto=
:david@fromorbit.com">david@fromorbit.com</a>&gt; wrote:<br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">On Tue, Sep 25, 2018 at 11:30:04AM -0400, Josef Bacik=
 wrote:<br>
&gt; In preparation for caching pages during filemap faults we need to push=
<br>
&gt; the struct vm_fault up a level into the arch page fault handlers, sinc=
e<br>
&gt; they are the ones responsible for retrying if we unlock the mmap_sem.<=
br>
&gt; <br>
&gt; Signed-off-by: Josef Bacik &lt;<a href=3D"mailto:josef@toxicpanda.com"=
 target=3D"_blank">josef@toxicpanda.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 arch/alpha/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/arc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 2 ++<br>
&gt;=C2=A0 arch/arm/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 18=
 ++++++++-----<br>
&gt;=C2=A0 arch/arm64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 18 ++++=
+++------<br>
&gt;=C2=A0 arch/hexagon/mm/vm_fault.c=C2=A0 =C2=A0 |=C2=A0 4 ++-<br>
&gt;=C2=A0 arch/ia64/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/m68k/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 5=
 ++--<br>
&gt;=C2=A0 arch/microblaze/mm/fault.c=C2=A0 =C2=A0 |=C2=A0 4 ++-<br>
&gt;=C2=A0 arch/mips/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/nds32/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 5=
 ++--<br>
&gt;=C2=A0 arch/nios2/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/openrisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 |=C2=A0 5 ++--<br>
&gt;=C2=A0 arch/parisc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 5 ++--=
<br>
&gt;=C2=A0 arch/powerpc/mm/copro_fault.c |=C2=A0 4 ++-<br>
&gt;=C2=A0 arch/powerpc/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 4 ++-<=
br>
&gt;=C2=A0 arch/riscv/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 2=
 ++<br>
&gt;=C2=A0 arch/s390/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/sh/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=
=A0 4 ++-<br>
&gt;=C2=A0 arch/sparc/mm/fault_32.c=C2=A0 =C2=A0 =C2=A0 |=C2=A0 6 ++++-<br>
&gt;=C2=A0 arch/sparc/mm/fault_64.c=C2=A0 =C2=A0 =C2=A0 |=C2=A0 2 ++<br>
&gt;=C2=A0 arch/um/kernel/trap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 4=
 ++-<br>
&gt;=C2=A0 arch/unicore32/mm/fault.c=C2=A0 =C2=A0 =C2=A0| 17 +++++++-----<b=
r>
&gt;=C2=A0 arch/x86/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 4 ++-<br>
&gt;=C2=A0 arch/xtensa/mm/fault.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 4 ++-<=
br>
&gt;=C2=A0 drivers/iommu/amd_iommu_v2.c=C2=A0 |=C2=A0 4 ++-<br>
&gt;=C2=A0 drivers/iommu/intel-svm.c=C2=A0 =C2=A0 =C2=A0|=C2=A0 6 +++--<br>
&gt;=C2=A0 include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 16=
 +++++++++---<br>
&gt;=C2=A0 mm/gup.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 8 ++++--<br>
&gt;=C2=A0 mm/hmm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 |=C2=A0 4 ++-<br>
&gt;=C2=A0 mm/ksm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | 10 ++++---<br>
&gt;=C2=A0 mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0| 61 +++++++++++++++++++++----------------------<br>
&gt;=C2=A0 31 files changed, 157 insertions(+), 89 deletions(-)<br>
&gt; <br>
&gt; diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c<br>
&gt; index d73dc473fbb9..3c98dfef03a9 100644<br>
&gt; --- a/arch/alpha/mm/fault.c<br>
&gt; +++ b/arch/alpha/mm/fault.c<br>
&gt; @@ -84,6 +84,7 @@ asmlinkage void<br>
&gt;=C2=A0 do_page_fault(unsigned long address, unsigned long mmcsr,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0long cause, struct pt_r=
egs *regs)<br>
&gt;=C2=A0 {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct vm_fault vmf =3D {};<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct * vma;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm =3D current-&gt;mm;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0const struct exception_table_entry *fixup;<b=
r>
&gt; @@ -148,7 +149,8 @@ do_page_fault(unsigned long address, unsigned long=
 mmcsr,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* If for any reason at all we couldn&#39;t =
handle the fault,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 make sure we exit gracefully rather =
than endlessly redo<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 the fault.=C2=A0 */<br>
&gt; -=C2=A0 =C2=A0 =C2=A0fault =3D handle_mm_fault(vma, address, flags);<b=
r>
&gt; +=C2=A0 =C2=A0 =C2=A0vm_fault_init(&amp;vmfs, vma, flags, address);<br=
>
&gt; +=C2=A0 =C2=A0 =C2=A0fault =3D handle_mm_fault(&amp;vmf);<br>
<br>
Doesn&#39;t compile.<br>
<br>
&gt; --- a/arch/arm/mm/fault.c<br>
&gt; +++ b/arch/arm/mm/fault.c<br>
&gt; @@ -225,17 +225,17 @@ static inline bool access_error(unsigned int fsr=
, struct vm_area_struct *vma)<br>
&gt;=C2=A0 }<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 static vm_fault_t __kprobes<br>
&gt; -__do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned in=
t fsr,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int flags, s=
truct task_struct *tsk)<br>
&gt; +__do_page_fault(struct mm_struct *mm, struct vm_fault *vm, unsigned i=
nt fsr,<br>
<br>
vm_fault is *vm....<br>
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *t=
sk)<br>
&gt;=C2=A0 {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0vm_fault_t fault;<br>
&gt;=C2=A0 <br>
&gt; -=C2=A0 =C2=A0 =C2=A0vma =3D find_vma(mm, addr);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0vma =3D find_vma(mm, vmf-&gt;address);<br>
<br>
So this doesn&#39;t compile.<br>
<br>
&gt;=C2=A0 <br>
&gt;=C2=A0 check_stack:<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (vma-&gt;vm_flags &amp; VM_GROWSDOWN &amp;&amp=
; !expand_stack(vma, addr))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (vma-&gt;vm_flags &amp; VM_GROWSDOWN &amp;&amp=
; !expand_stack(vma, vmf-&gt;address))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto good_area;<=
br>
&gt;=C2=A0 out:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0return fault;<br>
&gt; @@ -424,6 +424,7 @@ static bool is_el0_instruction_abort(unsigned int =
esr)<br>
&gt;=C2=A0 static int __kprobes do_page_fault(unsigned long addr, unsigned =
int esr,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pt_regs *regs)<br>
&gt;=C2=A0 {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct vm_fault vmf =3D {};<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct mm_struct *mm;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0struct siginfo si;<br>
&gt; @@ -493,7 +494,8 @@ static int __kprobes do_page_fault(unsigned long a=
ddr, unsigned int esr,<br>
&gt;=C2=A0 #endif<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;=C2=A0 <br>
&gt; -=C2=A0 =C2=A0 =C2=A0fault =3D __do_page_fault(mm, addr, mm_flags, vm_=
flags, tsk);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0vm_fault_init(&amp;vmf, NULL, addr, mm_flags);<br=
>
&gt; +=C2=A0 =C2=A0 =C2=A0fault =3D __do_page_fault(mm, vmf, vm_flags, tsk)=
;<br>
<br>
I&#39;m betting this doesn&#39;t compile, either.<br>
<br>
/me stops looking.<br>
<br>
Cheers,<br>
<br>
Dave.<br>
-- <br>
Dave Chinner<br>
<a href=3D"mailto:david@fromorbit.com" target=3D"_blank">david@fromorbit.co=
m</a><br>
</blockquote></div></div>

--00000000000045c2c70576bc3536--
