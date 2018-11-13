Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 135916B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:35:15 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c7so32169606qkg.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:35:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r93sor11153602qkr.27.2018.11.13.10.35.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 10:35:13 -0800 (PST)
Date: Tue, 13 Nov 2018 18:35:10 +0000
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Message-ID: <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name>
 <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: oleksandr@natalenko.name, Jann Horn <jannh@google.com>, linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On 18-11-13 21:17:42, Timofey Titovets wrote:
> D2N?, 13 D 1/2 D 3/4 N?D+-. 2018 D3. D2 20:59, Pavel Tatashin <pasha.tatashin@soleen.com>:
> >
> > On 18-11-13 15:23:50, Oleksandr Natalenko wrote:
> > > Hi.
> > >
> > > > Yep. However, so far, it requires an application to explicitly opt in
> > > > to this behavior, so it's not all that bad. Your patch would remove
> > > > the requirement for application opt-in, which, in my opinion, makes
> > > > this way worse and reduces the number of applications for which this
> > > > is acceptable.
> > >
> > > The default is to maintain the old behaviour, so unless the explicit
> > > decision is made by the administrator, no extra risk is imposed.
> >
> > The new interface would be more tolerable if it honored MADV_UNMERGEABLE:
> >
> > KSM default on: merge everything except when MADV_UNMERGEABLE is
> > excplicitly set.
> >
> > KSM default off: merge only when MADV_MERGEABLE is set.
> >
> > The proposed change won't honor MADV_UNMERGEABLE, meaning that
> > application programmers won't have a way to prevent sensitive data to be
> > every merged. So, I think, we should keep allow an explicit opt-out
> > option for applications.
> >
> 
> We just did not have VM/Madvise flag for that currently.
> Same as THP.
> Because all logic written with assumption, what we have exactly 2 states.
> Allow/Disallow (More like not allow).
> 
> And if we try to add, that must be something like:
> MADV_FORBID_* to disallow something completely.

No need to add new user flag MADV_FORBID, we should keep MADV_MERGEABLE
and MADV_UNMERGEABLE, but make them work so when MADV_UNMERGEABLE is
set, memory is indeed becomes always unmergeable regardless of ksm mode
of operation.

To do the above in ksm_madvise(), a new state should be added, for example
instead of: 

case MADV_UNMERGEABLE:
	*vm_flags &= ~VM_MERGEABLE;

A new flag should be used:
	*vm_flags |= VM_UNMERGEABLE;

I think, without honoring MADV_UNMERGEABLE correctly, this patch won't
be accepted.

Pasha
