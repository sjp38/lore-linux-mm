Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4846B06DB
	for <linux-mm@kvack.org>; Sat, 19 May 2018 19:47:39 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d4-v6so7510189plr.17
        for <linux-mm@kvack.org>; Sat, 19 May 2018 16:47:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3-v6si7083652plq.56.2018.05.19.16.47.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 16:47:37 -0700 (PDT)
Received: from mail-wr0-f178.google.com (mail-wr0-f178.google.com [209.85.128.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E20AA2085A
	for <linux-mm@kvack.org>; Sat, 19 May 2018 23:47:36 +0000 (UTC)
Received: by mail-wr0-f178.google.com with SMTP id w3-v6so4842228wrl.12
        for <linux-mm@kvack.org>; Sat, 19 May 2018 16:47:36 -0700 (PDT)
MIME-Version: 1.0
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com> <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
 <20180519202747.GK5479@ram.oc3035372033.ibm.com>
In-Reply-To: <20180519202747.GK5479@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 19 May 2018 16:47:23 -0700
Message-ID: <CALCETrVz9otkOQAxVkz6HtuMwjAeY6mMuLgFK_o0M0kbkUznwg@mail.gmail.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Andrew Lutomirski <luto@kernel.org>, Florian Weimer <fweimer@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Sat, May 19, 2018 at 1:28 PM Ram Pai <linuxram@us.ibm.com> wrote:

> You got it mostly right. Filling in some more details below for
> completeness.

> [...]

Okay, so I guess I was correct as to what the functionality was but not as
to the encoding or the name of UAMOR.

Can you also confirm that mprotect_key() affects all threads?


> And finally the kernel reserves some subset of keys, in advance, that
> it wants for itself. It will never give away those keys to userspace
> through sys_pkey_alloc(), and the bits corresponding to those keys will
> be 0 in UAMOR register.

> >
> > Here's my question: given that disallowed AMR bits are read-as-zero,
there
> > can always be a thread that is in the middle of a sequence like:
> >
> > step1 : unsigned long old = amr;
> > step2 : amr |= whatever;
> > step3 : ...  <- thread is here
> > step4 : amr = old;
> >
> > Now another thread calls pkey_alloc(), so UAMR is asynchronously
changed,
> > and the thread will write zero to the relevant AMR bits.

> > If I understand
> > correctly, this means that the decision to mask off unallocated keys via
> > UAMR effectively forces the initial value of newly-allocated keys in
other
> > threads in the allocating process to be zero, whatever zero means.

> The initial value of the newly allocated key will be whatever the
> init_value is, that is specified in the sys_pkey_alloc().

> Remember, the UAMOR and the AMR values are thread specific. If thread T2
> allocates a new key, then that thread will enable the bit in its version
> of the UAMOR register. It will not have any effect on the UAMOR value of
> any other threads's version.

So is it possible for two threads to each call pkey_alloc() and end up with
the same key?  If so, it seems entirely broken.  If not, then how do you
intend for a multithreaded application to usefully allocate a new key?
Regardless, it seems like the current behavior on POWER is very difficult
to work with.  Can you give an example of a use case for which POWER's
behavior makes sense?

For the use cases I've imagined, POWER's behavior does not make sense.
  x86's is not ideal but is still better.  Here are my two example use cases:

1. A crypto library.  Suppose I'm writing a TLS-terminating server, and I
want it to be resistant to Heartbleed-like bugs.  I could store my private
keys protected by mprotect_key() and arrange for all threads and signal
handlers to have PKRU/AMR values that prevent any access to the memory.
When an explicit call is made to sign with the key, I would temporarily
change PKRU/AMR to allow access, compute the signature, and change PKRU/AMR
back.  On x86 right now, this works nicely.  On POWER, it doesn't, because
any thread started before my pkey_alloc() call can access the protected
memory, as can any signal handler.

2. A database using mmap() (with persistent memory or otherwise).  It would
be nice to be resistant to accidental corruption due to stray writes.  I
would do more or less the same thing as (1), except that I would want
threads that are not actively writing to the database to be able the
protected memory.  On x86, I need to manually convince threads that may
have been started before my pkey_alloc() call as well as signal handlers to
update their PKRU values.  On POWER, as in example (1), the error goes the
other direction -- if I fail to propagate the AMR bits to all threads,
writes are not blocked.

--Andy
