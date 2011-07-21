Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D76536B00FC
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 12:58:51 -0400 (EDT)
Received: by pvc12 with SMTP id 12so1599234pvc.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 09:58:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110721164238.GA3326@barrios-desktop>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <20110721153722.GD1713@barrios-desktop> <20110721160958.GT5349@suse.de>
 <20110721162417.GF1713@barrios-desktop> <CAObL_7HpE3mCS90Zfa9-edBKPFN1MuBOHv+=e6BNHsi2u3zTOQ@mail.gmail.com>
 <20110721164238.GA3326@barrios-desktop>
From: Andrew Lutomirski <luto@mit.edu>
Date: Thu, 21 Jul 2011 12:58:29 -0400
Message-ID: <CAObL_7HN2tbXiVZ1vcwpTUMf5v1EPG0XsQqUuCYn8yWtm7AA9A@mail.gmail.com>
Subject: Re: [PATCH 0/4] Stop kswapd consuming 100% CPU when highest zone is small
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2011 at 12:42 PM, Minchan Kim <minchan.kim@gmail.com> wrote=
:
> On Thu, Jul 21, 2011 at 12:36:11PM -0400, Andrew Lutomirski wrote:
>> On Thu, Jul 21, 2011 at 12:24 PM, Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>> > On Thu, Jul 21, 2011 at 05:09:59PM +0100, Mel Gorman wrote:
>> >> On Fri, Jul 22, 2011 at 12:37:22AM +0900, Minchan Kim wrote:
>> >> > On Fri, Jun 24, 2011 at 03:44:53PM +0100, Mel Gorman wrote:
>> >> > > (Built this time and passed a basic sniff-test.)
>> >> > >
>> >> > > During allocator-intensive workloads, kswapd will be woken freque=
ntly
>> >> > > causing free memory to oscillate between the high and min waterma=
rk.
>> >> > > This is expected behaviour. =A0Unfortunately, if the highest zone=
 is
>> >> > > small, a problem occurs.
>> >> > >
>> >> > > This seems to happen most with recent sandybridge laptops but it'=
s
>> >> > > probably a co-incidence as some of these laptops just happen to h=
ave
>> >> > > a small Normal zone. The reproduction case is almost always durin=
g
>> >> > > copying large files that kswapd pegs at 100% CPU until the file i=
s
>> >> > > deleted or cache is dropped.
>> >> > >
>> >> > > The problem is mostly down to sleeping_prematurely() keeping kswa=
pd
>> >> > > awake when the highest zone is small and unreclaimable and compou=
nded
>> >> > > by the fact we shrink slabs even when not shrinking zones causing=
 a lot
>> >> > > of time to be spent in shrinkers and a lot of memory to be reclai=
med.
>> >> > >
>> >> > > Patch 1 corrects sleeping_prematurely to check the zones matching
>> >> > > =A0 the classzone_idx instead of all zones.
>> >> > >
>> >> > > Patch 2 avoids shrinking slab when we are not shrinking a zone.
>> >> > >
>> >> > > Patch 3 notes that sleeping_prematurely is checking lower zones a=
gainst
>> >> > > =A0 a high classzone which is not what allocators or balance_pgda=
t()
>> >> > > =A0 is doing leading to an artifical believe that kswapd should b=
e
>> >> > > =A0 still awake.
>> >> > >
>> >> > > Patch 4 notes that when balance_pgdat() gives up on a high zone t=
hat the
>> >> > > =A0 decision is not communicated to sleeping_prematurely()
>> >> > >
>> >> > > This problem affects 2.6.38.8 for certain and is expected to affe=
ct
>> >> > > 2.6.39 and 3.0-rc4 as well. If accepted, they need to go to -stab=
le
>> >> > > to be picked up by distros and this series is against 3.0-rc4. I'=
ve
>> >> > > cc'd people that reported similar problems recently to see if the=
y
>> >> > > still suffer from the problem and if this fixes it.
>> >> > >
>> >> >
>> >> > Good!
>> >> > This patch solved the problem.
>> >> > But there is still a mystery.
>> >> >
>> >> > In log, we could see excessive shrink_slab calls.
>> >>
>> >> Yes, because shrink_slab() was called on each loop through
>> >> balance_pgdat() even if the zone was balanced.
>> >>
>> >>
>> >> > And as you know, we had merged patch which adds cond_resched where =
last of the function
>> >> > in shrink_slab. So other task should get the CPU and we should not =
see
>> >> > 100% CPU of kswapd, I think.
>> >> >
>> >>
>> >> cond_resched() is not a substitute for going to sleep.
>> >
>> > Of course, it's not equal with sleep but other task should get CPU and=
 conusme their time slice
>> > So we should never see 100% CPU consumption of kswapd.
>> > No?
>>
>> If the rest of the system is idle, then kswapd will happily use 100%
>> CPU. =A0(Or on a multi-core system, kswapd will use close to 100% of one
>
> Of course. But at least, we have a test program and I think it's not idle=
.

The test program I used was 'top', which is pretty close to idle.

>
>> CPU even if another task is using the other one. =A0This is bad enough
>> on a desktop, but on a laptop you start to notice when your battery
>> dies.)
>
> Of course it's bad. :)
> What I want to know is just what's exact cause of 100% CPU usage.
> It might be not 100% but we might use the word sloppily.
>

Well, if you want to pedantic, my laptop can, in theory, demonstrate
true 100% CPU usage.  Trigger the bug, suspend every other thread, and
listen to the laptop fan spin and feel the laptop get hot.  (The fan
is controlled by the EC and takes no CPU.)

In practice, the usage was close enough to 100% that it got rounded.

The cond_resched was enough to at least make the system responsive
instead of the hard freeze I used to get.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
