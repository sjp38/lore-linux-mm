Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id ED7108E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 17:12:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3-v6so4467914pgc.8
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 14:12:34 -0700 (PDT)
Received: from sonic309-21.consmr.mail.gq1.yahoo.com (sonic309-21.consmr.mail.gq1.yahoo.com. [98.137.65.147])
        by mx.google.com with ESMTPS id f9-v6si2631248plm.126.2018.09.27.14.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 14:12:33 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Alex Xu <alex_y_xu@yahoo.ca>
In-Reply-To: <CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
References: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
 <CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
Message-ID: <153808275043.724.15980761008814866300@pink.alxu.ca>
Subject: Re: [PATCH] mm: fix z3fold warnings on CONFIG_SMP=n
Date: Thu, 27 Sep 2018 21:12:30 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Quoting Dan Streetman (2018-09-27 20:41:21)
> On Thu, Sep 27, 2018 at 4:27 PM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wr=
ote:
> >
> > Spinlocks are always lockable on UP systems, even if they were just
> > locked.
> =

> i think it would be much better to just use either
> assert_spin_locked() or just spin_is_locked(), instead of an #ifdef.
> =


I wrote a longer response and then learned about the WARN_ON_SMP macro,
so I'll just use that instead.

Original response below:

I thought about using assert_spin_locked, but I wanted to keep the
existing behavior, and it seems to make sense to try to lock the page if
we forgot to lock it earlier? Maybe not though; I don't understand this
code completely. I did write a version of z3fold_page_ensure_locked with
"if (assert_spin_locked(...))" but not only did that look even worse, it
doesn't even work, because assert_spin_locked is a statement on UP
systems, not an expression. It might be worth adding a
ensure_spin_locked function that does that though...

spin_is_locked currently still always returns 0 "on CONFIG_SMP=3Dn builds
with CONFIG_DEBUG_SPINLOCK=3Dn", so that would just return us to the same
problem of checking CONFIG_SMP.
