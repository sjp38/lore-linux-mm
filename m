Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A492D6B0085
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 01:06:45 -0500 (EST)
Received: by iwn9 with SMTP id 9so4589927iwn.14
        for <linux-mm@kvack.org>; Sat, 06 Nov 2010 23:06:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101106151237.GM13830@dastard>
References: <20101105014334.GF13830@dastard> <E1PELiI-0001Pj-8g@approx.mit.edu>
 <AANLkTimON_GL6vRF9=_U6oRFQ30EYssx3wv5xdNsU9JM@mail.gmail.com> <20101106151237.GM13830@dastard>
From: dave b <db.pub.mail@gmail.com>
Date: Sun, 7 Nov 2010 17:06:22 +1100
Message-ID: <AANLkTikbcTwZ5ttafqQTQgJ4sxbcpOrDhAQgDURgoimL@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Sanjoy Mahajan <sanjoy@olin.edu>, Jesper Juhl <jj@chaosbits.net>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On 7 November 2010 02:12, Dave Chinner <david@fromorbit.com> wrote:
> On Sun, Nov 07, 2010 at 01:10:24AM +1100, dave b wrote:
>> I now personally have thought that this problem is the kernel not
>> keeping track of reads vs writers properly =C2=A0or not providing enough
>> time to reading processes as writing ones which look like they are
>> blocking the system....
>
> Could be anything from that description....
>
>> If you want to do a simple test do an unlimited dd =C2=A0(or two dd's of=
 a
>> limited size, say 10gb) and a find /
>> Tell me how it goes :)
>
> The find runs at IO latency speed while the dd processes run at disk
> bandwidth:
>
> Device: =C2=A0 =C2=A0 =C2=A0 =C2=A0 rrqm/s =C2=A0 wrqm/s =C2=A0 =C2=A0 r/=
s =C2=A0 =C2=A0 w/s =C2=A0 =C2=A0rMB/s =C2=A0 =C2=A0wMB/s avgrq-sz avgqu-sz=
 =C2=A0 await =C2=A0svctm =C2=A0%util
> vda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.=
00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A00.00 =C2=A0 0.00 =C2=
=A0 0.00
> vdb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0 58.00 1251.00 =C2=A0 =C2=A0 0.45 =C2=A0 556.54 =C2=A0 871.45 =C2=
=A0 =C2=A026.69 =C2=A0 20.39 =C2=A0 0.72 =C2=A094.32
> sda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.=
00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A00.00 =C2=A0 0.00 =C2=
=A0 0.00
>
> That looks pretty normal to me for XFS and the noop IO scheduler,
> and there are no signs of latency or interactive problems in
> the system at all. Kill the dd's and:
>
> Device: =C2=A0 =C2=A0 =C2=A0 =C2=A0 rrqm/s =C2=A0 wrqm/s =C2=A0 =C2=A0 r/=
s =C2=A0 =C2=A0 w/s =C2=A0 =C2=A0rMB/s =C2=A0 =C2=A0wMB/s avgrq-sz avgqu-sz=
 =C2=A0 await =C2=A0svctm =C2=A0%util
> vda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.=
00 0.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A00.00 =C2=A0 0.00 =C2=A0 0.00
> vdb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0214.80 =C2=A0 =C2=A00.40 =C2=A0 =C2=A0 1.68 =C2=A0 =C2=A0 0.00 15=
.99 =C2=A0 =C2=A0 0.33 =C2=A0 =C2=A01.54 =C2=A0 1.54 =C2=A033.12
> sda =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0=
.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A00.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A0 0.=
00 0.00 =C2=A0 =C2=A0 0.00 =C2=A0 =C2=A00.00 =C2=A0 0.00 =C2=A0 0.00
>
> And the find runs 3-4x faster, but ~200 iops is about the limit
> I'd expect from 7200rpm SATA drives given a single thread issuing IO
> (i.e. 5ms average seek time).
>
>> ( the system will stall)
>
> No, the system doesn't stall at all. It runs just fine. Sure,
> anything that requires IO on the loaded filesystem is _slower_, but
> if you're writing huge files to it that's pretty much expected. The
> root drive (on a different spindle) is still perfectly responsive on
> a cold cache:
>
> $ sudo time find / -xdev > /dev/null
> 0.10user 1.87system 0:03.39elapsed 58%CPU (0avgtext+0avgdata 7008maxresid=
ent)k
> 0inputs+0outputs (1major+844minor)pagefaults 0swap
>
> So what you describe is not a systemic problem, but a problem that
> your system configuration triggers. That's why we need to know
> _exactly_ how your storage subsystem is configured....
>
>> http://article.gmane.org/gmane.linux.kernel.device-mapper.dm-crypt/4561
>> iirc can reproduce this on plain ext3.
>
> You're pointing to a "fsync-tester" program that exercises a
> well-known problem with ext3 (sync-the-world-on-fsync). Other
> filesystems do not have that design flaw so don't suffer from
> interactivity problems uner these workloads. =C2=A0As it is, your above
> dd workload example is not related to this fsync problem, either.
>
> This is what I'm trying to point out - you need to describe in
> significant detail your setup and what your applications are doing
> so we can identify if you are seeing a known problem or not. If you
> are seeing problems as a result of the above ext3 fsync problem,
> then the simple answer is "don't use ext3".

Thank you for your reply.
Well I am not sure :)
Is the answer "don't use ext3" ?
If it is what should I really be using instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
