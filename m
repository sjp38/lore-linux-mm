Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 459706B7B9B
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:19:52 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v12so894697plp.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:19:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t9si880034plq.337.2018.12.06.11.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 11:19:50 -0800 (PST)
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4FEA3215EA
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 19:19:50 +0000 (UTC)
Received: by mail-wm1-f53.google.com with SMTP id c126so2221844wmh.0
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:19:50 -0800 (PST)
MIME-Version: 1.0
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com> <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com> <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com> <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com> <20181206190115.GC10086@cisco>
In-Reply-To: <20181206190115.GC10086@cisco>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 6 Dec 2018 11:19:36 -0800
Message-ID: <CALCETrUmxht8dibJPBbPudQnoe6mHsKocEBgkJ7O1eFrVBfekQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@tycho.ws>
Cc: Andrew Lutomirski <luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Nadav Amit <nadav.amit@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Thu, Dec 6, 2018 at 11:01 AM Tycho Andersen <tycho@tycho.ws> wrote:
>
> On Thu, Dec 06, 2018 at 10:53:50AM -0800, Andy Lutomirski wrote:
> > > If we are going to unmap the linear alias, why not do it at vmalloc()
> > > time rather than vfree() time?
> >
> > That=E2=80=99s not totally nuts. Do we ever have code that expects __va=
() to
> > work on module data?  Perhaps crypto code trying to encrypt static
> > data because our APIs don=E2=80=99t understand virtual addresses.  I gu=
ess if
> > highmem is ever used for modules, then we should be fine.
> >
> > RO instead of not present might be safer.  But I do like the idea of
> > renaming Rick's flag to something like VM_XPFO or VM_NO_DIRECT_MAP and
> > making it do all of this.
>
> Yeah, doing it for everything automatically seemed like it was/is
> going to be a lot of work to debug all the corner cases where things
> expect memory to be mapped but don't explicitly say it. And in
> particular, the XPFO series only does it for user memory, whereas an
> additional flag like this would work for extra paranoid allocations
> of kernel memory too.
>

I just read the code, and I looks like vmalloc() is already using
highmem (__GFP_HIGH) if available, so, on big x86_32 systems, for
example, we already don't have modules in the direct map.

So I say we go for it.  This should be quite simple to implement --
the pageattr code already has almost all the needed logic on x86.  The
only arch support we should need is a pair of functions to remove a
vmalloc address range from the address map (if it was present in the
first place) and a function to put it back.  On x86, this should only
be a few lines of code.

What do you all think?  This should solve most of the problems we have.

If we really wanted to optimize this, we'd make it so that
module_alloc() allocates memory the normal way, then, later on, we
call some function that, all at once, removes the memory from the
direct map and applies the right permissions to the vmalloc alias (or
just makes the vmalloc alias not-present so we can add permissions
later without flushing), and flushes the TLB.  And we arrange for
vunmap to zap the vmalloc range, then put the memory back into the
direct map, then free the pages back to the page allocator, with the
flush in the appropriate place.

I don't see why the page allocator needs to know about any of this.
It's already okay with the permissions being changed out from under it
on x86, and it seems fine.  Rick, do you want to give some variant of
this a try?
