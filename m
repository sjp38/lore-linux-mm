Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9A16B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 18:23:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3so13957722pfh.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:23:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q1-v6si10491928pga.417.2018.05.02.15.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 15:23:11 -0700 (PDT)
Received: from mail-wr0-f175.google.com (mail-wr0-f175.google.com [209.85.128.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1182B21840
	for <linux-mm@kvack.org>; Wed,  2 May 2018 22:23:11 +0000 (UTC)
Received: by mail-wr0-f175.google.com with SMTP id c14-v6so15569920wrd.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 15:23:10 -0700 (PDT)
MIME-Version: 1.0
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com>
In-Reply-To: <a37b7deb-7f5a-3dfa-f360-956cab8a813a@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 02 May 2018 22:22:59 +0000
Message-ID: <CALCETrUM7wWZh55gaLiAoPqtxLLUJ4QC8r8zj62E9avJ6ZVu0w@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxram@us.ibm.com

On Wed, May 2, 2018 at 3:08 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/02/2018 02:23 PM, Andy Lutomirski wrote:
> >> The kernel could do *something*, probably along the membarrier system
> >> call.  I mean, I could implement a reasonable close approximation in
> >> userspace, via the setxid mechanism in glibc (but I really don't want
to).
> >
> > I beg to differ.
> >
> > Thread A:
> > old = RDPKRU();
> > WRPKRU(old & ~3);
> > ...
> > WRPKRU(old);
> >
> > Thread B:
> > pkey_alloc().
> >
> > If pkey_alloc() happens while thread A is in the ... part, you lose.  It
> > makes no difference what the kernel does.  The problem is that the
WRPKRU
> > instruction itself is designed incorrectly.

> Yes, *if* we define pkey_alloc() to be implicitly changing other
> threads' PKRU value.

I think that's the only generally useful behavior.  In general, if
libraries are going to use protection keys, they're going to do this:

int key = pkey_alloc(...);
mmap() or mprotect_key() some memory (for crypto secrets, a database,
whatever).
...
enable_write_access(key);
write to the memory;
disable_write_access(key);

That library wants other threads, signal handlers, and, in general, the
whole rest of the process to be restricted, and that library doesn't want
race conditions.  The problem here is that, to get this right, we either
need the PKRU modifications to be syscalls or to take locks, and the lock
approach is going to be fairly gross.


> Let's say we go to the hardware guys and ask for a new instruction to
> fix this.  We're going to have to make a pretty good case that this is
> either impossible or really hard to do in software.

> Surely we have the locking to tell another thread that we want its PKRU
> value to change without actively going out and having the kernel poke a
> new value in.

I think that doing it in userspace without a new instruction is going to be
slow, ugly, unreliable, or more than one of the above.

Here's my proposal.  We ask the hardware folks for new instructions.  Once
we get tentative agreement, we add new vDSO pkey accessors.  At first those
accessors function will do a syscall.  When we get the new instructions,
they get alternatives.  The vDSO helpers could look like this:

typedef struct { u64 opaque; } pkey_save_t;

pkey_save_t pkey_save_and_set(int key, unsigned int mode);
void pkey_set(int key, unsigned int mode);
void pkey_restore(int key, pkey_save_t prev);

Slight variants are possible.  On new hardware, pkey_set() and
pkey_restore() use the WRPKRU replacement.  pkey_save_and_set() uses the
RDPKRU replacement followed by the WRPKRU replacement.  The usage is:

pkey_save_t prev = pkey_save_and_set(my_key, 0);  /* enable read and write
*/
do something with memory;
pkey_restore(my_key, prev);

or just:

pkey_set(my_key, 0);
...
pkey_set(my_key, 3);  /* or 1 or 2 depending on the application */

And we make it very, very clear to user code that using RDPKRU and WRPKRU
directly is a big no-no.

What do you all think?  This gives us sane, if slow, behavior for current
CPUs and is decently fast on hypothetical new CPUs.
