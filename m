Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB626B0010
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:51:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s200-v6so36917533oie.6
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:51:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f205-v6sor5558696oia.274.2018.07.11.14.51.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 14:51:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-18-yu-cheng.yu@intel.com>
 <CAG48ez1ytOfQyNZMNPFp7XqKcpd7_aRai9G5s7rx0V=8ZG+r2A@mail.gmail.com> <6F5FEFFD-0A9A-4181-8D15-5FC323632BA6@amacapital.net>
In-Reply-To: <6F5FEFFD-0A9A-4181-8D15-5FC323632BA6@amacapital.net>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Jul 2018 14:51:21 -0700
Message-ID: <CAG48ez1OwQMmhQfHaauo+vneywsQ_ERKr4uVcQebC=GbdqZWtA@mail.gmail.com>
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack support
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: yu-cheng.yu@intel.com, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Wed, Jul 11, 2018 at 2:34 PM Andy Lutomirski <luto@amacapital.net> wrote=
:
> > On Jul 11, 2018, at 2:10 PM, Jann Horn <jannh@google.com> wrote:
> >
> >> On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wr=
ote:
> >>
> >> This patch adds basic shadow stack enabling/disabling routines.
> >> A task's shadow stack is allocated from memory with VM_SHSTK
> >> flag set and read-only protection.  The shadow stack is
> >> allocated to a fixed size.
> >>
> >> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > [...]
> >> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> >> new file mode 100644
> >> index 000000000000..96bf69db7da7
> >> --- /dev/null
> >> +++ b/arch/x86/kernel/cet.c
> > [...]
> >> +static unsigned long shstk_mmap(unsigned long addr, unsigned long len=
)
> >> +{
> >> +       struct mm_struct *mm =3D current->mm;
> >> +       unsigned long populate;
> >> +
> >> +       down_write(&mm->mmap_sem);
> >> +       addr =3D do_mmap(NULL, addr, len, PROT_READ,
> >> +                      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
> >> +                      0, &populate, NULL);
> >> +       up_write(&mm->mmap_sem);
> >> +
> >> +       if (populate)
> >> +               mm_populate(addr, populate);
> >> +
> >> +       return addr;
> >> +}
[...]
> > Should the kernel enforce that two shadow stacks must have a guard
> > page between them so that they can not be directly adjacent, so that
> > if you have too much recursion, you can't end up corrupting an
> > adjacent shadow stack?
>
> I think the answer is a qualified =E2=80=9Cno=E2=80=9D. I would like to i=
nstead enforce a general guard page on all mmaps that don=E2=80=99t use MAP=
_FORCE. We *might* need to exempt any mmap with an address hint for compati=
bility.

I like this idea a lot.

> My commercial software has been manually adding guard pages on every sing=
le mmap done by tcmalloc for years, and it has caught a couple bugs and cos=
ts essentially nothing.
>
> Hmm. Linux should maybe add something like Windows=E2=80=99 =E2=80=9Crese=
rved=E2=80=9D virtual memory. It=E2=80=99s basically a way to ask for a VA =
range that explicitly contains nothing and can be subsequently be turned in=
to something useful with the equivalent of MAP_FORCE.

What's the benefit over creating an anonymous PROT_NONE region? That
the kernel won't have to scan through the corresponding PTEs when
tearing down the mapping?
