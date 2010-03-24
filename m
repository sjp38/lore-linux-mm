Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 167EA6B01DF
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:56:39 -0400 (EDT)
Received: by wwb39 with SMTP id 39so2460096wwb.14
        for <linux-mm@kvack.org>; Wed, 24 Mar 2010 05:56:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100324114804.GF21147@csn.ul.ie>
References: <20100315130935.f8b0a2d7.akpm@linux-foundation.org>
	 <20100322235053.GD9590@csn.ul.ie>
	 <4e5e476b1003231435i47e5d95fg9d7eac0d14d3e26b@mail.gmail.com>
	 <20100324114804.GF21147@csn.ul.ie>
Date: Wed, 24 Mar 2010 13:56:35 +0100
Message-ID: <4e5e476b1003240556q86e7538s6117ac59ae57b18d@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone
	pressure
From: Corrado Zoccolo <czoccolo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 12:48 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Tue, Mar 23, 2010 at 10:35:20PM +0100, Corrado Zoccolo wrote:
>> Hi Mel,
>> On Tue, Mar 23, 2010 at 12:50 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On Mon, Mar 15, 2010 at 01:09:35PM -0700, Andrew Morton wrote:
>> >> On Mon, 15 Mar 2010 13:34:50 +0100
>> >> Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com> wrote:
>> >>
>> >> > c) If direct reclaim did reasonable progress in try_to_free but did=
 not
>> >> > get a page, AND there is no write in flight at all then let it try =
again
>> >> > to free up something.
>> >> > This could be extended by some kind of max retry to avoid some weir=
d
>> >> > looping cases as well.
>> >> >
>> >> > d) Another way might be as easy as letting congestion_wait return
>> >> > immediately if there are no outstanding writes - this would keep th=
e
>> >> > behavior for cases with write and avoid the "running always in full
>> >> > timeout" issue without writes.
>> >>
>> >> They're pretty much equivalent and would work. =C2=A0But there are tw=
o
>> >> things I still don't understand:
>> >>
>> >> 1: Why is direct reclaim calling congestion_wait() at all? =C2=A0If n=
o
>> >> writes are going on there's lots of clean pagecache around so reclaim
>> >> should trivially succeed. =C2=A0What's preventing it from doing so?
>> >>
>> >> 2: This is, I think, new behaviour. =C2=A0A regression. =C2=A0What ca=
used it?
>> >>
>> >
>> > 120+ kernels and a lot of hurt later;
>> >
>> > Short summary - The number of times kswapd and the page allocator have=
 been
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0calling congestion_wait and the length of t=
ime it spends in there
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0has been increasing since 2.6.29. Oddly, it=
 has little to do
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0with the page allocator itself.
>> >
>> > Test scenario
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > X86-64 machine 1 socket 4 cores
>> > 4 consumer-grade disks connected as RAID-0 - software raid. RAID contr=
oller
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0on-board and a piece of crap, and a decent =
RAID card could blow
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0the budget.
>> > Booted mem=3D256 to ensure it is fully IO-bound and match closer to wh=
at
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Christian was doing
>> >
>> > At each test, the disks are partitioned, the raid arrays created and a=
n
>> > ext2 filesystem created. iozone sequential read/write tests are run wi=
th
>> > increasing number of processes up to 64. Each test creates 8G of files=
. i.e.
>> > 1 process =3D 8G. 2 processes =3D 2x4G etc
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0iozone -s 8388608 -t 1 -r 64 -i 0 -i 1
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0iozone -s 4194304 -t 2 -r 64 -i 0 -i 1
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0etc.
>> >
>> > Metrics
>> > =3D=3D=3D=3D=3D=3D=3D
>> >
>> > Each kernel was instrumented to collected the following stats
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pg-Stall =C2=A0 =C2=A0 =C2=A0 =C2=A0Page al=
locator stalled calling congestion_wait
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pg-Wait =C2=A0 =C2=A0 =C2=A0 =C2=A0 The amo=
unt of time spent in congestion_wait
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pg-Rclm =C2=A0 =C2=A0 =C2=A0 =C2=A0 Pages r=
eclaimed by direct reclaim
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ksd-stall =C2=A0 =C2=A0 =C2=A0 balance_pgda=
t() (ie kswapd) staled on congestion_wait
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ksd-wait =C2=A0 =C2=A0 =C2=A0 =C2=A0Time sp=
end by balance_pgdat in congestion_wait
>> >
>> > Large differences in this do not necessarily show up in iozone because=
 the
