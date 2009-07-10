Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C51506B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 12:50:26 -0400 (EDT)
Received: by vwj5 with SMTP id 5so284615vwj.12
        for <linux-mm@kvack.org>; Fri, 10 Jul 2009 09:50:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090710083429.GC24168@localhost>
References: <20090608091044.880249722@intel.com>
	 <ab418ea90907100024xe95ab44pb0809d262e616565@mail.gmail.com>
	 <20090710083429.GC24168@localhost>
Date: Sat, 11 Jul 2009 00:50:50 +0800
Message-ID: <ab418ea90907100950o48c65cedxb491d7a207667a75@mail.gmail.com>
Subject: Re: [PATCH 0/3] make mapped executable pages the first class citizen
	(with test cases)
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 10, 2009 at 4:34 PM, Wu Fengguang<fengguang.wu@intel.com> wrote=
:
> On Fri, Jul 10, 2009 at 03:24:29PM +0800, Nai Xia wrote:
>> Hi,
>>
>> I was able to launch some tests with SPEC cpu2006.
>> The benchmark was based on mmotm
>> commit 0b7292956dbdfb212abf6e3c9cfb41e9471e1081 on a intel =A0Q6600 box =
with
>> 4G ram. The kernel cmdline mem=3D500M was used to see how good exec-prot=
 can
>> be under memory stress.
>
> Thank you for the testings, Nai!

You are welcome :)

>
>> Following are the results:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Esti=
mated
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Base =A0 =A0 Base =A0 =A0 =A0 Base
>> Benchmarks =A0 =A0 =A0Ref. =A0 Run Time =A0 =A0 Ratio
>>
>> mmotm with 500M
>> 400.perlbench =A0 =A09770 =A0 =A0 =A0 =A0671 =A0 =A0 =A014.6 =A0*
>> 401.bzip2 =A0 =A0 =A0 =A09650 =A0 =A0 =A0 1011 =A0 =A0 =A0 9.55 *
>> 403.gcc =A0 =A0 =A0 =A0 =A08050 =A0 =A0 =A0 =A0774 =A0 =A0 =A010.4 =A0*
>> 462.libquantum =A020720 =A0 =A0 =A0 1213 =A0 =A0 =A017.1 =A0*
>>
>>
>> mmot-prot with 500M
>> 400.perlbench =A0 =A09770 =A0 =A0 =A0 =A0658 =A0 =A0 =A014.8 =A0*
>> 401.bzip2 =A0 =A0 =A0 =A09650 =A0 =A0 =A0 1007 =A0 =A0 =A0 9.58 *
>> 403.gcc =A0 =A0 =A0 =A0 =A08050 =A0 =A0 =A0 =A0749 =A0 =A0 =A010.8 =A0*
>> 462.libquantum =A020720 =A0 =A0 =A0 1116 =A0 =A0 =A018.6 =A0*
>>
>> mmotm with 4G ( allowing the full working sets)
>> 400.perlbench =A0 =A09770 =A0 =A0 =A0 =A0594 =A0 =A0 =A016.5 =A0*
>> 401.bzip2 =A0 =A0 =A0 =A09650 =A0 =A0 =A0 =A0828 =A0 =A0 =A011.7 =A0*
>> 403.gcc =A0 =A0 =A0 =A0 =A08050 =A0 =A0 =A0 =A0523 =A0 =A0 =A015.4 =A0*
>> 462.libquantum =A020720 =A0 =A0 =A0 1121 =A0 =A0 =A018.5 =A0*
>
> mmotm =A0 =A0mmotm-prot =A0mmotm-4G =A0 =A0mmotm-prot =A0 mmotm-4G
> 14.6 =A0 =A0 14.8 =A0 =A0 =A0 =A016.5 =A0 =A0 =A0 =A0+1.4% =A0 =A0 =A0 =
=A0+13.0%
> =A09.55 =A0 =A0 9.58 =A0 =A0 =A0 11.7 =A0 =A0 =A0 =A0+0.3% =A0 =A0 =A0 =
=A0+22.5%
> 10.4 =A0 =A0 10.8 =A0 =A0 =A0 =A015.4 =A0 =A0 =A0 =A0+3.8% =A0 =A0 =A0 =
=A0+48.1%
> 17.1 =A0 =A0 18.6 =A0 =A0 =A0 =A018.5 =A0 =A0 =A0 =A0+8.8% =A0 =A0 =A0 =
=A0 +8.2%
>
> So it's mostly small improvements.
>
>> It's worth noting that SPEC documented "The CPU2006 benchmarks
>> (code + workload) have been designed to fit within about 1GB of
>> physical memory",
>> and the exec vm sizes of these programs are as below:
>> perlbench =A0956KB
>> bzip2 =A0 =A0 =A0 =A0 56KB
>> gcc =A0 =A0 =A0 =A0 =A03008KB
>> libquantum =A036KB
>>
>>
>> Are we expecting to see more good results for cpu-bound programs (e.g.
>> scientific ones)
>> with large number of exec pages ?
>
> Not likely. Scientific computing is typically equipped with lots of
> memory and the footprint of the program itself is relatively small.

OK, well, maybe as long as there is still swapping, improvement is
possible. Actually, in the above cases like bzip2, its exec footprint
is already quite small compared to the percentage of the improvement.
Let me see if I am lucky enough to have someone majoring in computing chemi=
stry
in our Univ. give a benchmark. :) You know they have relatively small
machines doing
small personal computing jobs and sometimes swapping still matters.

>
> The exec-mmap protection mainly helps when some exec pages/programs
> have been inactive for some minutes and then go active. That's the
> typically desktop use pattern.

OK.  Still it's good to see that this patch can improve more than 20% on av=
erage
on non-typical cases, hehe.

Regards,
Nai

>
> Thanks,
> Fengguang
>
>> On Mon, Jun 8, 2009 at 5:10 PM, Wu Fengguang<fengguang.wu@intel.com> wro=
te:
>> > Andrew,
>> >
>> > I managed to back this patchset with two test cases :)
>> >
>> > They demonstrated that
>> > - X desktop responsiveness can be *doubled* under high memory/swap pre=
ssure
>> > - it can almost stop major faults when the active file list is slowly =
scanned
>> > =A0because of undergoing partially cache hot streaming IO
>> >
>> > The details are included in the changelog.
>> >
>> > Thanks,
>> > Fengguang
>> > --
>> >
>> > --
>> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> > see: http://www.linux-mm.org/ .
>> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
