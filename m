Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5AAA6B7BA2
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:23:33 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so1918120itc.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:23:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11sor665269ioh.77.2018.12.06.11.23.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 11:23:32 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com> <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com>
 <CAKv+Gu_Fo3qG1DaA2T1MZZau_7e6rzZQY7eJ49FQDQe0QnOgHg@mail.gmail.com> <CALCETrUUe+X6dAfcqkL=Lncy5RyDHx6m4s1g9QgMWPE9kOBoVw@mail.gmail.com>
In-Reply-To: <CALCETrUUe+X6dAfcqkL=Lncy5RyDHx6m4s1g9QgMWPE9kOBoVw@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 6 Dec 2018 20:23:20 +0100
Message-ID: <CAKv+Gu8pQcb_5AoRS8yyvT0FxHTe=yUQYNoQX2z6mysyC9noZA@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Will Deacon <will.deacon@arm.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Nadav Amit <nadav.amit@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, kristen@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, anil.s.keshavamurthy@intel.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, naveen.n.rao@linux.vnet.ibm.com, "David S. Miller" <davem@davemloft.net>, "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, 6 Dec 2018 at 20:21, Andy Lutomirski <luto@kernel.org> wrote:
>
> On Thu, Dec 6, 2018 at 11:04 AM Ard Biesheuvel
> <ard.biesheuvel@linaro.org> wrote:
> >
> > On Thu, 6 Dec 2018 at 19:54, Andy Lutomirski <luto@kernel.org> wrote:
> > >
>
> > > That=E2=80=99s not totally nuts. Do we ever have code that expects __=
va() to
> > > work on module data?  Perhaps crypto code trying to encrypt static
> > > data because our APIs don=E2=80=99t understand virtual addresses.  I =
guess if
> > > highmem is ever used for modules, then we should be fine.
> > >
> >
> > The crypto code shouldn't care, but I think it will probably break hibe=
rnate :-(
>
> How so?  Hibernate works (or at least should work) on x86 PAE, where
> __va doesn't work on module data, and, on x86, the direct map has some
> RO parts with where the module is, so hibernate can't be writing to
> the memory through the direct map with its final permissions.

On arm64 at least, hibernate reads the contents of memory via the
linear mapping. Not sure about other arches.
