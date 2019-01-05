Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C35048E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 16:54:25 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id x2so3799001lfg.16
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 13:54:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7-v6sor36327694ljk.19.2019.01.05.13.54.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 13:54:23 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com. [209.85.208.176])
        by smtp.gmail.com with ESMTPSA id q6sm11702689lfh.52.2019.01.05.13.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 13:54:20 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id v15-v6so35178110ljh.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 13:54:20 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm> <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 13:54:03 -0800
Message-ID: <CAHk-=wgrSKyN23yp-npq6+J-4pGqbzxb3mJ183PryjHw7PWDyA@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>, Masatake YAMATO <yamato@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Sat, Jan 5, 2019 at 12:43 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> > Who actually _uses_ mincore()? That's probably the best guide to what
> > we should do. Maybe they open the file read-only even if they are the
> > owner, and we really should look at file ownership instead.
>
> Yeah, well
>
>         https://codesearch.debian.net/search?q=mincore
>
> is a bit too much mess to get some idea quickly I am afraid.

Yeah, heh.

And the first hit is 'fincore', which probably nobody cares about
anyway, but it does

    fd = open (name, O_RDONLY)
    ..
    mmap(window, len, PROT_NONE, MAP_PRIVATE, ..

so if we want to keep that working, we'd really need to actually check
file ownership rather than just looking at f_mode.

But I don't know if anybody *uses* and cares about fincore, and it's
particularly questionable for non-root users.

And the Android go runtime code seems to oddly use mincore to figure
out page size:

  // try using mincore to detect the physical page size.
  // mincore should return EINVAL when address is not a multiple of
system page size.

which is all kinds of odd, but whatever.. Why mincore, rather than
something sane and obvious like mmap? Don't ask me...

Anyway, the Debian code search just results in mostly non-present
stuff. It's sad that google code search is no more. It was great for
exactly these kinds of questions.

The mono runtime seems to have some mono_pages_not_faulted() function,
but I don't know if people use it for file mappings, and I couldn't
find any interesting users of it.

I didn't find anything that seems to really care, but I gave up after
a few pages of really boring stuff.

                    Linus
