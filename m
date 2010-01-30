Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 107CF6B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 15:53:25 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Update][PATCH] MM / PM: Force GFP_NOIO during suspend/hibernation and resume
Date: Sat, 30 Jan 2010 21:53:52 +0100
References: <201001212121.50272.rjw@sisk.pl> <201001301956.41372.rjw@sisk.pl> <1264884140.13861.7.camel@maxim-laptop>
In-Reply-To: <1264884140.13861.7.camel@maxim-laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201001302153.53016.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: Alexey Starikovskiy <astarikovskiy@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Saturday 30 January 2010, Maxim Levitsky wrote:
> On Sat, 2010-01-30 at 19:56 +0100, Rafael J. Wysocki wrote:=20
> > On Monday 25 January 2010, Alexey Starikovskiy wrote:
> > > Rafael J. Wysocki =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > On Saturday 23 January 2010, Maxim Levitsky wrote:
> > > >> On Fri, 2010-01-22 at 22:19 +0100, Rafael J. Wysocki wrote:=20
> > > >>> On Friday 22 January 2010, Maxim Levitsky wrote:
> > > >>>> On Fri, 2010-01-22 at 10:42 +0900, KOSAKI Motohiro wrote:=20
> > > >>>>>>>> Probably we have multiple option. but I don't think GFP_NOIO=
 is good
> > > >>>>>>>> option. It assume the system have lots non-dirty cache memor=
y and it isn't
> > > >>>>>>>> guranteed.
> > > >>>>>>> Basically nothing is guaranteed in this case.  However, does =
it actually make
> > > >>>>>>> things _worse_? =20
> > > >>>>>> Hmm..
> > > >>>>>> Do you mean we don't need to prevent accidental suspend failur=
e?
> > > >>>>>> Perhaps, I did misunderstand your intention. If you think your=
 patch solve
> > > >>>>>> this this issue, I still disagree. but If you think your patch=
 mitigate
> > > >>>>>> the pain of this issue, I agree it. I don't have any reason to=
 oppose your
> > > >>>>>> first patch.
> > > >>>>> One question. Have anyone tested Rafael's $subject patch?=20
> > > >>>>> Please post test result. if the issue disapper by the patch, we=
 can
> > > >>>>> suppose the slowness is caused by i/o layer.
> > > >>>> I did.
> > > >>>>
> > > >>>> As far as I could see, patch does solve the problem I described.
> > > >>>>
> > > >>>> Does it affect speed of suspend? I can't say for sure. It seems =
to be
> > > >>>> the same.
> > > >>> Thanks for testing.
> > > >> I'll test that too, soon.
> > > >> Just to note that I left my hibernate loop run overnight, and now =
I am
> > > >> posting from my notebook after it did 590 hibernate cycles.
> > > >=20
> > > > Did you have a chance to test it?
> > > >=20
> > > >> Offtopic, but Note that to achieve that I had to stop using global=
 acpi
> > > >> hardware lock. I tried all kinds of things, but for now it just ha=
nds
> > > >> from time to time.
> > > >> See http://bugzilla.kernel.org/show_bug.cgi?id=3D14668
> > > >=20
> > > > I'm going to look at that later this week, although I'm not sure I =
can do more
> > > > than Alex about that.
> > > >=20
> > > > Rafael
> > > Rafael,
> > > If you can point to where one may insert callback to be called just b=
efore handing control to resume kernel,
> > > it may help...
> >=20
> > Generally speaking, I'd do that in a .suspend() callback of one of devi=
ces.
> >=20
> > If that's inconvenient, you can also place it in the .pre_restore() pla=
tform
> > hibernate callback (drivers/acpi/sleep.c).  It only disables GPEs right=
 now,
> > it might release the global lock as well.
> >=20
> > The .pre_restore() callback is executed after all devices have been sus=
pended,
> > so there's no danger any driver would re-acquire the global lock after =
that.
>=20
>=20
> Well, I did that very late, very close to image restore.
> Still, it didn't work (It hung after the resume, in the kernel that was
> just restored, on access to the hardware lock, or in other words in same
> way)
>=20
> Here is what I did:

I saw the patch in the bug entry
(http://bugzilla.kernel.org/show_bug.cgi?id=3D14668).
Please see the comments in there.

Please also test the patch I attached and let's use the bug entry for the
tracking of this issue from now on.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
