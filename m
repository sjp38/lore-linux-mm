Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA416B000A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:57:31 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id s3so8608388otb.0
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:57:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j84-v6sor10040906oia.19.2018.11.13.03.57.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 03:57:30 -0800 (PST)
Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com. [209.85.167.174])
        by smtp.gmail.com with ESMTPSA id v41sm9326587otf.19.2018.11.13.03.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 03:57:28 -0800 (PST)
Received: by mail-oi1-f174.google.com with SMTP id u130-v6so10030194oie.7
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:57:28 -0800 (PST)
MIME-Version: 1.0
References: <b4c41073d763dc5798562233de8eaa6d@natalenko.name>
In-Reply-To: <b4c41073d763dc5798562233de8eaa6d@natalenko.name>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 14:56:51 +0300
Message-ID: <CAGqmi742UNjRLTT-XuKFBfQc14mjHJPNQ6bbpRojniz6-At9Rg@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleksandr@natalenko.name
Cc: linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 14:06, Oleks=
andr Natalenko <oleksandr@natalenko.name>:
>
> Hi.
>
> > ksm by default working only on memory that added by
> > madvise().
> >
> > And only way get that work on other applications:
> >   * Use LD_PRELOAD and libraries
> >   * Patch kernel
> >
> > Lets use kernel task list and add logic to import VMAs from tasks.
> >
> > That behaviour controlled by new attributes:
> >   * mode:
> >     I try mimic hugepages attribute, so mode have two states:
> >       * madvise      - old default behaviour
> >       * always [new] - allow ksm to get tasks vma and
> >                        try working on that.
> >   * seeker_sleep_millisecs:
> >     Add pauses between imports tasks VMA
> >
> > For rate limiting proporses and tasklist locking time,
> > ksm seeker thread only import VMAs from one task per loop.
> >
> > Some numbers from different not madvised workloads.
> > Formulas:
> >   Percentage ratio =3D (pages_sharing - pages_shared)/pages_unshared
> >   Memory saved =3D (pages_sharing - pages_shared)*4/1024 MiB
> >   Memory used =3D free -h
> >
> >   * Name: My working laptop
> >     Description: Many different chrome/electron apps + KDE
> >     Ratio: 5%
> >     Saved: ~100  MiB
> >     Used:  ~2000 MiB
> >
> >   * Name: K8s test VM
> >     Description: Some small random running docker images
> >     Ratio: 40%
> >     Saved: ~160 MiB
> >     Used:  ~920 MiB
> >
> >   * Name: Ceph test VM
> >     Description: Ceph Mon/OSD, some containers
> >     Ratio: 20%
> >     Saved: ~60 MiB
> >     Used:  ~600 MiB
> >
> >   * Name: BareMetal K8s backend server
> >     Description: Different server apps in containers C, Java, GO & etc
> >     Ratio: 72%
> >     Saved: ~5800 MiB
> >     Used:  ~35.7 GiB
> >
> >   * Name: BareMetal K8s processing server
> >     Description: Many instance of one CPU intensive application
> >     Ratio: 55%
> >     Saved: ~2600 MiB
> >     Used:  ~28.0 GiB
> >
> >   * Name: BareMetal Ceph node
> >     Description: Only OSD storage daemons running
> >     Raio: 2%
> >     Saved: ~190 MiB
> >     Used:  ~11.7 GiB
>
> Out of curiosity, have you compared these results with UKSM [1]?
>
> Thanks.
>
> --
>    Oleksandr Natalenko (post-factum)
>
> [1] https://github.com/dolohow/uksm

Long story short:
I try get UKSM code in kernel, and i mostly know how UKSM works.
Yep, UKSM implement logic in different way, but UKSM _always_ will have
same or worse numbers (saved pages) in compare to KSM.

Why?

Both scan VMA pages and filter VMA by some flags (same set of flags).
So they both will see same subset of pages, which can be deduped.
But UKSM also try not dedup VMA pages, if some of VMA pages changes
more frequently - trashing.
Because of that UKSM will skip some pages, but KSM will try dedup all
pages, not changed between scans.

I skip UKSM internal logic, which can work better of course in
resource usage terms
(different hash implementation, different page tree),
but that doesn't matter in that case (if we talk about saved memory).

Only thing what UKSM have, which KSM can't do:
UKSM can add VMA memory it self, by hooks in mm.

KSM currently need help by madvise() for that.
That the reason, why i write that patchset for KSM.
(I also wrote some info to Pavel Tatashin in above mail)

Thanks!
