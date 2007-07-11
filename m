Date: Wed, 11 Jul 2007 05:59:05 +0200 (CEST)
From: Grzegorz Kulewski <kangur@polcom.net>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.63.0707110518280.9258@alpha.polcom.net>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
 <200707102015.44004.kernel@kolivas.org> <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Hawkins <darthmdh@gmail.com>, linux-kernel@vger.kernel.org, Con Kolivas <kernel@kolivas.org>, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Andrew Morton wrote:
> On Wed, 11 Jul 2007 11:02:56 +1000 "Matthew Hawkins" <darthmdh@gmail.com> wrote:
>
>> We all know swap prefetch has been tested out the wazoo since Moses was a
>> little boy, is compile-time and runtime selectable, and gives an important
>> and quantifiable performance increase to desktop systems.
>
> Always interested.  Please provide us more details on your usage and
> testing of that code.  Amount of memory, workload, observed results,
> etc?

I am using swap prefetch in -ck kernels since it was introduced.

My machine: Athlon XP 2000MHz, 1GB DDR 266, fast SATA disk, different 
swap configurations but usually heaps of swap (2GB and/or 8GB).

My workload: desktop usage, KDE, software development, Firefox (HUGE 
memory hog), Eclipse and all that stuff (HUGE memory hog), sometimes other 
applications, sometimes some game such as Americas Army (that one will eat 
all your memory in any configuration), Konsole with heaps of tabs, usually 
some heavy compilations in the background.

Observed result (of not broken swap prefetch versions): after closing some 
memory hog (for example stopping playing game and starting to write some 
code or reloading Firefox after it leaked enough memory to nearly bring 
the system down) the disk will work for some time and after that 
everything works as expected, no heavy swap-in when switching between 
applications and so on, nearly no lags in desktop usage.

This is nearly unnoticable. Unless I have to run pure mainline. In that 
case I can notice that swap prefetch is off very quickly because after 
closing such memory hog and returning to some other application the system 
is slow for long time. Worse: after it starts to work reasonably and I try 
to switch to some other application or even try to use some dialog window 
or module of current application I have to wait, sometimes > 10s for it to 
swap back in (even if 70% of my RAM is free at that time, after memory hog 
is gone). It is painfull.

I observed similar results on my laptop (Athlon 64, 512MB RAM, slow ATA 
disk, similar workload but reduced because hardware is weak).

For me swap prefetch makes huge difference. The system lags a lot less in 
such circumstances.

Personaly I think swap prefetch is a hack. Maybe not very dirty and ugly 
but still a hack. But since:

* nobody proposed anything that can replace it and can be considered a 
no-hack,
* swap prefetch is rather well tested and shouldn't cause regressions (no 
known regressions as far as I know, the patch does not look very 
invasive, was reviewed several times, ...),
* Con said he won't make further -ck relases and won't port these patches 
to newer kernels,
* there are at least several people who see the difference,
* if somebody really hates it (s)he can turn it off

I think it could get merged, at least temporarily, before somebody can 
suggest some better or extended solution.

Personaly I would be very happy to see it in so people like me don't have 
to patch it in or (worse) port it (possibly causing bugs and filling 
additional bug reports and asking additional questions on these lists).

I even wonder if adding the opposite of swap prefetch too wouldn't be even 
better for many workloads. Something like: "when system and swap-disk is 
idle try to copy some pages to swap so when system needs memory swap-out 
could be much cheaper". I suspect patch like that can reduce startup times 
(and other operations) of great memory hogs because disk (the slowest 
device) will only have to read the application and won't have to swap-out 
half of the RAM at the same time.

I am happy to provide further info if needed.


Thanks,

Grzegorz Kulewski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