>> > disks are so slow that the stalls are a tiny percentage overall. Howev=
er, in
>> > the event that there are many disks, it might be a greater problem. I =
believe
>> > Christian is hitting a corner case where small delays trigger a much l=
arger
>> > stall.
>> >
>> > Why The Increases
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >
>> > The big problem here is that there was no one change. Instead, it has =
been
>> > a steady build-up of a number of problems. The ones I identified are i=
n the
>> > block IO, CFQ IO scheduler, tty and page reclaim. Some of these are fi=
xed
>> > but need backporting and others I expect are a major surprise. Whether=
 they
>> > are worth backporting or not heavily depends on whether Christian's pr=
oblem
>> > is resolved.
>> >
>> > Some of the "fixes" below are obviously not fixes at all. Gathering th=
is data
>> > took a significant amount of time. It'd be nice if people more familia=
r with
>> > the relevant problem patches could spring a theory or patch.
>> >
>> > The Problems
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >
>> > 1. Block layer congestion queue async/sync difficulty
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fix title: asyncconfusion
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fixed in mainline? yes, in 2.6.31
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0affects: 2.6.30
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A02.6.30 replaced congestion queues based on =
read/write with sync/async
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0in commit 1faa16d2. Problems were identifie=
d with this and fixed in
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A02.6.31 but not backported. Backporting 8aa7=
e847 and 373c0a7e brings
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A02.6.30 in line with 2.6.29 performance. It'=
s not an issue for 2.6.31.
>> >
>> > 2. TTY using high order allocations more frequently
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fix title: ttyfix
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fixed in mainline? yes, in 2.6.34-rc2
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0affects: 2.6.31 to 2.6.34-rc1
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A02.6.31 made pty's use the same buffering lo=
gic as tty. =C2=A0Unfortunately,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0it was also allowed to make high-order GFP_=
ATOMIC allocations. This
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0triggers some high-order reclaim and introd=
uces some stalls. It's
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fixed in 2.6.34-rc2 but needs back-porting.
>> >
>> > 3. Page reclaim evict-once logic from 56e49d21 hurts really badly
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fix title: revertevict
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fixed in mainline? no
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0affects: 2.6.31 to now
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0For reasons that are not immediately obviou=
s, the evict-once patches
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0*really* hurt the time spent on congestion =
and the number of pages
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaimed. Rik, I'm afaid I'm punting this =
to you for explanation
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0because clearly you tested this for AIM7 an=
d might have some
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0theories. For the purposes of testing, I ju=
st reverted the changes.
>> >
>> > 4. CFQ scheduler fairness commit 718eee057 causes some hurt
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fix title: none available
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0fixed in mainline? no
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0affects: 2.6.33 to now
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0A bisection finger printed this patch as be=
ing a problem introduced
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0between 2.6.32 and 2.6.33. It increases a s=
mall amount the number of
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0times the page allocator stalls but drastic=
ally increased the number
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0of pages reclaimed. It's not clear why the =
commit is such a problem.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Unfortunately, I could not test a revert of=
 this patch. The CFQ and
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0block IO changes made in this window were e=
xtremely convulated and
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0overlapped heavily with a large number of p=
atches altering the same
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0code as touched by commit 718eee057. I trie=
d reverting everything
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0made on and after this commit but the resul=
ts were unsatisfactory.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Hence, there is no fix in the results below
>> >
>> > Results
>> > =3D=3D=3D=3D=3D=3D=3D
>> >
>> > Here are the highlights of kernels tested. I'm omitting the bisection
>> > results for obvious reasons. The metrics were gathered at two points;
>> > after filesystem creation and after IOZone completed.
>> >
>> > The lower the number for each metric, the better.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 After Filesystem Setup =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 After IOZone
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pg-St=
all =C2=A0pg-Wait =C2=A0pg-Rclm =C2=A0ksd-stall =C2=A0ksd-wait =C2=A0 =C2=
=A0 =C2=A0 =C2=A0pg-Stall =C2=A0pg-Wait =C2=A0pg-Rclm =C2=A0ksd-stall =C2=
=A0ksd-wait
>> > 2.6.29 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=
=A0 =C2=A0 =C2=A0183 =C2=A0 =C2=A0 =C2=A0 =C2=A0152 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.30 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=A05 =C2=A0 =C2=A0 =C2=A0 34 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=A025 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 783 =C2=A0 =C2=A0 3752 =C2=A0 =C2=A031939 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 76 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.30-asyncconfusion =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A044 =C2=
=A0 =C2=A0 =C2=A0 60 =C2=A0 =C2=A0 2656 =C2=A0 =C2=A0 =C2=A0 =C2=A0893 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.30.10 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A043 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 777 =C2=A0 =C2=A0 3699 =C2=A0 =C2=A032661 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 74 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.30.10-asyncconfusion =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A036 =C2=A0 =
=C2=A0 =C2=A0 88 =C2=A0 =C2=A0 1699 =C2=A0 =C2=A0 =C2=A0 1114 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 0
>> >
>> > asyncconfusion can be back-ported easily to 2.6.30.10. Performance is =
not
>> > perfectly in line with 2.6.29 but it's better.
>> >
>> > 2.6.31 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 49175 =C2=A0 245727 =C2=A02730626 =C2=A0 =C2=A0 17=
6344 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.31-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
3 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A031 =C2=A0 =C2=A0 =C2=A0147 =C2=A0 =C2=A0 1887 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0114 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.31-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4=
6238 =C2=A0 231000 =C2=A02549462 =C2=A0 =C2=A0 170912 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.31-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7 =C2=A0 =C2=
=A0 =C2=A0 35 =C2=A0 =C2=A0 =C2=A0448 =C2=A0 =C2=A0 =C2=A0 =C2=A0121 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.31.12 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 68897 =C2=A0 344268 =C2=A04050646 =C2=A0 =C2=A0 183523 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.31.12-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A018 =C2=
=A0 =C2=A0 =C2=A0 87 =C2=A0 =C2=A0 1009 =C2=A0 =C2=A0 =C2=A0 =C2=A0147 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.31.12-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 62797=
 =C2=A0 313805 =C2=A03786539 =C2=A0 =C2=A0 173398 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 0
