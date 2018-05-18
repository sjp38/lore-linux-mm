Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A06856B05DC
	for <linux-mm@kvack.org>; Fri, 18 May 2018 10:35:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 70-v6so3425129wmb.2
        for <linux-mm@kvack.org>; Fri, 18 May 2018 07:35:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u17-v6sor2177264wmu.24.2018.05.18.07.35.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 07:35:14 -0700 (PDT)
MIME-Version: 1.0
References: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com>
In-Reply-To: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 18 May 2018 07:35:01 -0700
Message-ID: <CALCETrXx_gUVQEvWjFNOBHqzVM+VSaMaRAX=11e7L=8BLHEagw@mail.gmail.com>
Subject: Re: pkeys on POWER: Default AMR, UAMOR values
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, linuxram@us.ibm.com, Dave Hansen <dave.hansen@intel.com>

On Fri, May 18, 2018 at 6:17 AM Florian Weimer <fweimer@redhat.com> wrote:

> I'm working on adding POWER pkeys support to glibc.  The coding work is
> done, but I'm faced with some test suite failures.

> Unlike the default x86 configuration, on POWER, existing threads have
> full access to newly allocated keys.

> Or, more precisely, in this scenario:

> * Thread A launches thread B
> * Thread B waits
> * Thread A allocations a protection key with pkey_alloc
> * Thread A applies the key to a page
> * Thread A signals thread B
> * Thread B starts to run and accesses the page

> Then at the end, the access will be granted.

> I hope it's not too late to change this to denied access.

> Furthermore, I think the UAMOR value is wrong as well because it
> prevents thread B at the end to set the AMR register.  In particular, if
> I do this

> * =E2=80=A6 (as before)
> * Thread A signals thread B
> * Thread B sets the access rights for the key to PKEY_DISABLE_ACCESS
> * Thread B reads the current access rights for the key

> then it still gets 0 (all access permitted) because the original UAMOR
> value inherited from thread A prior to the key allocation masks out the
> access right update for the newly allocated key.

This type of issue is why I think that a good protection key ISA would not
have a usermode read-the-whole-register or write-the-whole-register
operation at all.  It's still not clear to me that there is any good
kernel-mode solution.  But at least x86 defaults to deny-everything, which
is more annoying but considerably safer than POWER's behavior.

--Andy
