Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD7948E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:32:23 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id g3so4248769wrm.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:32:23 -0800 (PST)
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id j27si46327219wre.73.2019.01.10.23.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 23:32:22 -0800 (PST)
Date: Fri, 11 Jan 2019 08:32:06 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111073206.GA1303@nautica>
References: <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111045750.GA27333@nautica>
 <CAHk-=wiqfAdmmE+pR3O5zs=xtkd6A6ShyyCwpwSZ+341L=zVYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=wiqfAdmmE+pR3O5zs=xtkd6A6ShyyCwpwSZ+341L=zVYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

Linus Torvalds wrote on Thu, Jan 10, 2019:
> But those numbers aren't about the mincore() change. That's just from
> dropping caches.
> 
> Now, what's the difference with the mincore change, and without? Is it
> actually measurable?
> 
> Because that's all that matters: is the mincore change something you
> can even notice? Is it a big regression?
> 
> The fact that things are slower when they are cold in the cache isn't
> the issue. The issue is whether the change to mincore semantics makes
> any difference to real loads.

mincore itself isn't used to reload the data, but is necessary to know
*what* you need to reload.
If you don't know what pages are hot, how can you preload them?

For small enough a database and with enough memory you can act stupid
and load the whole tables in cache, that's what I did because I was lazy
and only had a big mysql data set around. But the container warming up
automaton Dave mentioned and postgresql db preloading with pgfincore
explicitely depend on being able to tell what they need to preload.


pgfincore documentation states:
----
set of PostgreSQL functions to manage blocks in memory

Those functions let you know which and how many disk block from a
relation are in the page cache of the operating system, and eventually
write the result to a file. Then using this file, it is possible to
restore the page cache state for each block of the relation.
----
If you cannot dump an arbitrary "hot state" x, you cannot restore it.


This is all basically a repeat of the other subthread; sure precaching
itself doesn't need mincore and if you're all-knowing the syscall isn't
needed, but mere mortals need it.


If it's about the commit itself, vmtouch tells me 0 page in these
database files are in cache when I reboot to a 5.0-rc1 kernel and run
some queries, so the difference after a fresh boot is exactly what I
stated. I'm probably missing something but I'm not quite sure in what
situation the "new mincore" has any use right now.
-- 
Dominique Martinet | Asmadeus
