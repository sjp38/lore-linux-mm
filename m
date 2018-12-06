Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 529716B7BB3
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:30:49 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id t13so657858otk.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:30:49 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 2si470232otr.63.2018.12.06.11.30.48
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 11:30:48 -0800 (PST)
Date: Thu, 6 Dec 2018 19:31:08 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Message-ID: <20181206193108.GA21002@arm.com>
References: <20181204160304.GB7195@arm.com>
 <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com>
 <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com>
 <CAKv+Gu_Fo3qG1DaA2T1MZZau_7e6rzZQY7eJ49FQDQe0QnOgHg@mail.gmail.com>
 <CALCETrUUe+X6dAfcqkL=Lncy5RyDHx6m4s1g9QgMWPE9kOBoVw@mail.gmail.com>
 <CAKv+Gu8pQcb_5AoRS8yyvT0FxHTe=yUQYNoQX2z6mysyC9noZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKv+Gu8pQcb_5AoRS8yyvT0FxHTe=yUQYNoQX2z6mysyC9noZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andy Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Nadav Amit <nadav.amit@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, kristen@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, anil.s.keshavamurthy@intel.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, naveen.n.rao@linux.vnet.ibm.com, "David S. Miller" <davem@davemloft.net>, "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Dec 06, 2018 at 08:23:20PM +0100, Ard Biesheuvel wrote:
> On Thu, 6 Dec 2018 at 20:21, Andy Lutomirski <luto@kernel.org> wrote:
> >
> > On Thu, Dec 6, 2018 at 11:04 AM Ard Biesheuvel
> > <ard.biesheuvel@linaro.org> wrote:
> > >
> > > On Thu, 6 Dec 2018 at 19:54, Andy Lutomirski <luto@kernel.org> wrote:
> > > >
> >
> > > > That’s not totally nuts. Do we ever have code that expects __va() to
> > > > work on module data?  Perhaps crypto code trying to encrypt static
> > > > data because our APIs don’t understand virtual addresses.  I guess if
> > > > highmem is ever used for modules, then we should be fine.
> > > >
> > >
> > > The crypto code shouldn't care, but I think it will probably break hibernate :-(
> >
> > How so?  Hibernate works (or at least should work) on x86 PAE, where
> > __va doesn't work on module data, and, on x86, the direct map has some
> > RO parts with where the module is, so hibernate can't be writing to
> > the memory through the direct map with its final permissions.
> 
> On arm64 at least, hibernate reads the contents of memory via the
> linear mapping. Not sure about other arches.

Can we handle this like the DEBUG_PAGEALLOC case, and extract the pfn from
the pte when we see that it's PROT_NONE?

Will