>> > 2.6.31.12-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 7 =C2=A0 =C2=A0 =C2=
=A0 35 =C2=A0 =C2=A0 =C2=A0448 =C2=A0 =C2=A0 =C2=A0 =C2=A0199 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 0
>> >
>> > Applying the tty fixes from 2.6.34-rc2 and getting rid of the evict-on=
ce
>> > patches bring things back in line with 2.6.29 again.
>> >
>> > Rik, any theory on evict-once?
>> >
>> > 2.6.32 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 44437 =C2=A0 221753 =C2=A02760857 =C2=A0 =C2=A0 13=
2517 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.32-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
3 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A035 =C2=A0 =C2=A0 =C2=A0 14 =C2=A0 =C2=A0 1570 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0460 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.32-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6=
0770 =C2=A0 303206 =C2=A03659254 =C2=A0 =C2=A0 166293 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.32-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A055 =C2=A0 =C2=
=A0 =C2=A0 62 =C2=A0 =C2=A0 2496 =C2=A0 =C2=A0 =C2=A0 =C2=A0494 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 0
>> > 2.6.32.10 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 90769 =C2=A0 447702 =C2=A04251448 =C2=A0 =C2=A0 234868 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.32.10-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 148 =C2=A0 =
=C2=A0 =C2=A0597 =C2=A0 =C2=A0 8642 =C2=A0 =C2=A0 =C2=A0 =C2=A0478 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.32.10-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 91729=
 =C2=A0 453337 =C2=A04374070 =C2=A0 =C2=A0 238593 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 0
>> > 2.6.32.10-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A065 =C2=A0 =C2=A0 =C2=
=A0146 =C2=A0 =C2=A0 3408 =C2=A0 =C2=A0 =C2=A0 =C2=A0347 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 0
>> >
>> > Again, fixing tty and reverting evict-once helps bring figures more in=
 line
