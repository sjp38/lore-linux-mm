Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D810D6B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 17:24:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j14so1185458pfn.11
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:24:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f9-v6si250712pgr.123.2018.05.02.14.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 14:24:01 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2035D217D9
	for <linux-mm@kvack.org>; Wed,  2 May 2018 21:24:01 +0000 (UTC)
Received: by mail-wm0-f46.google.com with SMTP id j5so26878368wme.5
        for <linux-mm@kvack.org>; Wed, 02 May 2018 14:24:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com> <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
In-Reply-To: <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 02 May 2018 21:23:49 +0000
Message-ID: <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On Wed, May 2, 2018 at 2:06 PM Florian Weimer <fweimer@redhat.com> wrote:

> On 05/02/2018 10:41 PM, Andy Lutomirski wrote:

> >> See above.  The signal handler will crash if it calls any non-local
> >> function through the GOT because with the default access rights, it's
> >> not readable in the signal handler.
> >
> >> Any use of memory protection keys for basic infrastructure will run
into
> >> this problem, so I think the current kernel behavior is not very
useful.
> >>     It's also x86-specific.
> >
> >>    From a security perspective, the atomic behavior is not very useful
> >> because you generally want to modify PKRU *before* computing the
details
> >> of the memory access, so that you don't have a general =E2=80=9Cpoke a=
nywhere
> >> with this access right=E2=80=9D primitive in the text segment.  (I cal=
led this
> >> the =E2=80=9Csuffix problem=E2=80=9D in another context.)
> >
> >
> > Ugh, right.  It's been long enough that I forgot about the underlying
> > issue.  A big part of the problem here is that pkey_alloc() should set
the
> > initial value of the key across all threads, but it *can't*.  There is
> > literally no way to do it in a multithreaded program that uses RDPKRU
and
> > WRPKRU.

> The kernel could do *something*, probably along the membarrier system
> call.  I mean, I could implement a reasonable close approximation in
> userspace, via the setxid mechanism in glibc (but I really don't want to)=
.

I beg to differ.

Thread A:
old =3D RDPKRU();
WRPKRU(old & ~3);
...
WRPKRU(old);

Thread B:
pkey_alloc().

If pkey_alloc() happens while thread A is in the ... part, you lose.  It
makes no difference what the kernel does.  The problem is that the WRPKRU
instruction itself is designed incorrectly.



> > But I think the right fix, at least for your use case, is to have a
per-mm
> > init_pkru variable that starts as "deny all".  We'd add a new
pkey_alloc()
> > flag like PKEY_ALLOC_UPDATE_INITIAL_STATE that causes the specified
mode to
> > update init_pkru.  New threads and delivered signals would get the
> > init_pkru state instead of the hardcoded default.

> I implemented this for signal handlers:

>     https://marc.info/?l=3Dlinux-api&m=3D151285420302698&w=3D2

> This does not alter the thread inheritance behavior yet.  I would have
> to investigate how to implement that.

> Feedback led to the current patch, though.  I'm not sure what has
> changed since then.

What feedback?  I think the old patch was much better than the new patch.
I could point out some issues in the kernel code, and I think it should
deal with thread creation, but otherwise I think it's the right approach.

Keep in mind, though, that it's just not possible to make pkey_alloc() work
on x86 in any sensible way in a multithreaded program.


> If I recall correctly, the POWER maintainer did express a strong desire
> back then for (what is, I believe) their current semantics, which my
> PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.

Ram, I really really don't like the POWER semantics.  Can you give some
justification for them?  Does POWER at least have an atomic way for
userspace to modify just the key it wants to modify or, even better,
special load and store instructions to use alternate keys?

--Andy
