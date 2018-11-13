Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12F8D6B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:26:07 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id k76so674465oih.13
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:26:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t197-v6sor10244996oih.125.2018.11.13.05.26.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 05:26:06 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru>
 <CAG48ez0VRmRQckOjQhOeaf6bLYkfi45ksdnzuCKPwBYTM+As1g@mail.gmail.com> <CAGqmi75MShkwHTiSLPiOoQuYORmYTBJVqMKXm7pKhoNg9PT3yw@mail.gmail.com>
In-Reply-To: <CAGqmi75MShkwHTiSLPiOoQuYORmYTBJVqMKXm7pKhoNg9PT3yw@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Tue, 13 Nov 2018 14:25:38 +0100
Message-ID: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: timofey.titovets@synesis.ru
Cc: kernel list <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>, linux-doc@vger.kernel.org

On Tue, Nov 13, 2018 at 1:59 PM Timofey Titovets
<timofey.titovets@synesis.ru> wrote:
>
> =D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 14:57, Jan=
n Horn <jannh@google.com>:
> >
> > On Tue, Nov 13, 2018 at 12:40 PM Timofey Titovets
> > <timofey.titovets@synesis.ru> wrote:
> > > ksm by default working only on memory that added by
> > > madvise().
> > >
> > > And only way get that work on other applications:
> > >   * Use LD_PRELOAD and libraries
> > >   * Patch kernel
> > >
> > > Lets use kernel task list and add logic to import VMAs from tasks.
> > >
> > > That behaviour controlled by new attributes:
> > >   * mode:
> > >     I try mimic hugepages attribute, so mode have two states:
> > >       * madvise      - old default behaviour
> > >       * always [new] - allow ksm to get tasks vma and
> > >                        try working on that.
> >
> > Please don't. And if you really have to for some reason, put some big
> > warnings on this, advising people that it's a security risk.
> >
> > KSM is one of the favorite punching bags of side-channel and hardware
> > security researchers:
> >
> > As a gigantic, problematic side channel:
> > http://staff.aist.go.jp/k.suzaki/EuroSec2011-suzaki.pdf
> > https://www.usenix.org/system/files/conference/woot15/woot15-paper-barr=
esi.pdf
> > https://access.redhat.com/blogs/766093/posts/1976303
> > https://gruss.cc/files/dedup.pdf
> >
> > In particular https://gruss.cc/files/dedup.pdf ("Practical Memory
> > Deduplication Attacks in Sandboxed JavaScript") shows that KSM makes
> > it possible to use malicious JavaScript to determine whether a given
> > page of memory exists elsewhere on your system.
> >
> > And also as a way to target rowhammer-based faults:
> > https://www.usenix.org/system/files/conference/usenixsecurity16/sec16_p=
aper_razavi.pdf
> > https://thisissecurity.stormshield.com/2017/10/19/attacking-co-hosted-v=
m-hacker-hammer-two-memory-modules/
>
> I'm very sorry, i'm not a security specialist.
> But if i understood correctly, ksm have that security issues _without_
> my patch set.

Yep. However, so far, it requires an application to explicitly opt in
to this behavior, so it's not all that bad. Your patch would remove
the requirement for application opt-in, which, in my opinion, makes
this way worse and reduces the number of applications for which this
is acceptable.

> Even more, not only KSM have that type of issue, any memory
> deduplication have that problems.

Yup.

> Any guy who care about security must decide on it self. Which things
> him use and how he will
> defend from others.

> Even more on it self he must learn tools, what he use and make some
> decision right?
>
> So, if you really care about that problem in general, or only on KSM side=
,
> that your initiative and your duty to warn people about that.
>
> KSM already exists for 10+ years. You know about security implication
> of use memory deduplication.
> That your duty to send a patches to documentation, and add appropriate wa=
rnings.

As far as I know, basically nobody is using KSM at this point. There
are blog posts from several cloud providers about these security risks
that explicitly state that they're not using memory deduplication.
