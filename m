Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 1F75B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 05:54:12 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC 1/3] /dev/low_mem_notify
Date: Thu, 19 Jan 2012 10:53:29 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
 <1326788038-29141-2-git-send-email-minchan@kernel.org>
 <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
 <4F15A34F.40808@redhat.com>
 <alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
 <84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
 <4F175706.8000808@redhat.com>
 <alpine.LFD.2.02.1201190922390.3033@tux.localdomain>
 <4F17DCED.4020908@redhat.com>
 <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
 <4F17E058.8020008@redhat.com>
In-Reply-To: <4F17E058.8020008@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rhod@redhat.com, penberg@kernel.org
Cc: riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

> -----Original Message-----
> From: ext Ronen Hod [mailto:rhod@redhat.com]
> Sent: 19 January, 2012 11:20
> To: Pekka Enberg
...
> >>> Isn't
> >>>
> >>> /proc/sys/vm/min_free_kbytes
> >>>
> >>> pretty much just that?
> >> Would you suggest to use min_free_kbytes as the threshold for sending
> >> low_memory_notifications to applications, and separately as a target
> >> value for the applications' memory giveaway?
> > I'm not saying that the kernel should use it directly but it seems
> > like the kind of "ideal number of free pages" threshold you're
> > suggesting. So userspace can read that value and use it as the "number
> > of free pages" threshold for VM events, no?
>=20
> Yes, I like it. The rules of the game are simple and consistent all over,=
 be it the
> alert threshold, voluntary poling by the apps, and for concurrent work by
> several applications.
> Well, as long as it provides a good indication for low_mem_pressure.

For me it doesn't look that have much sense. min_free_kbytes could be set f=
rom user-space (or auto-tuned by kernel) to keep some amount=20
of memory available for GFP_ATOMIC allocations.  In case situation comes un=
der pointed level kernel will reclaim memory from e.g. caches.

>From potential user point of view the proposed API has number of lacks whic=
h would be nice to have implemented:
1. rename this API from low_mem_pressure to something more related to notif=
ication and memory situation in system: memory_pressure, memnotify, memory_=
level etc. The word "low" is misleading here
2. API must use deferred timers to prevent use-time impact. Deferred timer =
will be triggered only in case HW event or non-deferrable timer, so if devi=
ce sleeps timer might be skipped and that is what expected for user-space
3. API should be tunable for propagate changes when level is Up or Down, ma=
ybe both ways.=20
4. to avoid triggering too much events probably has sense to filter accordi=
ng to amount of change but that is optional. If subscriber set timer to 1s =
the amount of events should not be very big.
5. API must provide interface to request parameters e.g. available swap or =
free memory just to have some base.
6. I do not understand how work with attributes performed ( ) but it has se=
nse to use mask and fill requested attributes using mask and callback table=
 i.e. if free pages requested - they are reported, otherwise not.
7. would have sense to backport couple of attributes from memnotify.c

I can submit couple of patches if some of proposals looks sane for everyone=
.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
