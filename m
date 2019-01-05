Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE9E38E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:06:03 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id e12-v6so10576069ljb.18
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:06:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor34321028lja.17.2019.01.05.15.06.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:06:02 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id a18-v6sm12899008ljk.86.2019.01.05.15.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:06:00 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id c16so27731756lfj.8
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:05:59 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
In-Reply-To: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:05:43 -0800
Message-ID: <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sat, Jan 5, 2019 at 2:55 PM Jann Horn <jannh@google.com> wrote:
>
> Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
> handler) is less problematic because it only returns data about the
> state of page tables, and doesn't query the address_space? In other
> words, it permits monitoring evictions, but non-intrusively detecting
> that something has been loaded into memory by another process is
> harder?

Yes. I think it was brought up during the original report, but to use
the pagemap for this, you'd basically need to first populate all the
pages, and then wait for pageout.

So pagemap *does* leak very similar data, but it's much harder to use
as an attack vector.

That said, I think "mincore()" is just the simple one. You *can* (and
this was also discussed on the security list) do things like

 - fault in a single page

 - the kernel will opportunistically fault in pages that it already
has available _around_ that page.

 - then use pagemap (or just _timing_ - no real kernel support needed)
to see if those pages are now mapped in your address space

so honestly, mincore is just the "big hammer" and easy way to get at
some of this data. But it's probably worth closing exactly because
it's easy. There are other ways to get at the "are these pages mapped"
information, but they are a lot more combersome to use.

Side note: maybe we could just remove the "__mincore_unmapped_range()"
thing entirely, and basically make mincore() do what pagemap does,
which is to say "are the pages mapped in this VM".

That would be nicer than my patch, simply because removing code is
always nice. And arguably it's a better semantic anyway.

                Linus
