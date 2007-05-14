Received: by mu-out-0910.google.com with SMTP id w1so888429mue
        for <linux-mm@kvack.org>; Mon, 14 May 2007 01:50:49 -0700 (PDT)
Date: Mon, 14 May 2007 10:50:45 +0200 (CEST)
From: Esben Nielsen <nielsen.esben@googlemail.com>
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
In-Reply-To: <4645DCA2.80408@cosmosbay.com>
Message-ID: <Pine.LNX.4.64.0705141040050.20796@frodo.shire>
References: <20070511131541.992688403@chello.nl>  <Pine.LNX.4.64.0705121120210.26287@frodo.shire>
 <1178964103.6810.55.camel@twins> <Pine.LNX.4.64.0705121520210.2101@frodo.shire>
 <4645DCA2.80408@cosmosbay.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-22478338-1517368955-1179132645=:20796"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Esben Nielsen <nielsen.esben@googlemail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

---22478338-1517368955-1179132645=:20796
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 12 May 2007, Eric Dumazet wrote:

> Esben Nielsen a =E9crit :
>>
>>
>>  On Sat, 12 May 2007, Peter Zijlstra wrote:
>>=20
>> >  On Sat, 2007-05-12 at 11:27 +0200, Esben Nielsen wrote:
>> > >=20
>> > >  On Fri, 11 May 2007, Peter Zijlstra wrote:
>> > >=20
>> > > >=20
>> > > >  I was toying with a scalable rw_mutex and found that it gives ~10=
%=20
>> > > >  reduction in
>> > > >  system time on ebizzy runs (without the MADV_FREE patch).
>> > > >=20
>> > >=20
>> > >  You break priority enheritance on user space futexes! :-(
>> > >  The problems is that the futex waiter have to take the mmap_sem. An=
d=20
>> > >  as
>> > >  your rw_mutex isn't PI enabled you get priority inversions :-(
>> >=20
>> >  Do note that rwsems have no PI either.
>> >  PI is not a concern for mainline - yet, I do have ideas here though.
>> >=20
>> >
>>  If PI wasn't a concern for mainline, why is PI futexes merged into the
>>  mainline?
>
> If you really care about futexes and mmap_sem, just use private futexes,=
=20
> since they dont use mmap_sem at all.
>

futex_wait_pi() takes mmap_sem. So does futex_fd(). I can't see a code=20
path into the PI futexes which doesn't use mmap_sem.

There is another way to avoid problems with mmap_sem:
Use shared memory for data you need to share with high priority tasks and
normal low priority tasks there. The high priority task(s) run(s) in=20
an isolated high priority process having its own mmap_sem. This high=20
priority process is mlock'ed and doesn't do any operations write locking=20
mmap_sem.

But it would be nice if you can avoid such a cumbersome workaround...

Esben
---22478338-1517368955-1179132645=:20796--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
