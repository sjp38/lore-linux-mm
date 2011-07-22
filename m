Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3707B6B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 09:22:12 -0400 (EDT)
Received: by pzk33 with SMTP id 33so3795262pzk.36
        for <linux-mm@kvack.org>; Fri, 22 Jul 2011 06:22:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAEwNFnD2ZTARC1Yw2uEYVSctBo7wsmA7rmQOaFH2rwOKoo3YjA@mail.gmail.com>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <20110721153722.GD1713@barrios-desktop> <20110721160958.GT5349@suse.de>
 <20110721162417.GF1713@barrios-desktop> <CAObL_7HpE3mCS90Zfa9-edBKPFN1MuBOHv+=e6BNHsi2u3zTOQ@mail.gmail.com>
 <20110721164238.GA3326@barrios-desktop> <CAObL_7HN2tbXiVZ1vcwpTUMf5v1EPG0XsQqUuCYn8yWtm7AA9A@mail.gmail.com>
 <CAEwNFnD2ZTARC1Yw2uEYVSctBo7wsmA7rmQOaFH2rwOKoo3YjA@mail.gmail.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 22 Jul 2011 09:21:47 -0400
Message-ID: <CAObL_7ES+6xcLCewtOaZby5uYnT3F91TuKPVZc_aOWSpRjNg3A@mail.gmail.com>
Subject: Re: [PATCH 0/4] Stop kswapd consuming 100% CPU when highest zone is small
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2011 at 8:30 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Jul 22, 2011 at 1:58 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>> On Thu, Jul 21, 2011 at 12:42 PM, Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>>> On Thu, Jul 21, 2011 at 12:36:11PM -0400, Andrew Lutomirski wrote:
>>>> On Thu, Jul 21, 2011 at 12:24 PM, Minchan Kim <minchan.kim@gmail.com> =
wrote:
>>>> > On Thu, Jul 21, 2011 at 05:09:59PM +0100, Mel Gorman wrote:
>>>> >> On Fri, Jul 22, 2011 at 12:37:22AM +0900, Minchan Kim wrote:
>>>> >> > On Fri, Jun 24, 2011 at 03:44:53PM +0100, Mel Gorman wrote:
>>>> >> > > (Built this time and passed a basic sniff-test.)
>>>> >> > >
>>>> >> > > During allocator-intensive workloads, kswapd will be woken freq=
uently
>>>> >> > > causing free memory to oscillate between the high and min water=
mark.
>>>> >> > > This is expected behaviour. =A0Unfortunately, if the highest zo=
ne is
>>>> >> > > small, a problem occurs.
>>>> >> > >
>>>> >> > > This seems to happen most with recent sandybridge laptops but i=
t's
>>>> >> > > probably a co-incidence as some of these laptops just happen to=
 have
>>>> >> > > a small Normal zone. The reproduction case is almost always dur=
ing
>>>> >> > > copying large files that kswapd pegs at 100% CPU until the file=
 is
>>>> >> > > deleted or cache is dropped.
>>>> >> > >
>>>> >> > > The problem is mostly down to sleeping_prematurely() keeping ks=
wapd
>>>> >> > > awake when the highest zone is small and unreclaimable and comp=
ounded
>>>> >> > > by the fact we shrink slabs even when not shrinking zones causi=
ng a lot
>>>> >> > > of time to be spent in shrinkers and a lot of memory to be recl=
aimed.
>>>> >> > >
>>>> >> > > Patch 1 corrects sleeping_prematurely to check the zones matchi=
ng
>>>> >> > > =A0 the classzone_idx instead of all zones.
>>>> >> > >
>>>> >> > > Patch 2 avoids shrinking slab when we are not shrinking a zone.
>>>> >> > >
>>>> >> > > Patch 3 notes that sleeping_prematurely is checking lower zones=
 against
>>>> >> > > =A0 a high classzone which is not what allocators or balance_pg=
dat()
>>>> >> > > =A0 is doing leading to an artifical believe that kswapd should=
 be
>>>> >> > > =A0 still awake.
>>>> >> > >
>>>> >> > > Patch 4 notes that when balance_pgdat() gives up on a high zone=
 that the
>>>> >> > > =A0 decision is not communicated to sleeping_prematurely()
>>>> >> > >
>>>> >> > > This problem affects 2.6.38.8 for certain and is expected to af=
fect
>>>> >> > > 2.6.39 and 3.0-rc4 as well. If accepted, they need to go to -st=
able
>>>> >> > > to be picked up by distros and this series is against 3.0-rc4. =
I've
>>>> >> > > cc'd people that reported similar problems recently to see if t=
hey
>>>> >> > > still suffer from the problem and if this fixes it.
>>>> >> > >
>>>> >> >
>>>> >> > Good!
>>>> >> > This patch solved the problem.
>>>> >> > But there is still a mystery.
>>>> >> >
>>>> >> > In log, we could see excessive shrink_slab calls.
>>>> >>
>>>> >> Yes, because shrink_slab() was called on each loop through
>>>> >> balance_pgdat() even if the zone was balanced.
>>>> >>
>>>> >>
>>>> >> > And as you know, we had merged patch which adds cond_resched wher=
e last of the function
>>>> >> > in shrink_slab. So other task should get the CPU and we should no=
t see
>>>> >> > 100% CPU of kswapd, I think.
>>>> >> >
>>>> >>
>>>> >> cond_resched() is not a substitute for going to sleep.
>>>> >
>>>> > Of course, it's not equal with sleep but other task should get CPU a=
nd conusme their time slice
>>>> > So we should never see 100% CPU consumption of kswapd.
>>>> > No?
>>>>
>>>> If the rest of the system is idle, then kswapd will happily use 100%
>>>> CPU. =A0(Or on a multi-core system, kswapd will use close to 100% of o=
ne
>>>
>>> Of course. But at least, we have a test program and I think it's not id=
le.
>>
>> The test program I used was 'top', which is pretty close to idle.
>>
>>>
>>>> CPU even if another task is using the other one. =A0This is bad enough
>>>> on a desktop, but on a laptop you start to notice when your battery
>>>> dies.)
>>>
>>> Of course it's bad. :)
>>> What I want to know is just what's exact cause of 100% CPU usage.
>>> It might be not 100% but we might use the word sloppily.
>>>
>>
>> Well, if you want to pedantic, my laptop can, in theory, demonstrate
>> true 100% CPU usage. =A0Trigger the bug, suspend every other thread, and
>> listen to the laptop fan spin and feel the laptop get hot. =A0(The fan
>> is controlled by the EC and takes no CPU.)
>>
>> In practice, the usage was close enough to 100% that it got rounded.
>>
>> The cond_resched was enough to at least make the system responsive
>> instead of the hard freeze I used to get.
>
> I don't want to be pedantic. :)
> What I have a thought about 100% CPU usage was that it doesn't yield
> CPU and spins on the CPU but as I heard your example(ie, cond_resched
> makes the system responsive), it's not the case. It was just to use
> most of time in kswapd, not 100%. It seems I was paranoid about the
> word, sorry for that.

Ah, sorry.  I must have been unclear in my original email.

In 2.6.39, it made my system unresponsive.  With your cond_resched and
pgdat_balanced fixes, it just made kswapd eat all available CPU, but
the system still worked.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