>> > with 2.6.29.
>> >
>> > 2.6.33 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0152248 =C2=A0 754226 =C2=A04940952 =C2=A0 =C2=A0 26=
7214 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.33-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
3 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 8=
83 =C2=A0 =C2=A0 4306 =C2=A0 =C2=A028918 =C2=A0 =C2=A0 =C2=A0 =C2=A0507 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.33-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A015=
7831 =C2=A0 782473 =C2=A05129011 =C2=A0 =C2=A0 237116 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.33-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =
=C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01056 =C2=A0 =C2=A0 52=
35 =C2=A0 =C2=A034796 =C2=A0 =C2=A0 =C2=A0 =C2=A0519 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.33.1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0156422 =C2=A0 776724 =C2=A05078145 =C2=A0 =C2=A0 234938=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.33.1-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01095 =
=C2=A0 =C2=A0 5405 =C2=A0 =C2=A036058 =C2=A0 =C2=A0 =C2=A0 =C2=A0477 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.33.1-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A03 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0136=
324 =C2=A0 673148 =C2=A04434461 =C2=A0 =C2=A0 236597 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0
>> > 2.6.33.1-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =
=C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01339 =C2=A0 =C2=A0 6624 =C2=
=A0 =C2=A043583 =C2=A0 =C2=A0 =C2=A0 =C2=A0466 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
0
>> >
>> > At this point, the CFQ commit "cfq-iosched: fairness for sync no-idle
>> > queues" has lodged itself deep within CGQ and I couldn't tear it out o=
r
>> > see how to fix it. Fixing tty and reverting evict-once helps but the n=
umber
>> > of stalls is significantly increased and a much larger number of pages=
 get
>> > reclaimed overall.
>> >
>> > Corrado?
>>
>> The major changes in I/O scheduing behaviour are:
>> * buffered writes:
>> =C2=A0 =C2=A0before we could schedule few writes, then interrupt them to=
 do
>> =C2=A0 some reads, and then go back to writes; now we guarantee some
>> =C2=A0 uninterruptible time slice for writes, but the delay between two
>> =C2=A0 slices is increased. The total write throughput averaged over a t=
ime
>> =C2=A0 window larger than 300ms should be comparable, or even better wit=
h
>> =C2=A0 2.6.33. Note that the commit you cite has introduced a bug regard=
ing
>> =C2=A0 write throughput on NCQ disks that was later fixed by 1efe8fe1, m=
erged
>> =C2=A0 before 2.6.33 (this may lead to confusing bisection results).
>
> This is true. The CFQ and block IO changes in that window are almost
> impossible to properly bisect and isolate individual changes. There were
> multiple dependant patches that modified each others changes. It's unclea=
r
> if this modification can even be isolated although your suggestion below
> is the best bet.
>
>> * reads (and sync writes):
>> =C2=A0 * before, we serviced a single process for 100ms, then switched t=
o
>> =C2=A0 =C2=A0 an other, and so on.
>> =C2=A0 * after, we go round robin for random requests (they get a unifie=
d
>> =C2=A0 =C2=A0 time slice, like buffered writes do), and we have consecut=
ive time
>> =C2=A0 =C2=A0 slices for sequential requests, but the length of the slic=
e is reduced
>> =C2=A0 =C2=A0 when the number of concurrent processes doing I/O increase=
s.
>>
>> This means that with 16 processes doing sequential I/O on the same
>> disk, before you were switching between processes every 100ms, and now
>> every 32ms. The old behaviour can be brought back by setting
>> /sys/block/sd*/queue/iosched/low_latency to 0.
>
> Will try this and see what happens.
>
>> For random I/O, the situation (going round robin, it will translate to
>> switching every 8 ms on average) is not revertable via flags.
>>
>
> At the moment, I'm not testing random IO so it shouldn't be a factor in
> the tests.
>
>> >
>> > 2.6.34-rc1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =
=C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0150629 =C2=A0 746901 =C2=A04895328 =C2=A0 =C2=A0 239233 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.34-rc1-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00=
 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02595 =C2=A0=
 =C2=A012901 =C2=A0 =C2=A084988 =C2=A0 =C2=A0 =C2=A0 =C2=A0622 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 0
