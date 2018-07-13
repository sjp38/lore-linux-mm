Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC0B6B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 22:21:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id y7-v6so18442378plt.17
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:21:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25-v6sor7117972pfe.144.2018.07.12.19.21.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 19:21:46 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <167645aa-f1c7-bd6a-c7e0-2da317cbbaba@intel.com>
Date: Thu, 12 Jul 2018 19:21:42 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <55A0592D-0E8D-4BC5-BA4B-E82E92EEA36A@amacapital.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-19-yu-cheng.yu@intel.com> <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com> <1531436398.2965.18.camel@intel.com> <46784af0-6fbb-522d-6acb-c6248e5e0e0d@linux.intel.com> <167645aa-f1c7-bd6a-c7e0-2da317cbbaba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>



> On Jul 12, 2018, at 6:50 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 07/12/2018 04:49 PM, Dave Hansen wrote:
>>>> That seems like something we need to call out if so.  It also means we
>>>> need to update the SDM because some of the text is wrong.
>>> It needs to mention the WRUSS case.
>> Ugh.  The documentation for this is not pretty.  But, I guess this is
>> not fundamentally different from access to U=3D1 pages when SMAP is in
>> place and we've set EFLAGS.AC=3D1.
>=20
> I was wrong and misread the docs.  We do not get X86_PF_USER set when
> EFLAGS.AC=3D1.
>=20
> But, we *do* get X86_PF_USER (otherwise defined to be set when in ring3)
> when running in ring0 with the WRUSS instruction and some other various
> shadow-stack-access-related things.  I'm sure folks had a good reason
> for this architecture, but it is a pretty fundamentally *new*
> architecture that we have to account for.

I think it makes (some) sense. The USER bit is set for a page fault that was=
 done with user privilege. So a descriptor table fault at CPL 3 has USER cle=
ar (regardless of the cause of the fault) and WRUSS has USER set.

>=20
> This new architecture is also not spelled out or accounted for in the
> SDM as of yet.  It's only called out here as far as I know:
> https://software.intel.com/sites/default/files/managed/4d/2a/control-flow-=
enforcement-technology-preview.pdf
>=20
> Which reminds me:  Yu-cheng, do you have a link to the docs anywhere in
> your set?  If not, you really should.

I am tempted to suggest that the whole series not be merged until there are a=
ctual docs. It=E2=80=99s not a fantastic precedent.=
