Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA6C56B065A
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:40:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b83-v6so3783757wme.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:40:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d17-v6sor4208942wrd.34.2018.05.18.12.39.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 12:39:58 -0700 (PDT)
MIME-Version: 1.0
References: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com> <20180518174448.GE5479@ram.oc3035372033.ibm.com>
In-Reply-To: <20180518174448.GE5479@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 18 May 2018 12:39:46 -0700
Message-ID: <CALCETrV_wYPKHna8R2Bu19nsDqF2dJWarLLsyHxbcYD_AgYfPg@mail.gmail.com>
Subject: Re: pkeys on POWER: Default AMR, UAMOR values
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, May 18, 2018 at 10:45 AM Ram Pai <linuxram@us.ibm.com> wrote:

> On Fri, May 18, 2018 at 03:17:14PM +0200, Florian Weimer wrote:
> > I'm working on adding POWER pkeys support to glibc.  The coding work
> > is done, but I'm faced with some test suite failures.
> >
> > Unlike the default x86 configuration, on POWER, existing threads
> > have full access to newly allocated keys.
> >
> > Or, more precisely, in this scenario:
> >
> > * Thread A launches thread B
> > * Thread B waits
> > * Thread A allocations a protection key with pkey_alloc
> > * Thread A applies the key to a page
> > * Thread A signals thread B
> > * Thread B starts to run and accesses the page
> >
> > Then at the end, the access will be granted.
> >
> > I hope it's not too late to change this to denied access.
> >
> > Furthermore, I think the UAMOR value is wrong as well because it
> > prevents thread B at the end to set the AMR register.  In
> > particular, if I do this
> >
> > * =E2=80=A6 (as before)
> > * Thread A signals thread B
> > * Thread B sets the access rights for the key to PKEY_DISABLE_ACCESS
> > * Thread B reads the current access rights for the key
> >
> > then it still gets 0 (all access permitted) because the original
> > UAMOR value inherited from thread A prior to the key allocation
> > masks out the access right update for the newly allocated key.

> Florian, is the behavior on x86 any different? A key allocated in the
> context off one thread is not meaningful in the context of any other
> thread.


The difference is that x86 starts out with deny-all instead of allow-all.
The POWER semantics make it very hard for a multithreaded program to
meaningfully use protection keys to prevent accidental access to important
memory.
