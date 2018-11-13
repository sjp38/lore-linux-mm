Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA35E6B0006
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 17:55:43 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id e10so9812759oth.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:55:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m62-v6sor4923417oif.52.2018.11.13.14.55.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 14:55:42 -0800 (PST)
Received: from mail-oi1-f180.google.com (mail-oi1-f180.google.com. [209.85.167.180])
        by smtp.gmail.com with ESMTPSA id q65-v6sm7019730oif.6.2018.11.13.14.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 14:55:40 -0800 (PST)
Received: by mail-oi1-f180.google.com with SMTP id c206so6375311oib.0
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:55:40 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru>
 <20181113022516.45u6b536vtdjgvrf@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi744_8NA30V0aWCpFi_=WSaA+18h3njOTQG0SFUVdXi8bg@mail.gmail.com> <CA+CK2bB0C-PCdaHS7YiLf5iZWn1bATg2y32ogL1FSw7LY9E7SQ@mail.gmail.com>
In-Reply-To: <CA+CK2bB0C-PCdaHS7YiLf5iZWn1bATg2y32ogL1FSw7LY9E7SQ@mail.gmail.com>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Wed, 14 Nov 2018 01:55:04 +0300
Message-ID: <CAGqmi74uqeqxD4n=pb=3v48sSfk-pQhk7eTHkuTLxegFAq-D9A@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 21:43, Pavel=
 Tatashin <pasha.tatashin@soleen.com>:
>
> > > Is it really necessary to have an extra thread in ksm just to add vma=
's
> > > for scanning? Can we do it right from the scanner thread? Also, may b=
e
> > > it is better to add vma's at their creation time when KSM_MODE_ALWAYS=
 is
> > > enabled?
> > >
> > > Thank you,
> > > Pasha
> >
> > Oh, thats a long story, and my english to bad for describe all things,
> > even that hard to find linux-mm conversation several years ago about th=
at.
> >
> > Anyway, so:
> > In V2 - i use scanner thread to add VMA, but i think scanner do that
> > with too high rate.
> > i.e. walk on task list, and get new task every 20ms, to wait write sema=
phore,
> > to get VMA...
> > To high rate for task list scanner, i think it's overkill.
> >
> > About add VMA from creation time,
> > UKSM add ksm_enter() hooks to mm subsystem, i port that to KSM.
> > But some mm people say what they not like add KSM hooks to other subsys=
tems.
> > And want ksm do that internally by some way.
> >
> > Frankly speaking i didn't have enough knowledge and skills to do that
> > another way in past time.
> > They also suggest me look to THP for that logic, but i can't find how
> > THP do that without hooks, and
> > where THP truly scan memory.
> >
> > So, after all of that i implemented this in that way.
> > In first iteration as part of ksm scan thread, and in second, by
> > separate thread.
> > Because that allow to add VMA in fully independent way.
>
> It still feels as a wrong direction. A new thread that adds random
> VMA's to scan, and no way to optimize the queue fairness for example.
> It should really be done at creation time, when VMA is created it
> should be added to KSM scanning queue, or KSM main scanner thread
> should go through VMA list in a coherent order.

How you see queue fairness in that case?
i.e. if you talk about moving from old VMA to new VMA,
IIRC i can't find any whole kernel list of VMAs.

i.e. i really understood what you don't like exactly,
but for that we need add hooks as i already mentioned above.
(And i already try get that to kernel [1]).

So, as i wrote you below, i need some maintainer opinion
in which way that responsible person of mm see 'right' implementation.

> The design of having a separate thread is bad. I plan in the future to
> add thread per node support to KSM, and this one odd thread won't
> break things, to which queue should this thread add VMA if there are
> multiple queues?

That will be interesting to look :)
But IMHO:
I think you will need to add some code to ksm_enter().
Because madvise() internally call ksm_enter().

So ksm_enter() will decide which tread must process that.
That not depends on caller.

Thanks.

> Thank you,
> Pasha
>
- - -
1. https://lkml.org/lkml/2014/11/8/206
