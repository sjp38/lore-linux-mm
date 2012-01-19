Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 8C1F46B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 06:55:46 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC 1/3] /dev/low_mem_notify
Date: Thu, 19 Jan 2012 11:54:58 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB9826904559D9B@008-AM1MPN1-003.mgdnok.nokia.com>
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
	<84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLHd5dCvBwV5gsraFZXh86wq7tg7uLLnevN8Pp_jGiOBbw@mail.gmail.com>
In-Reply-To: <CAOJsxLHd5dCvBwV5gsraFZXh86wq7tg7uLLnevN8Pp_jGiOBbw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: rhod@redhat.com, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 19 January, 2012 13:08
...
> > 1. rename this API from low_mem_pressure to something more related to
> > notification and memory situation in system: memory_pressure,
> > memnotify, memory_level etc. The word "low" is misleading here
>=20
> The thing is called vmevent:

Yes, I see it. But I was a bit confused with vmnotify_fops and was sure it =
is mapped through dev. Now it anonymous inode.

>=20
> On Thu, Jan 19, 2012 at 12:53 PM,  <leonid.moiseichuk@nokia.com> wrote:
> > 2. API must use deferred timers to prevent use-time impact. Deferred
> > timer will be triggered only in case HW event or non-deferrable timer,
> > so if device sleeps timer might be skipped and that is what expected
> > for user-space
>=20
> I'm currently looking at the possibility of hooking VM events to perf whi=
ch
> also uses hrtimers. Can't we make hrtimers do the right thing?

I had no answer for this question. According to hrtimer_cpu_notify the cpu =
state is tracked but timer may set HW event to wake up.
In this case use-time will be affected due to you will have too much HW eve=
nts and reasons to wakeup.
At least powertop reports hrtimers in relation to <kernel core> as an activ=
ities sources.

>=20
> On Thu, Jan 19, 2012 at 12:53 PM,  <leonid.moiseichuk@nokia.com> wrote:
> > 3. API should be tunable for propagate changes when level is Up or
> > Down, maybe both ways.
>=20
> Agreed.
>=20
> On Thu, Jan 19, 2012 at 12:53 PM,  <leonid.moiseichuk@nokia.com> wrote:
> > 4. to avoid triggering too much events probably has sense to filter
> > according to amount of change but that is optional. If subscriber set
> > timer to 1s the amount of events should not be very big.
>=20
> Agreed.
>=20
> On Thu, Jan 19, 2012 at 12:53 PM,  <leonid.moiseichuk@nokia.com> wrote:
> > 5. API must provide interface to request parameters e.g. available
> > swap or free memory just to have some base.
>=20
> The current ABI already supports that. You can specify which attributes
> you're interested in and they will be delivered as part of th event.

But you have in vmnotify.h suspicious free_pages_threshold field.

>=20
> On Thu, Jan 19, 2012 at 12:53 PM,  <leonid.moiseichuk@nokia.com> wrote:
> > 6. I do not understand how work with attributes performed ( ) but it
> > has sense to use mask and fill requested attributes using mask and
> > callback table i.e. if free pages requested - they are reported, otherw=
ise
> not.
>=20
> That's how it works now in the git tree.

Vmnotify.c has vmnotify_watch_event which collects fixed set of parameters.

> I'm currently looking at how to support Minchan's non-sampled events. It
> seems to me integrating with perf would be nice because we could simply
> use tracepoints for this.

If tracepoints not jeopardize use time has sense to do it.

>=20
> 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
