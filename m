Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6704B6B7B9F
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:21:07 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t2so1099293pfj.15
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:21:07 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d65si929829pfc.201.2018.12.06.11.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 11:21:06 -0800 (PST)
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D829921722
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 19:21:05 +0000 (UTC)
Received: by mail-wm1-f54.google.com with SMTP id r24so14804807wmh.0
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:21:05 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com> <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com> <CAKv+Gu_Fo3qG1DaA2T1MZZau_7e6rzZQY7eJ49FQDQe0QnOgHg@mail.gmail.com>
In-Reply-To: <CAKv+Gu_Fo3qG1DaA2T1MZZau_7e6rzZQY7eJ49FQDQe0QnOgHg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Dec 2018 11:20:51 -0800
Message-ID: <CALCETrUUe+X6dAfcqkL=Lncy5RyDHx6m4s1g9QgMWPE9kOBoVw@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrew Lutomirski <luto@kernel.org>, Will Deacon <will.deacon@arm.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Nadav Amit <nadav.amit@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Dec 6, 2018 at 11:04 AM Ard Biesheuvel
<ard.biesheuvel@linaro.org> wrote:
>
> On Thu, 6 Dec 2018 at 19:54, Andy Lutomirski <luto@kernel.org> wrote:
> >

> > That=E2=80=99s not totally nuts. Do we ever have code that expects __va=
() to
> > work on module data?  Perhaps crypto code trying to encrypt static
> > data because our APIs don=E2=80=99t understand virtual addresses.  I gu=
ess if
> > highmem is ever used for modules, then we should be fine.
> >
>
> The crypto code shouldn't care, but I think it will probably break hibern=
ate :-(

How so?  Hibernate works (or at least should work) on x86 PAE, where
__va doesn't work on module data, and, on x86, the direct map has some
RO parts with where the module is, so hibernate can't be writing to
the memory through the direct map with its final permissions.