>> > 2.6.34-rc1-ttyfix =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 1 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0159603 =C2=
=A0 791056 =C2=A05186082 =C2=A0 =C2=A0 223458 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> > 2.6.34-rc1-ttyfix-revertevict =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01549 =C2=A0 =C2=A0 7641 =C2=A0 =
=C2=A050484 =C2=A0 =C2=A0 =C2=A0 =C2=A0679 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0
>> >
>> > Again, ttyfix and revertevict help a lot but CFQ needs to be fixed to =
get
>> > back to 2.6.29 performance.
>> >
>> > Next Steps
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >
>> > Jens, any problems with me backporting the async/sync fixes from 2.6.3=
1 to
>> > 2.6.30.x (assuming that is still maintained, Greg?)?
>> >
>> > Rik, any suggestions on what can be done with evict-once?
>> >
>> > Corrado, any suggestions on what can be done with CFQ?
>>
>> If my intuition that switching between processes too often is
>> detrimental when you have memory pressure (higher probability to need
>> to re-page-in some of the pages that were just discarded), I suggest
>> trying setting low_latency to 0, and maybe increasing the slice_sync
>> (to get more slice to a single process before switching to an other),
>> slice_async (to give more uninterruptible time to buffered writes) and
>> slice_async_rq (to higher the limit of consecutive write requests can
>> be sent to disk).
>> While this would normally lead to a bad user experience on a system
>> with plenty of memory, it should keep things acceptable when paging in
>> / swapping / dirty page writeback is overwhelming.
>>
>
> Christian, would you be able to follow the same instructions and see can
> you make a difference to your test? It is known for your situation that
> memory is unusually low for size of your workload so it's a possibility.

An other parameter that is worth tweaking in this case is the
readahead size. If readahead size is too large for the available
memory, we might be reading, then discarding, and then reading again
the same pages.

I would also like to see some iostats output (iostats -kx 5 >
iostats.log) during the experiment run, to better understand what's
happening.

Thanks,
Corrado

>
> Thanks Corrado.
>
>> Corrado
>>
>> >
>> > Christian, can you test the following amalgamated patch on 2.6.32.10 a=
nd
>> > 2.6.33 please? Note it's 2.6.32.10 because the patches below will not =
apply
>> > cleanly to 2.6.32 but it will against 2.6.33. It's a combination of tt=
yfix
>> > and revertevict. If your problem goes away, it implies that the stalls=
 I
>> > can measure are roughly correlated to the more significant problem you=
 have.
>> >
>> > =3D=3D=3D=3D=3D CUT HERE =3D=3D=3D=3D=3D
>> >
>> > From d9661adfb8e53a7647360140af3b92284cbe52d4 Mon Sep 17 00:00:00 2001
>> > From: Alan Cox <alan@linux.intel.com>
>> > Date: Thu, 18 Feb 2010 16:43:47 +0000
>> > Subject: [PATCH] tty: Keep the default buffering to sub-page units
>> >
>> > We allocate during interrupts so while our buffering is normally diced=
 up
>> > small anyway on some hardware at speed we can pressure the VM excessiv=
ely
>> > for page pairs. We don't really need big buffers to be linear so don't=
 try
