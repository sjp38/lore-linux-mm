Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3105A6B0010
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:54:54 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id s53so9230154ota.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:54:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7-v6sor9399736oia.24.2018.11.13.10.54.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 10:54:52 -0800 (PST)
Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com. [209.85.210.54])
        by smtp.gmail.com with ESMTPSA id o15sm5965942otb.3.2018.11.13.10.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 10:54:51 -0800 (PST)
Received: by mail-ot1-f54.google.com with SMTP id g27so12341660oth.6
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:54:50 -0800 (PST)
MIME-Version: 1.0
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name> <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com> <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 21:54:13 +0300
Message-ID: <CAGqmi763e4sZj1NHAk2fAjtPtb-kAZfcPq=KTH8B3sE-oDVvGw@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>, Jann Horn <jannh@google.com>, linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 21:35, Pavel=
 Tatashin <pasha.tatashin@soleen.com>:
>
> On 18-11-13 21:17:42, Timofey Titovets wrote:
> > =D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 20:59, P=
avel Tatashin <pasha.tatashin@soleen.com>:
> > >
> > > On 18-11-13 15:23:50, Oleksandr Natalenko wrote:
> > > > Hi.
> > > >
> > > > > Yep. However, so far, it requires an application to explicitly op=
t in
> > > > > to this behavior, so it's not all that bad. Your patch would remo=
ve
> > > > > the requirement for application opt-in, which, in my opinion, mak=
es
> > > > > this way worse and reduces the number of applications for which t=
his
> > > > > is acceptable.
> > > >
> > > > The default is to maintain the old behaviour, so unless the explici=
t
> > > > decision is made by the administrator, no extra risk is imposed.
> > >
> > > The new interface would be more tolerable if it honored MADV_UNMERGEA=
BLE:
> > >
> > > KSM default on: merge everything except when MADV_UNMERGEABLE is
> > > excplicitly set.
> > >
> > > KSM default off: merge only when MADV_MERGEABLE is set.
> > >
> > > The proposed change won't honor MADV_UNMERGEABLE, meaning that
> > > application programmers won't have a way to prevent sensitive data to=
 be
> > > every merged. So, I think, we should keep allow an explicit opt-out
> > > option for applications.
> > >
> >
> > We just did not have VM/Madvise flag for that currently.
> > Same as THP.
> > Because all logic written with assumption, what we have exactly 2 state=
s.
> > Allow/Disallow (More like not allow).
> >
> > And if we try to add, that must be something like:
> > MADV_FORBID_* to disallow something completely.
>
> No need to add new user flag MADV_FORBID, we should keep MADV_MERGEABLE
> and MADV_UNMERGEABLE, but make them work so when MADV_UNMERGEABLE is
> set, memory is indeed becomes always unmergeable regardless of ksm mode
> of operation.
>
> To do the above in ksm_madvise(), a new state should be added, for exampl=
e
> instead of:
>
> case MADV_UNMERGEABLE:
>         *vm_flags &=3D ~VM_MERGEABLE;
>
> A new flag should be used:
>         *vm_flags |=3D VM_UNMERGEABLE;
>
> I think, without honoring MADV_UNMERGEABLE correctly, this patch won't
> be accepted.
>
> Pasha
>

That must work, but we out of bit space in vm_flags [1].
i.e. first 32 bits already defined, and other only accessible only on
64-bit machines.

1. https://elixir.bootlin.com/linux/latest/source/include/linux/mm.h#L219
