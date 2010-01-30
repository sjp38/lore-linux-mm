Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AAAB56B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 13:55:50 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Update][PATCH] MM / PM: Force GFP_NOIO during suspend/hibernation and resume
Date: Sat, 30 Jan 2010 19:56:41 +0100
References: <201001212121.50272.rjw@sisk.pl> <201001252249.18690.rjw@sisk.pl> <4B5E1281.7090700@suse.de>
In-Reply-To: <4B5E1281.7090700@suse.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201001301956.41372.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Alexey Starikovskiy <astarikovskiy@suse.de>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Monday 25 January 2010, Alexey Starikovskiy wrote:
> Rafael J. Wysocki =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > On Saturday 23 January 2010, Maxim Levitsky wrote:
> >> On Fri, 2010-01-22 at 22:19 +0100, Rafael J. Wysocki wrote:=20
> >>> On Friday 22 January 2010, Maxim Levitsky wrote:
> >>>> On Fri, 2010-01-22 at 10:42 +0900, KOSAKI Motohiro wrote:=20
> >>>>>>>> Probably we have multiple option. but I don't think GFP_NOIO is =
good
> >>>>>>>> option. It assume the system have lots non-dirty cache memory an=
d it isn't
> >>>>>>>> guranteed.
> >>>>>>> Basically nothing is guaranteed in this case.  However, does it a=
ctually make
> >>>>>>> things _worse_? =20
> >>>>>> Hmm..
> >>>>>> Do you mean we don't need to prevent accidental suspend failure?
> >>>>>> Perhaps, I did misunderstand your intention. If you think your pat=
ch solve
> >>>>>> this this issue, I still disagree. but If you think your patch mit=
igate
> >>>>>> the pain of this issue, I agree it. I don't have any reason to opp=
ose your
> >>>>>> first patch.
> >>>>> One question. Have anyone tested Rafael's $subject patch?=20
> >>>>> Please post test result. if the issue disapper by the patch, we can
> >>>>> suppose the slowness is caused by i/o layer.
> >>>> I did.
> >>>>
> >>>> As far as I could see, patch does solve the problem I described.
> >>>>
> >>>> Does it affect speed of suspend? I can't say for sure. It seems to be
> >>>> the same.
> >>> Thanks for testing.
> >> I'll test that too, soon.
> >> Just to note that I left my hibernate loop run overnight, and now I am
> >> posting from my notebook after it did 590 hibernate cycles.
> >=20
> > Did you have a chance to test it?
> >=20
> >> Offtopic, but Note that to achieve that I had to stop using global acpi
> >> hardware lock. I tried all kinds of things, but for now it just hands
> >> from time to time.
> >> See http://bugzilla.kernel.org/show_bug.cgi?id=3D14668
> >=20
> > I'm going to look at that later this week, although I'm not sure I can =
do more
> > than Alex about that.
> >=20
> > Rafael
> Rafael,
> If you can point to where one may insert callback to be called just befor=
e handing control to resume kernel,
> it may help...

Generally speaking, I'd do that in a .suspend() callback of one of devices.

If that's inconvenient, you can also place it in the .pre_restore() platform
hibernate callback (drivers/acpi/sleep.c).  It only disables GPEs right now,
it might release the global lock as well.

The .pre_restore() callback is executed after all devices have been suspend=
ed,
so there's no danger any driver would re-acquire the global lock after that.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
