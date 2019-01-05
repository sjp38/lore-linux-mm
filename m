Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3053E8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:17:32 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id l12-v6so10617027ljb.11
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:17:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o26-v6sor34356856ljj.36.2019.01.05.12.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 12:17:30 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id c203sm11862130lfe.95.2019.01.05.12.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:17:28 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id v15-v6so35085615ljh.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:17:28 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com> <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 12:17:12 -0800
Message-ID: <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

[ Crossed emails ]

On Sat, Jan 5, 2019 at 12:12 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> I am still not completely sure what to return in such cases though; we can
> either blatantly lie and always pretend that the pages are resident

That's what my untested patch did. Or maybe just claim they are all
not present?

And again, that patch was entirely untested, so it may be garbage and
have some fundamental problem. I also don't know exactly what rule
might make most sense, but "you can write to the file" certainly to me
implies that you also could know what parts of it are in-core.

Who actually _uses_ mincore()? That's probably the best guide to what
we should do. Maybe they open the file read-only even if they are the
owner, and we really should look at file ownership instead.

I tried to make that "can_do_mincore()" function easy to understand
and easy to just modify to some sane state.

Again, my patch is meant as a "perhaps something like this?" rather
than some "this is _exactly_ how it must be done". Take the patch as a
quick suggestion, not some final answer.

              Linus
