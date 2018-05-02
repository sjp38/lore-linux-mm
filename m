Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3606B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 16:41:42 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a9-v6so10864101pgt.6
        for <linux-mm@kvack.org>; Wed, 02 May 2018 13:41:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t14si10015245pfh.101.2018.05.02.13.41.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 13:41:41 -0700 (PDT)
Received: from mail-wr0-f176.google.com (mail-wr0-f176.google.com [209.85.128.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9AAB423954
	for <linux-mm@kvack.org>; Wed,  2 May 2018 20:41:40 +0000 (UTC)
Received: by mail-wr0-f176.google.com with SMTP id i14-v6so12201954wre.2
        for <linux-mm@kvack.org>; Wed, 02 May 2018 13:41:40 -0700 (PDT)
MIME-Version: 1.0
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
In-Reply-To: <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 02 May 2018 20:41:28 +0000
Message-ID: <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On Wed, May 2, 2018 at 10:17 AM Florian Weimer <fweimer@redhat.com> wrote:

> On 05/02/2018 07:09 PM, Andy Lutomirski wrote:
> >> Nick Clifton wrote a binutils patch which puts the .got.plt section on
separate pages.  We allocate a protection key for it, assign it to all such
sections in the process image, and change the access rights of the main
thread to disallow writes via that key during process startup.  In
_dl_fixup, we enable write access to the GOT, update the GOT entry, and
then disable it again.
> >>
> >> This way, we have a pretty safe form of lazy binding, without having
to resort to BIND_NOW.
> >>
> >> With the current kernel behavior on x86, we cannot do that because
signal handlers revert to the default (deny) access rights, so the GOT
turns inaccessible.

> > Dave is right: the current behavior was my request, and I still think
it=E2=80=99s correct.  The whole point is that, even if something nasty hap=
pens
like a SIGALRM handler hitting in the middle of _dl_fixup, the SIGALRM
handler is preventing from accidentally writing to the protected memory.
When SIGALRM returns, PKRU should get restored
> >
> > Another way of looking at this is that the kernel would like to
approximate what the ISA behavior*should*  have been: the whole sequence
=E2=80=9Cmodify PKRU; access memory; restore PKRU=E2=80=9D should be as ato=
mic as possible.
> >
> > Florian, what is the actual problematic sequence of events?

> See above.  The signal handler will crash if it calls any non-local
> function through the GOT because with the default access rights, it's
> not readable in the signal handler.

> Any use of memory protection keys for basic infrastructure will run into
> this problem, so I think the current kernel behavior is not very useful.
>    It's also x86-specific.

>   From a security perspective, the atomic behavior is not very useful
> because you generally want to modify PKRU *before* computing the details
> of the memory access, so that you don't have a general =E2=80=9Cpoke anyw=
here
> with this access right=E2=80=9D primitive in the text segment.  (I called=
 this
> the =E2=80=9Csuffix problem=E2=80=9D in another context.)


Ugh, right.  It's been long enough that I forgot about the underlying
issue.  A big part of the problem here is that pkey_alloc() should set the
initial value of the key across all threads, but it *can't*.  There is
literally no way to do it in a multithreaded program that uses RDPKRU and
WRPKRU.

But I think the right fix, at least for your use case, is to have a per-mm
init_pkru variable that starts as "deny all".  We'd add a new pkey_alloc()
flag like PKEY_ALLOC_UPDATE_INITIAL_STATE that causes the specified mode to
update init_pkru.  New threads and delivered signals would get the
init_pkru state instead of the hardcoded default.
