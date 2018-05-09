Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2606B0520
	for <linux-mm@kvack.org>; Wed,  9 May 2018 10:41:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s3so26349742pfh.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 07:41:37 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f2-v6si21121361pgs.655.2018.05.09.07.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 07:41:36 -0700 (PDT)
Received: from mail-wr0-f169.google.com (mail-wr0-f169.google.com [209.85.128.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6E97C2184F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:41:35 +0000 (UTC)
Received: by mail-wr0-f169.google.com with SMTP id v15-v6so35857102wrm.10
        for <linux-mm@kvack.org>; Wed, 09 May 2018 07:41:35 -0700 (PDT)
MIME-Version: 1.0
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com> <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net> <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com>
 <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com> <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
 <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com> <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com>
 <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com>
In-Reply-To: <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 09 May 2018 14:41:23 +0000
Message-ID: <CALCETrUGjN8mhOaLqGcau-pPKm9TQW8k05hZrh52prRNdC5yQQ@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andrew Lutomirski <luto@kernel.org>, linuxram@us.ibm.com, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, May 8, 2018 at 5:40 AM Florian Weimer <fweimer@redhat.com> wrote:

> On 05/08/2018 04:49 AM, Andy Lutomirski wrote:
> > On Mon, May 7, 2018 at 2:48 AM Florian Weimer <fweimer@redhat.com>
wrote:
> >
> >> On 05/03/2018 06:05 AM, Andy Lutomirski wrote:
> >>> On Wed, May 2, 2018 at 7:11 PM Ram Pai <linuxram@us.ibm.com> wrote:
> >>>
> >>>> On Wed, May 02, 2018 at 09:23:49PM +0000, Andy Lutomirski wrote:
> >>>>>
> >>>>>> If I recall correctly, the POWER maintainer did express a strong
> >>> desire
> >>>>>> back then for (what is, I believe) their current semantics, which
my
> >>>>>> PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.
> >>>>>
> >>>>> Ram, I really really don't like the POWER semantics.  Can you give
> > some
> >>>>> justification for them?  Does POWER at least have an atomic way for
> >>>>> userspace to modify just the key it wants to modify or, even better,
> >>>>> special load and store instructions to use alternate keys?
> >>>
> >>>> I wouldn't call it POWER semantics. The way I implemented it on power
> >>>> lead to the semantics, given that nothing was explicitly stated
> >>>> about how the semantics should work within a signal handler.
> >>>
> >>> I think that this is further evidence that we should introduce a new
> >>> pkey_alloc() mode and deprecate the old.  To the extent possible, this
> >>> thing should work the same way on x86 and POWER.
> >
> >> Do you propose to change POWER or to change x86?
> >
> > Sorry for being slow to reply.  I propose to introduce a new
> > PKEY_ALLOC_something variant on x86 and POWER and to make the behavior
> > match on both.

> So basically implement PKEY_ALLOC_SETSIGNAL for POWER, and keep the
> existing (different) behavior without the flag?

> Ram, would you be okay with that?  Could you give me a hand if
> necessary?  (I assume we have silicon in-house because it's a
> long-standing feature of the POWER platform which was simply dormant on
> Linux until now.)

> > It should at least update the values loaded when a signal
> > is delivered and it should probably also update it for new threads.

> I think we should keep inheritance for new threads and fork.  pkey_alloc
> only has a single access rights argument, which makes it hard to reuse
> this interface if there are two (three) separate sets of access rights.


Hmm.  I can get on board with the idea that fork() / clone() /
pthread_create() are all just special cases of the idea that the thread
that *calls* them should have the right pkey values, and the latter is
already busted given our inability to asynchronously propagate the new mode
in pkey_alloc().  So let's so PKEY_ALLOC_SETSIGNAL as a starting point.

One thing we could do, though: the current initual state on process
creation is all access blocked on all keys.  We could change it so that
half the keys are fully blocked and half are read-only.  Then we could add
a PKEY_ALLOC_STRICT or similar that allocates a key with the correct
initial state *and* does the setsignal thing.  If there are no keys left
with the correct initial state, then it fails.
