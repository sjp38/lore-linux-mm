Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB4B66B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 13:43:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id h24-v6so7029010ede.9
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:43:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19-v6sor3437874ejr.12.2018.11.13.10.43.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 10:43:00 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru>
 <20181113022516.45u6b536vtdjgvrf@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi744_8NA30V0aWCpFi_=WSaA+18h3njOTQG0SFUVdXi8bg@mail.gmail.com>
In-Reply-To: <CAGqmi744_8NA30V0aWCpFi_=WSaA+18h3njOTQG0SFUVdXi8bg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 13 Nov 2018 10:42:47 -0800
Message-ID: <CA+CK2bB0C-PCdaHS7YiLf5iZWn1bATg2y32ogL1FSw7LY9E7SQ@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org

> > Is it really necessary to have an extra thread in ksm just to add vma's
> > for scanning? Can we do it right from the scanner thread? Also, may be
> > it is better to add vma's at their creation time when KSM_MODE_ALWAYS is
> > enabled?
> >
> > Thank you,
> > Pasha
>
> Oh, thats a long story, and my english to bad for describe all things,
> even that hard to find linux-mm conversation several years ago about that.
>
> Anyway, so:
> In V2 - i use scanner thread to add VMA, but i think scanner do that
> with too high rate.
> i.e. walk on task list, and get new task every 20ms, to wait write semaphore,
> to get VMA...
> To high rate for task list scanner, i think it's overkill.
>
> About add VMA from creation time,
> UKSM add ksm_enter() hooks to mm subsystem, i port that to KSM.
> But some mm people say what they not like add KSM hooks to other subsystems.
> And want ksm do that internally by some way.
>
> Frankly speaking i didn't have enough knowledge and skills to do that
> another way in past time.
> They also suggest me look to THP for that logic, but i can't find how
> THP do that without hooks, and
> where THP truly scan memory.
>
> So, after all of that i implemented this in that way.
> In first iteration as part of ksm scan thread, and in second, by
> separate thread.
> Because that allow to add VMA in fully independent way.

It still feels as a wrong direction. A new thread that adds random
VMA's to scan, and no way to optimize the queue fairness for example.
It should really be done at creation time, when VMA is created it
should be added to KSM scanning queue, or KSM main scanner thread
should go through VMA list in a coherent order.

The design of having a separate thread is bad. I plan in the future to
add thread per node support to KSM, and this one odd thread won't
break things, to which queue should this thread add VMA if there are
multiple queues?

Thank you,
Pasha