>> > so hard.
>> >
>> > In order to make this work well we will tidy up excess callers to requ=
est_room,
>> > which cannot itself enforce this break up.
>> >
>> > Signed-off-by: Alan Cox <alan@linux.intel.com>
>> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
>> >
>> > diff --git a/drivers/char/tty_buffer.c b/drivers/char/tty_buffer.c
>> > index 66fa4e1..f27c4d6 100644
>> > --- a/drivers/char/tty_buffer.c
>> > +++ b/drivers/char/tty_buffer.c
>> > @@ -247,7 +247,8 @@ int tty_insert_flip_string(struct tty_struct *tty,=
 const unsigned char *chars,
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int copied =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int space =3D tty_b=
uffer_request_room(tty, size - copied);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int goal =3D min(si=
ze - copied, TTY_BUFFER_PAGE);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int space =3D tty_b=
uffer_request_room(tty, goal);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tty_buff=
er *tb =3D tty->buf.tail;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If there is =
no space then tb may be NULL */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(sp=
ace =3D=3D 0))
>> > @@ -283,7 +284,8 @@ int tty_insert_flip_string_flags(struct tty_struct=
 *tty,
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int copied =3D 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int space =3D tty_b=
uffer_request_room(tty, size - copied);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int goal =3D min(si=
ze - copied, TTY_BUFFER_PAGE);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int space =3D tty_b=
uffer_request_room(tty, goal);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct tty_buff=
er *tb =3D tty->buf.tail;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If there is =
no space then tb may be NULL */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(sp=
ace =3D=3D 0))
>> > diff --git a/include/linux/tty.h b/include/linux/tty.h
>> > index 6abfcf5..d96e588 100644
>> > --- a/include/linux/tty.h
>> > +++ b/include/linux/tty.h
>> > @@ -68,6 +68,16 @@ struct tty_buffer {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long data[0];
>> > =C2=A0};
>> >
>> > +/*
>> > + * We default to dicing tty buffer allocations to this many character=
s
>> > + * in order to avoid multiple page allocations. We assume tty_buffer =
itself
>> > + * is under 256 bytes. See tty_buffer_find for the allocation logic t=
his
>> > + * must match
>> > + */
>> > +
>> > +#define TTY_BUFFER_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((PAGE_SIZE =C2=A0- 256) / 2)
>> > +
>> > +
>> > =C2=A0struct tty_bufhead {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct delayed_work work;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t lock;
>> > From 352fa6ad16b89f8ffd1a93b4419b1a8f2259feab Mon Sep 17 00:00:00 2001
>> > From: Mel Gorman <mel@csn.ul.ie>
>> > Date: Tue, 2 Mar 2010 22:24:19 +0000
>> > Subject: [PATCH] tty: Take a 256 byte padding into account when buffer=
ing below sub-page units
>> >
>> > The TTY layer takes some care to ensure that only sub-page allocations
>> > are made with interrupts disabled. It does this by setting a goal of
>> > "TTY_BUFFER_PAGE" to allocate. Unfortunately, while TTY_BUFFER_PAGE ta=
kes the
>> > size of tty_buffer into account, it fails to account that tty_buffer_f=
ind()
>> > rounds the buffer size out to the next 256 byte boundary before adding=
 on
>> > the size of the tty_buffer.
>> >
>> > This patch adjusts the TTY_BUFFER_PAGE calculation to take into accoun=
t the
>> > size of the tty_buffer and the padding. Once applied, tty_buffer_alloc=
()
>> > should not require high-order allocations.
>> >
>> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > Cc: stable <stable@kernel.org>
>> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
>> >
>> > diff --git a/include/linux/tty.h b/include/linux/tty.h
>> > index 568369a..593228a 100644
>> > --- a/include/linux/tty.h
>> > +++ b/include/linux/tty.h
>> > @@ -70,12 +70,13 @@ struct tty_buffer {
>> >
>> > =C2=A0/*
>> > =C2=A0* We default to dicing tty buffer allocations to this many chara=
cters
>> > - * in order to avoid multiple page allocations. We assume tty_buffer =
itself
>> > - * is under 256 bytes. See tty_buffer_find for the allocation logic t=
his
>> > - * must match
>> > + * in order to avoid multiple page allocations. We know the size of
>> > + * tty_buffer itself but it must also be taken into account that the
>> > + * the buffer is 256 byte aligned. See tty_buffer_find for the alloca=
tion
>> > + * logic this must match
>> > =C2=A0*/
>> >
>> > -#define TTY_BUFFER_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((PAGE_SIZE =C2=A0- 256) / 2)
>> > +#define TTY_BUFFER_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0(((PAGE_SIZE - siz=
eof(struct tty_buffer)) / 2) & ~0xFF)
>> >
>> >
>> > =C2=A0struct tty_bufhead {
>> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> > index bf9213b..5ba0d9a 100644
>> > --- a/include/linux/memcontrol.h
>> > +++ b/include/linux/memcontrol.h
>> > @@ -94,7 +94,6 @@ extern void mem_cgroup_note_reclaim_priority(struct =
mem_cgroup *mem,
>> > =C2=A0extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup=
 *mem,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int priority);
>> > =C2=A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>> > -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
>> > =C2=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone =
*zone,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_lis=
t lru);
>> > @@ -243,12 +242,6 @@ mem_cgroup_inactive_anon_is_low(struct mem_cgroup=
 *memcg)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
