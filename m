Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD726B035A
	for <linux-mm@kvack.org>; Wed, 16 May 2018 16:38:00 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f5-v6so815718pgq.19
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:38:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m8-v6si3240242plt.29.2018.05.16.13.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 13:38:00 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5E15D2083F
	for <linux-mm@kvack.org>; Wed, 16 May 2018 20:37:59 +0000 (UTC)
Received: by mail-wm0-f47.google.com with SMTP id f8-v6so4993263wmc.4
        for <linux-mm@kvack.org>; Wed, 16 May 2018 13:37:59 -0700 (PDT)
MIME-Version: 1.0
References: <57459C6F-C8BA-4E2D-99BA-64F35C11FC05@amacapital.net>
 <6286ba0a-7e09-b4ec-e31f-bd091f5940ff@redhat.com> <CALCETrVrm6yGiv6_z7RqdeB-324RoeMmjpf1EHsrGOh+iKb7+A@mail.gmail.com>
 <b2df1386-9df9-2db8-0a25-51bf5ff63592@redhat.com> <CALCETrW_Dt-HoG4keFJd8DSD=tvyR+bBCFrBDYdym4GQbfng4A@mail.gmail.com>
 <20180503021058.GA5670@ram.oc3035372033.ibm.com> <CALCETrXRQF08exQVZqtTLOKbC8Ywq5x4EYH_1D7r5v9bdOSwbg@mail.gmail.com>
 <927c8325-4c98-d7af-b921-6aafcf8fe992@redhat.com> <CALCETrX46wR_MDW=m9SVm=ejQmPAmD3+2oC3iapf75bPhnEAWQ@mail.gmail.com>
 <314e1a48-db94-9b37-8793-a95a2082c9e2@redhat.com> <20180516203534.GA5479@ram.oc3035372033.ibm.com>
In-Reply-To: <20180516203534.GA5479@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 16 May 2018 13:37:46 -0700
Message-ID: <CALCETrVQs=ix-w9_MLJWikzmBG-e2Fzg61TrZLNVv5R3XFOs=g@mail.gmail.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Florian Weimer <fweimer@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, May 16, 2018 at 1:35 PM Ram Pai <linuxram@us.ibm.com> wrote:

> On Tue, May 08, 2018 at 02:40:46PM +0200, Florian Weimer wrote:
> > On 05/08/2018 04:49 AM, Andy Lutomirski wrote:
> > >On Mon, May 7, 2018 at 2:48 AM Florian Weimer <fweimer@redhat.com>
wrote:
> > >
> > >>On 05/03/2018 06:05 AM, Andy Lutomirski wrote:
> > >>>On Wed, May 2, 2018 at 7:11 PM Ram Pai <linuxram@us.ibm.com> wrote:
> > >>>
> > >>>>On Wed, May 02, 2018 at 09:23:49PM +0000, Andy Lutomirski wrote:
> > >>>>>
> > >>>>>>If I recall correctly, the POWER maintainer did express a strong
> > >>>desire
> > >>>>>>back then for (what is, I believe) their current semantics, which
my
> > >>>>>>PKEY_ALLOC_SIGNALINHERIT patch implements for x86, too.
> > >>>>>
> > >>>>>Ram, I really really don't like the POWER semantics.  Can you give
> > >some
> > >>>>>justification for them?  Does POWER at least have an atomic way for
> > >>>>>userspace to modify just the key it wants to modify or, even
better,
> > >>>>>special load and store instructions to use alternate keys?
> > >>>
> > >>>>I wouldn't call it POWER semantics. The way I implemented it on
power
> > >>>>lead to the semantics, given that nothing was explicitly stated
> > >>>>about how the semantics should work within a signal handler.
> > >>>
> > >>>I think that this is further evidence that we should introduce a new
> > >>>pkey_alloc() mode and deprecate the old.  To the extent possible,
this
> > >>>thing should work the same way on x86 and POWER.
> > >
> > >>Do you propose to change POWER or to change x86?
> > >
> > >Sorry for being slow to reply.  I propose to introduce a new
> > >PKEY_ALLOC_something variant on x86 and POWER and to make the behavior
> > >match on both.
> >
> > So basically implement PKEY_ALLOC_SETSIGNAL for POWER, and keep the
> > existing (different) behavior without the flag?
> >
> > Ram, would you be okay with that?  Could you give me a hand if
> > necessary?  (I assume we have silicon in-house because it's a
> > long-standing feature of the POWER platform which was simply dormant
> > on Linux until now.)

> Yes. I can help you with that.

> So let me see if I understand the overall idea.

> Application can allocate new keys through a new syscall
> sys_pkey_alloc_1(flags, init_val, sig_init_val)

> 'sig_init_val' is the permission-state of the key in signal context.

> The kernel will set the permission of each keys to their
> corresponding values when entering the signal handler and revert
> on return from the signal handler.

> just like init_val, sig_init_val also percolates to children threads.


I was imagining it would be just pkey_alloc(SOME_NEW_FLAG, init_val); and
the init val would be used for the current thread and for signal handlers.
New threads would inherit their parents' values.  The latter is certainly
up for negotiation, but it's the simplest behavior, and it's not obvious to
be that it's wrong.

--Andy
