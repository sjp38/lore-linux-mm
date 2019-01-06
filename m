Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98FAF8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 19:23:07 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id t22-v6so10826700lji.14
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 16:23:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor36579053lje.28.2019.01.05.16.23.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 16:23:05 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id r203sm7769221lff.13.2019.01.05.16.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 16:23:03 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id y11so27781068lfj.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 16:23:03 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com> <20190106001138.GW6310@bombadil.infradead.org>
In-Reply-To: <20190106001138.GW6310@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 16:22:47 -0800
Message-ID: <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sat, Jan 5, 2019 at 4:11 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> FreeBSD claims to have a manpage from SunOS 4.1.3 with mincore (!)
>
> https://www.freebsd.org/cgi/man.cgi?query=mincore&apropos=0&sektion=0&manpath=SunOS+4.1.3&arch=default&format=html
>
> DESCRIPTION
>        mincore()  returns  the primary memory residency status of pages in the
>        address space covered by mappings in the range [addr, addr + len).

It's still not clear that "primary memory residency status" actually means.

Does it mean "mapped", or does it mean "exists in caches and doesn't need IO".

I don't even know what kind of caches SunOS 4.1.3 had. The Linux
implementation depends on the page cache, and wouldn't work (at least
not very well) in a system that has a traditional disk buffer cache.

Anyway, I guess it's mostly moot. From a "does this cause regressions"
standpoint, the only thing that matters is really whatever Linux
programs that have used this since it was introduced 18+ years ago.

But I think my patch to just rip out all that page lookup, and just
base it on the page table state has the fundamental advantage that it
gets rid of code. Maybe I should jst commit it, and see if anything
breaks? We do have options in case things break, and then we'd at
least know who cares (and perhaps a lot more information of _why_ they
care).

                     Linus