>> > =C2=A0}
>> >
>> > -static inline int
>> > -mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 return 1;
>> > -}
>> > -
>> > =C2=A0static inline unsigned long
>> > =C2=A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *=
zone,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 enum lru_list lru)
>> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> > index 66035bf..bbb0eda 100644
>> > --- a/mm/memcontrol.c
>> > +++ b/mm/memcontrol.c
>> > @@ -843,17 +843,6 @@ int mem_cgroup_inactive_anon_is_low(struct mem_cg=
roup *memcg)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> > =C2=A0}
>> >
>> > -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 unsigned long active;
>> > - =C2=A0 =C2=A0 =C2=A0 unsigned long inactive;
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 inactive =3D mem_cgroup_get_local_zonestat(memc=
g, LRU_INACTIVE_FILE);
>> > - =C2=A0 =C2=A0 =C2=A0 active =3D mem_cgroup_get_local_zonestat(memcg,=
 LRU_ACTIVE_FILE);
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 return (active > inactive);
>> > -}
>> > -
>> > =C2=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone =
*zone,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum lru_lis=
t lru)
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 692807f..5512301 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -1428,59 +1428,13 @@ static int inactive_anon_is_low(struct zone *z=
one, struct scan_control *sc)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return low;
>> > =C2=A0}
>> >
>> > -static int inactive_file_is_low_global(struct zone *zone)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 unsigned long active, inactive;
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 active =3D zone_page_state(zone, NR_ACTIVE_FILE=
);
>> > - =C2=A0 =C2=A0 =C2=A0 inactive =3D zone_page_state(zone, NR_INACTIVE_=
FILE);
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 return (active > inactive);
>> > -}
>> > -
>> > -/**
>> > - * inactive_file_is_low - check if file pages need to be deactivated
>> > - * @zone: zone to check
>> > - * @sc: =C2=A0 scan control of this context
>> > - *
>> > - * When the system is doing streaming IO, memory pressure here
>> > - * ensures that active file pages get deactivated, until more
>> > - * than half of the file pages are on the inactive list.
>> > - *
>> > - * Once we get to that situation, protect the system's working
>> > - * set from being evicted by disabling active file page aging.
>> > - *
>> > - * This uses a different ratio than the anonymous pages, because
>> > - * the page cache uses a use-once replacement algorithm.
>> > - */
>> > -static int inactive_file_is_low(struct zone *zone, struct scan_contro=
l *sc)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 int low;
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 if (scanning_global_lru(sc))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low =3D inactive_fi=
le_is_low_global(zone);
>> > - =C2=A0 =C2=A0 =C2=A0 else
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low =3D mem_cgroup_=
inactive_file_is_low(sc->mem_cgroup);
>> > - =C2=A0 =C2=A0 =C2=A0 return low;
>> > -}
>> > -
>> > -static int inactive_list_is_low(struct zone *zone, struct scan_contro=
l *sc,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int file)
>> > -{
>> > - =C2=A0 =C2=A0 =C2=A0 if (file)
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return inactive_fil=
e_is_low(zone, sc);
>> > - =C2=A0 =C2=A0 =C2=A0 else
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return inactive_ano=
n_is_low(zone, sc);
>> > -}
>> > -
>> > =C2=A0static unsigned long shrink_list(enum lru_list lru, unsigned lon=
g nr_to_scan,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone, struct scan_control *sc,=
 int priority)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0int file =3D is_file_lru(lru);
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 if (is_active_lru(lru)) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (inactive_list_i=
s_low(zone, sc, file))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrin=
k_active_list(nr_to_scan, zone, sc, priority, file);
>> > + =C2=A0 =C2=A0 =C2=A0 if (lru =3D=3D LRU_ACTIVE_FILE) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_active_list(=
nr_to_scan, zone, sc, priority, file);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
