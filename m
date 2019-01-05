Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8BB28E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:28:39 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id t22-v6so10816122lji.14
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:28:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66-v6sor35490602ljb.20.2019.01.05.15.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:28:38 -0800 (PST)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com. [209.85.208.172])
        by smtp.gmail.com with ESMTPSA id n8-v6sm14216334lji.90.2019.01.05.15.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:28:36 -0800 (PST)
Received: by mail-lj1-f172.google.com with SMTP id n18-v6so35264490lji.7
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:28:35 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com> <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
In-Reply-To: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:28:19 -0800
Message-ID: <CAHk-=wie+SA1WCQ5nTKgvWyBUdTGxHjAOaoms-=Xu7-wC4j=Ag@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Sat, Jan 5, 2019 at 3:16 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> It goes back to forever, it looks like. I can't find a reason.

Our man-pages talk abouit the "without doing IO" part. That may be the
result of our code, though, not the reason for it.

The BSD man-page has other flags, but doesn't describe what "in core"
really means:

     MINCORE_INCORE        Page is in core (resident).

     MINCORE_REFERENCED        Page has been referenced by us.

     MINCORE_MODIFIED        Page has been modified by us.

     MINCORE_REFERENCED_OTHER  Page has been referenced.

     MINCORE_MODIFIED_OTHER    Page has been modified.

     MINCORE_SUPER        Page is part of a large (``super'') page.

but the fact that it has MINCORE_MODIFIED_OTHER does obviously imply
that yes, historically it really did look up the pages elsewhere, not
just in the page tables.

Still, maybe we can get away with just making it be about our own page
tables. That would be lovely.

                 Linus
