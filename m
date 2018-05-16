Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9676B0364
	for <linux-mm@kvack.org>; Wed, 16 May 2018 16:55:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63-v6so1299503pfl.12
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:55:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x187-v6si2838156pgb.335.2018.05.16.13.55.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 13:55:08 -0700 (PDT)
Received: from mail-wr0-f180.google.com (mail-wr0-f180.google.com [209.85.128.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C328C20858
	for <linux-mm@kvack.org>; Wed, 16 May 2018 20:55:07 +0000 (UTC)
Received: by mail-wr0-f180.google.com with SMTP id y15-v6so3317646wrg.11
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:55:07 -0700 (PDT)
MIME-Version: 1.0
References: <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com> <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
 <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com> <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com>
 <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com> <CALCETrUGjN8mhOaLqGcau-pPKm9TQW8k05hZrh52prRNdC5yQQ@mail.gmail.com>
 <008010c1-20a1-c307-25ac-8a69d672d031@redhat.com> <20180516205244.GB5479@ram.oc3035372033.ibm.com>
In-Reply-To: <20180516205244.GB5479@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 16 May 2018 13:54:54 -0700
Message-ID: <CALCETrXzt3V9metjBuZm7D-JDr0VoHSjacXAXO+j69LHoMKC0Q@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Florian Weimer <fweimer@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, May 16, 2018 at 1:52 PM Ram Pai <linuxram@us.ibm.com> wrote:

> On Mon, May 14, 2018 at 02:01:23PM +0200, Florian Weimer wrote:
> > On 05/09/2018 04:41 PM, Andy Lutomirski wrote:
> > >Hmm.  I can get on board with the idea that fork() / clone() /
> > >pthread_create() are all just special cases of the idea that the thread
> > >that*calls*  them should have the right pkey values, and the latter is
> > >already busted given our inability to asynchronously propagate the new
mode
> > >in pkey_alloc().  So let's so PKEY_ALLOC_SETSIGNAL as a starting point.
> >
> > Ram, any suggestions for implementing this on POWER?

> I suspect the changes will go in
> restore_user_regs() and save_user_regs().  These are the functions
> that save and restore register state before entry and exit into/from
> a signal handler.

> >
> > >One thing we could do, though: the current initual state on process
> > >creation is all access blocked on all keys.  We could change it so that
> > >half the keys are fully blocked and half are read-only.  Then we could
add
> > >a PKEY_ALLOC_STRICT or similar that allocates a key with the correct
> > >initial state*and*  does the setsignal thing.  If there are no keys
left
> > >with the correct initial state, then it fails.
> >
> > The initial PKRU value can currently be configured by the system
> > administrator.  I fear this approach has too many moving parts to be
> > viable.

> Sounds like on x86  keys can go active in signal-handler
> without any explicit allocation request by the application.  This is not
> the case on power. Is that API requirement? Hope not.

On x86, signals are currently delivered with all keys locked all the way
down (except for the magic one we use to emulate no-read access).  I would
hesitate to change this for existing applications.
