Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7EF6B7CF4
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 18:08:08 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so1617155pfj.3
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 15:08:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j193sor3007109pge.29.2018.12.06.15.08.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 15:08:06 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrUbmmcL7pixsP9AH1-AE2WMVgbDkoP_E4wAJMbuZ0CzCg@mail.gmail.com>
Date: Thu, 6 Dec 2018 15:08:02 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <EFB09636-D34F-4C63-87E6-76C49007C2CA@gmail.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
 <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
 <20181204160304.GB7195@arm.com>
 <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
 <20181205114148.GA15160@arm.com>
 <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com>
 <20181206190115.GC10086@cisco>
 <CALCETrUmxht8dibJPBbPudQnoe6mHsKocEBgkJ7O1eFrVBfekQ@mail.gmail.com>
 <F5664C1D-C3E7-433B-8E5A-7967023E0567@gmail.com>
 <CALCETrUbmmcL7pixsP9AH1-AE2WMVgbDkoP_E4wAJMbuZ0CzCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Tycho Andersen <tycho@tycho.ws>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Rick Edgecombe <rick.p.edgecombe@intel.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Alexei Starovoitov <ast@kernel.org>, Linux-MM <linux-mm@kvack.org>, Jann Horn <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Peter Zijlstra <peterz@infradead.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Masami Hiramatsu <mhiramat@kernel.org>, "Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Network Development <netdev@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Igor Stoppa <igor.stoppa@gmail.com>

> On Dec 6, 2018, at 12:17 PM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> On Thu, Dec 6, 2018 at 11:39 AM Nadav Amit <nadav.amit@gmail.com> =
wrote:
>>> On Dec 6, 2018, at 11:19 AM, Andy Lutomirski <luto@kernel.org> =
wrote:
>>>=20
>>> On Thu, Dec 6, 2018 at 11:01 AM Tycho Andersen <tycho@tycho.ws> =
wrote:
>>>> On Thu, Dec 06, 2018 at 10:53:50AM -0800, Andy Lutomirski wrote:
>>>>>> If we are going to unmap the linear alias, why not do it at =
vmalloc()
>>>>>> time rather than vfree() time?
>>>>>=20
>>>>> That=E2=80=99s not totally nuts. Do we ever have code that expects =
__va() to
>>>>> work on module data?  Perhaps crypto code trying to encrypt static
>>>>> data because our APIs don=E2=80=99t understand virtual addresses.  =
I guess if
>>>>> highmem is ever used for modules, then we should be fine.
>>>>>=20
>>>>> RO instead of not present might be safer.  But I do like the idea =
of
>>>>> renaming Rick's flag to something like VM_XPFO or VM_NO_DIRECT_MAP =
and
>>>>> making it do all of this.
>>>>=20
>>>> Yeah, doing it for everything automatically seemed like it was/is
>>>> going to be a lot of work to debug all the corner cases where =
things
>>>> expect memory to be mapped but don't explicitly say it. And in
>>>> particular, the XPFO series only does it for user memory, whereas =
an
>>>> additional flag like this would work for extra paranoid allocations
>>>> of kernel memory too.
>>>=20
>>> I just read the code, and I looks like vmalloc() is already using
>>> highmem (__GFP_HIGH) if available, so, on big x86_32 systems, for
>>> example, we already don't have modules in the direct map.
>>>=20
>>> So I say we go for it.  This should be quite simple to implement --
>>> the pageattr code already has almost all the needed logic on x86.  =
The
>>> only arch support we should need is a pair of functions to remove a
>>> vmalloc address range from the address map (if it was present in the
>>> first place) and a function to put it back.  On x86, this should =
only
>>> be a few lines of code.
>>>=20
>>> What do you all think?  This should solve most of the problems we =
have.
>>>=20
>>> If we really wanted to optimize this, we'd make it so that
>>> module_alloc() allocates memory the normal way, then, later on, we
>>> call some function that, all at once, removes the memory from the
>>> direct map and applies the right permissions to the vmalloc alias =
(or
>>> just makes the vmalloc alias not-present so we can add permissions
>>> later without flushing), and flushes the TLB.  And we arrange for
>>> vunmap to zap the vmalloc range, then put the memory back into the
>>> direct map, then free the pages back to the page allocator, with the
>>> flush in the appropriate place.
>>>=20
>>> I don't see why the page allocator needs to know about any of this.
>>> It's already okay with the permissions being changed out from under =
it
>>> on x86, and it seems fine.  Rick, do you want to give some variant =
of
>>> this a try?
>>=20
>> Setting it as read-only may work (and already happens for the =
read-only
>> module data). I am not sure about setting it as non-present.
>>=20
>> At some point, a discussion about a threat-model, as Rick indicated, =
would
>> be required. I presume ROP attacks can easily call =
set_all_modules_text_rw()
>> and override all the protections.
>=20
> I am far from an expert on exploit techniques, but here's a
> potentially useful model: let's assume there's an attacker who can
> write controlled data to a controlled kernel address but cannot
> directly modify control flow.  It would be nice for such an attacker
> to have a very difficult time of modifying kernel text or of
> compromising control flow.  So we're assuming a feature like kernel
> CET or that the attacker finds it very difficult to do something like
> modifying some thread's IRET frame.
>=20
> Admittedly, for the kernel, this is an odd threat model, since an
> attacker can presumably quite easily learn the kernel stack address of
> one of their tasks, do some syscall, and then modify their kernel
> thread's stack such that it will IRET right back to a fully controlled
> register state with RSP pointing at an attacker-supplied kernel stack.
> So this threat model gives very strong ROP powers. unless we have
> either CET or some software technique to harden all the RET
> instructions in the kernel.
>=20
> I wonder if there's a better model to use.  Maybe with stack-protector
> we get some degree of protection?  Or is all of this is rather weak
> until we have CET or a RAP-like feature.

I believe that seeing the end-goal would make reasoning about patches
easier, otherwise the complaint =E2=80=9Cbut anyhow it=E2=80=99s all =
insecure=E2=80=9D keeps popping
up.

I=E2=80=99m not sure CET or other CFI would be enough even with this =
threat-model.
The page-tables (the very least) need to be write-protected, as =
otherwise
controlled data writes may just modify them. There are various possible
solutions I presume: write_rare for page-tables, hypervisor-assisted
security to obtain physical level NX/RO (a-la Microsoft VBS) or some =
sort of
hardware enclave.

What do you think?=
