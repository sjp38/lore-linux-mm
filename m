Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 131606B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 11:20:47 -0500 (EST)
Received: by pzk27 with SMTP id 27so2231895pzk.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 08:20:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 14 Nov 2009 01:20:45 +0900
Message-ID: <28c262360911130820r34d2d2d2jf2ca754447eb9f5@mail.gmail.com>
Subject: Re: [RFC MM] speculative page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 4:35 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This is just a toy patch inspied by on Christoph's mmap_sem works.
> Only for my hobby, now.
>
> Not well tested. So please look into only if you have time.
>
> My multi-thread page fault test program shows some improvement.
> But I doubt my test ;) Do you have recommended benchmarks for parallel pa=
ge-faults ?
>
> Counting # of page faults per 60sec. See page-faults. bigger is better.
> Test on x86-64 8cpus.
>
> [Before]
> =A0474441.541914 =A0task-clock-msecs =A0 =A0 =A0 =A0 # =A0 =A0 =A07.906 C=
PUs
> =A0 =A0 =A0 =A0 =A010318 =A0context-switches =A0 =A0 =A0 =A0 # =A0 =A0 =
=A00.000 M/sec
> =A0 =A0 =A0 =A0 =A0 =A0 10 =A0CPU-migrations =A0 =A0 =A0 =A0 =A0 # =A0 =
=A0 =A00.000 M/sec
> =A0 =A0 =A0 15816787 =A0page-faults =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0 =
=A00.033 M/sec
> =A01485219138381 =A0cycles =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0 3130=
.458 M/sec =A0(scaled from 69.99%)
> =A0 295669524399 =A0instructions =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A0 =A00.1=
99 IPC =A0 =A0(scaled from 79.98%)
> =A0 =A057658291915 =A0branches =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A01=
21.529 M/sec =A0(scaled from 79.98%)
> =A0 =A0 =A0798567455 =A0branch-misses =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0 =
=A01.385 % =A0 =A0 =A0(scaled from 79.98%)
> =A0 =A0 2458780947 =A0cache-references =A0 =A0 =A0 =A0 # =A0 =A0 =A05.182=
 M/sec =A0(scaled from 20.02%)
> =A0 =A0 =A0844605496 =A0cache-misses =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A0 =
=A01.780 M/sec =A0(scaled from 20.02%)
>
> [After]
> 471166.582784 =A0task-clock-msecs =A0 =A0 =A0 =A0 # =A0 =A0 =A07.852 CPUs
> =A0 =A0 =A0 =A0 =A010378 =A0context-switches =A0 =A0 =A0 =A0 # =A0 =A0 =
=A00.000 M/sec
> =A0 =A0 =A0 =A0 =A0 =A0 10 =A0CPU-migrations =A0 =A0 =A0 =A0 =A0 # =A0 =
=A0 =A00.000 M/sec
> =A0 =A0 =A0 37950235 =A0page-faults =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0 =
=A00.081 M/sec
> =A01463000664470 =A0cycles =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0 3105=
.060 M/sec =A0(scaled from 70.32%)
> =A0 346531590054 =A0instructions =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A0 =A00.2=
37 IPC =A0 =A0(scaled from 80.20%)
> =A0 =A063309364882 =A0branches =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A01=
34.367 M/sec =A0(scaled from 80.19%)
> =A0 =A0 =A0448256258 =A0branch-misses =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0 =
=A00.708 % =A0 =A0 =A0(scaled from 80.20%)
> =A0 =A0 2601112130 =A0cache-references =A0 =A0 =A0 =A0 # =A0 =A0 =A05.521=
 M/sec =A0(scaled from 19.81%)
> =A0 =A0 =A0872978619 =A0cache-misses =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A0 =
=A01.853 M/sec =A0(scaled from 19.80%)
>

Looks amazing. page fault is the two times faster than old.
What's your test program?

I think per thread vma cache is effective as well as speculative lock.

> Main concept of this patch is
> =A0- Do page fault without taking mm->mmap_sem until some modification in=
 vma happens.
> =A0- All page fault via get_user_pages() should have to take mmap_sem.
> =A0- find_vma()/rb_tree must be walked under proper locks. For avoiding t=
hat, use
> =A0 per-thread cache.
>
> It seems I don't have enough time to update this, more.
> So, I dump patches here just for share.

I think this is good embedded device as well as big thread environment
like google.
Some embedded device has big threads. That's because design issue of
migration from RTOS
to Linux. Thread model makes system design easier since threads share
address space like RTOS.
I know it's bad design. but At a loss, it's real problem.

I support this idea.
Thanks, Kame.


> Thanks,
> -Kame
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
