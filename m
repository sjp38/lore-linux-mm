Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A47466B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 08:40:25 -0500 (EST)
Date: Mon, 18 Jan 2010 15:40:19 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
Message-ID: <20100118134019.GH30698@redhat.com>
References: <20100114170247.6747.A69D9226@jp.fujitsu.com>
 <6feea4871001141130j4184a24di363b7e6553d506e8@mail.gmail.com>
 <20100118121726.AE45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20100118121726.AE45.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Andrew C. Morrow" <andrew.c.morrow@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 12:23:09PM +0900, KOSAKI Motohiro wrote:
> > On Thu, Jan 14, 2010 at 3:17 AM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > >> > Hmm..
> > >> > Your answer didn't match I wanted.
> > >> Then I don't get what you want.
> > >
> > > I want to know the benefit of the patch for patch reviewing.
> > >
> >=20
> > The benefit of the patch is that it makes it possible for an
> > application which has previously called mlockall(MCL_FUTURE) to
> > selectively exempt new memory mappings from memory locking, on a
> > per-mmap-call basis. As was pointed out earlier, there is currently no
> > thread-safe way for an application to do this. The earlier proposed
> > workaround of toggling MCL_FUTURE around calls to mmap is racy in a
> > multi-threaded context. Other threads may manipulate the address space
> > during the window where MCL_FUTURE is off, subverting the programmers
> > intended memory locking semantics.
> >=20
> > The ability to exempt specific memory mappings from memory locking is
> > necessary when the region to be mapped is larger than physical memory.
> > In such cases a call to mmap the region cannot succeed, unless
> > MAP_UNLOCKED is available.
> >=20
> >=20
> > >
> > >> > few additional questions.
> > >> >
> > >> > - Why don't you change your application? It seems natural way than=
 kernel change.
> > >> There is no way to change my application and achieve what I've descr=
ibed
> > >> in a multithreaded app.
> > >
> > > Then, we don't recommend to use mlockall(). I don't hope to hear your=
 conclusion,
> > > it is not objectivization. I hope to hear why you reached such conclu=
sion.
> > >
> >=20
> > I agree that mlockall is a big hammer and should be avoided in most
> > cases, but there are situations where it is exactly what is needed. In
> > Gleb's instance, it sounds like he is doing some finicky performance
> > measurement and major page faults skew his results. In my case, I have
> > a realtime process where the measured latency impact of major page
> > faults is unacceptable. In both of these cases, mlockall is a
> > reasonable approach to eliminating major faults.
> >=20
> > However, Gleb and I have independently found ourselves unable to use
> > mlockall because we also need to create a very large memory mapping
> > (for which we don't care about major faults). The proposed
> > MAP_UNLOCKED flag would allow us to override MCL_FUTURE for that one
> > mapping.
> >=20
> > >
> > >> > - Why do you want your virtual machine have mlockall? AFAIK, curre=
nt majority
> > >> > =9A virtual machine doesn't.
> > >> It is absolutely irrelevant for that patch, but just because you ask=
 I
> > >> want to measure the cost of swapping out of a guest memory.
> > >
> > > No. if you stop to use mlockall, the issue is vanished.
> > >
> >=20
> > And other issues arise. Gleb described a situation where the use of
> > mlockall is justified, identified an issue which prevents its use, and
> > provided a patch which resolves that issue. Why are you focusing on
> > the validity of using mlockall?
> >=20
> > >
> > >> > - If this feature added, average distro user can get any benefit?
> > >> >
> > >> ?! Is this some kind of new measure? There are plenty of much more
> > >> invasive features that don't bring benefits to an average distro use=
r.
> > >> This feature can bring benefit to embedded/RT developers.
> > >
> > > I mean who get benifit?
> > >
> > >
> > >> > I mean, many application developrs want to add their specific feat=
ure
> > >> > into kernel. but if we allow it unlimitedly, major syscall become
> > >> > the trushbox of pretty toy feature soon.
> > >> >
> > >> And if application developer wants to extend kernel in a way that it
> > >> will be possible to do something that was not possible before why is
> > >> this a bad thing? I would agree with you if for my problem was users=
pace
> > >> solution, but there is none. The mmap interface is asymmetric in reg=
ards
> > >> to mlock currently. There is MAP_LOCKED, but no MAP_UNLOCKED. Why
> > >> MAP_LOCKED is useful then?
> > >
> > > Why? Because this is formal LKML reviewing process. I'm reviewing your
> > > patch for YOU.
> > >
> > > If there is no objective reason, I don't want to continue reviewing.
> > >
> >=20
> > There is an objective reason: the current interaction between
> > mlockall(MCL_FUTURE) and mmap has a deficiency. In 'normal' mode,
> > without MCL_FUTURE in force, the default is that new memory mappings
> > are not locked, but mmap provides MAP_LOCKED specifically to override
> > that default. However, with MCL_FUTURE toggled to on, there is no
> > analogous way to tell mmap to override the default. The proposed
> > MAP_UNLOCKED flag would resolve this deficiency.
>=20
> Very thank you, Andrew!
>=20
> Your explanation help me lots rather than original patch description. OK,=
 At least
> MAP_UNLOCED have two users (you and gleb) and your explanation seems
> makes sense.
>=20
> So, if gleb resend this patch with rewrited description, I might take my =
reviewed-by tag to it, probagly.
>=20
Just did it. I hope the commit message is OK with you now. Its text is
taken from this Andrew's mail. Thanks.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
