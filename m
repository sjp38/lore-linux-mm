Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52E4C6B000A
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:22:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so15647482plf.18
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:22:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor6105181pfn.12.2018.07.11.15.22.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 15:22:01 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack support
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAG48ez1OwQMmhQfHaauo+vneywsQ_ERKr4uVcQebC=GbdqZWtA@mail.gmail.com>
Date: Wed, 11 Jul 2018 15:21:58 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <A034EC34-13E7-4AEF-BB3C-FEF14143B601@amacapital.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-18-yu-cheng.yu@intel.com> <CAG48ez1ytOfQyNZMNPFp7XqKcpd7_aRai9G5s7rx0V=8ZG+r2A@mail.gmail.com> <6F5FEFFD-0A9A-4181-8D15-5FC323632BA6@amacapital.net> <CAG48ez1OwQMmhQfHaauo+vneywsQ_ERKr4uVcQebC=GbdqZWtA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: yu-cheng.yu@intel.com, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com


> On Jul 11, 2018, at 2:51 PM, Jann Horn <jannh@google.com> wrote:
>=20
> On Wed, Jul 11, 2018 at 2:34 PM Andy Lutomirski <luto@amacapital.net> wrot=
e:
>>> On Jul 11, 2018, at 2:10 PM, Jann Horn <jannh@google.com> wrote:
>>>=20
>>>> On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wro=
te:
>>>>=20
>>>> This patch adds basic shadow stack enabling/disabling routines.
>>>> A task's shadow stack is allocated from memory with VM_SHSTK
>>>> flag set and read-only protection.  The shadow stack is
>>>> allocated to a fixed size.
>>>>=20
>>>> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
>>> [...]
>>>> diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
>>>> new file mode 100644
>>>> index 000000000000..96bf69db7da7
>>>> --- /dev/null
>>>> +++ b/arch/x86/kernel/cet.c
>>> [...]
>>>> +static unsigned long shstk_mmap(unsigned long addr, unsigned long len)=

>>>> +{
>>>> +       struct mm_struct *mm =3D current->mm;
>>>> +       unsigned long populate;
>>>> +
>>>> +       down_write(&mm->mmap_sem);
>>>> +       addr =3D do_mmap(NULL, addr, len, PROT_READ,
>>>> +                      MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
>>>> +                      0, &populate, NULL);
>>>> +       up_write(&mm->mmap_sem);
>>>> +
>>>> +       if (populate)
>>>> +               mm_populate(addr, populate);
>>>> +
>>>> +       return addr;
>>>> +}
> [...]
>>> Should the kernel enforce that two shadow stacks must have a guard
>>> page between them so that they can not be directly adjacent, so that
>>> if you have too much recursion, you can't end up corrupting an
>>> adjacent shadow stack?
>>=20
>> I think the answer is a qualified =E2=80=9Cno=E2=80=9D. I would like to i=
nstead enforce a general guard page on all mmaps that don=E2=80=99t use MAP_=
FORCE. We *might* need to exempt any mmap with an address hint for compatibi=
lity.
>=20
> I like this idea a lot.
>=20
>> My commercial software has been manually adding guard pages on every sing=
le mmap done by tcmalloc for years, and it has caught a couple bugs and cost=
s essentially nothing.
>>=20
>> Hmm. Linux should maybe add something like Windows=E2=80=99 =E2=80=9Crese=
rved=E2=80=9D virtual memory. It=E2=80=99s basically a way to ask for a VA r=
ange that explicitly contains nothing and can be subsequently be turned into=
 something useful with the equivalent of MAP_FORCE.
>=20
> What's the benefit over creating an anonymous PROT_NONE region? That
> the kernel won't have to scan through the corresponding PTEs when
> tearing down the mapping?

Make it more obvious what=E2=80=99s happening and avoid accounting issues?  W=
hat I=E2=80=99ve actually used is MAP_NORESERVE | PROT_NONE, but I think thi=
s still counts against the VA rlimit. But maybe that=E2=80=99s actually the d=
esired behavior.
