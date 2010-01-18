Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 522C56B006A
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 22:23:14 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0I3NBen014368
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 18 Jan 2010 12:23:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F201D45DE6F
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:23:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D1A5C45DD74
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:23:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B892D1DB8037
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:23:10 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 55FB31DB803A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 12:23:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
In-Reply-To: <6feea4871001141130j4184a24di363b7e6553d506e8@mail.gmail.com>
References: <20100114170247.6747.A69D9226@jp.fujitsu.com> <6feea4871001141130j4184a24di363b7e6553d506e8@mail.gmail.com>
Message-Id: <20100118121726.AE45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Jan 2010 12:23:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Andrew C. Morrow" <andrew.c.morrow@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Gleb Natapov <gleb@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Thu, Jan 14, 2010 at 3:17 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > Hmm..
> >> > Your answer didn't match I wanted.
> >> Then I don't get what you want.
> >
> > I want to know the benefit of the patch for patch reviewing.
> >
>=20
> The benefit of the patch is that it makes it possible for an
> application which has previously called mlockall(MCL_FUTURE) to
> selectively exempt new memory mappings from memory locking, on a
> per-mmap-call basis. As was pointed out earlier, there is currently no
> thread-safe way for an application to do this. The earlier proposed
> workaround of toggling MCL_FUTURE around calls to mmap is racy in a
> multi-threaded context. Other threads may manipulate the address space
> during the window where MCL_FUTURE is off, subverting the programmers
> intended memory locking semantics.
>=20
> The ability to exempt specific memory mappings from memory locking is
> necessary when the region to be mapped is larger than physical memory.
> In such cases a call to mmap the region cannot succeed, unless
> MAP_UNLOCKED is available.
>=20
>=20
> >
> >> > few additional questions.
> >> >
> >> > - Why don't you change your application? It seems natural way than k=
ernel change.
> >> There is no way to change my application and achieve what I've describ=
ed
> >> in a multithreaded app.
> >
> > Then, we don't recommend to use mlockall(). I don't hope to hear your c=
onclusion,
> > it is not objectivization. I hope to hear why you reached such conclusi=
on.
> >
>=20
> I agree that mlockall is a big hammer and should be avoided in most
> cases, but there are situations where it is exactly what is needed. In
> Gleb's instance, it sounds like he is doing some finicky performance
> measurement and major page faults skew his results. In my case, I have
> a realtime process where the measured latency impact of major page
> faults is unacceptable. In both of these cases, mlockall is a
> reasonable approach to eliminating major faults.
>=20
> However, Gleb and I have independently found ourselves unable to use
> mlockall because we also need to create a very large memory mapping
> (for which we don't care about major faults). The proposed
> MAP_UNLOCKED flag would allow us to override MCL_FUTURE for that one
> mapping.
>=20
> >
> >> > - Why do you want your virtual machine have mlockall? AFAIK, current=
 majority
> >> > =A0 virtual machine doesn't.
> >> It is absolutely irrelevant for that patch, but just because you ask I
> >> want to measure the cost of swapping out of a guest memory.
> >
> > No. if you stop to use mlockall, the issue is vanished.
> >
>=20
> And other issues arise. Gleb described a situation where the use of
> mlockall is justified, identified an issue which prevents its use, and
> provided a patch which resolves that issue. Why are you focusing on
> the validity of using mlockall?
>=20
> >
> >> > - If this feature added, average distro user can get any benefit?
> >> >
> >> ?! Is this some kind of new measure? There are plenty of much more
> >> invasive features that don't bring benefits to an average distro user.
> >> This feature can bring benefit to embedded/RT developers.
> >
> > I mean who get benifit?
> >
> >
> >> > I mean, many application developrs want to add their specific featur=
e
> >> > into kernel. but if we allow it unlimitedly, major syscall become
> >> > the trushbox of pretty toy feature soon.
> >> >
> >> And if application developer wants to extend kernel in a way that it
> >> will be possible to do something that was not possible before why is
> >> this a bad thing? I would agree with you if for my problem was userspa=
ce
> >> solution, but there is none. The mmap interface is asymmetric in regar=
ds
> >> to mlock currently. There is MAP_LOCKED, but no MAP_UNLOCKED. Why
> >> MAP_LOCKED is useful then?
> >
> > Why? Because this is formal LKML reviewing process. I'm reviewing your
> > patch for YOU.
> >
> > If there is no objective reason, I don't want to continue reviewing.
> >
>=20
> There is an objective reason: the current interaction between
> mlockall(MCL_FUTURE) and mmap has a deficiency. In 'normal' mode,
> without MCL_FUTURE in force, the default is that new memory mappings
> are not locked, but mmap provides MAP_LOCKED specifically to override
> that default. However, with MCL_FUTURE toggled to on, there is no
> analogous way to tell mmap to override the default. The proposed
> MAP_UNLOCKED flag would resolve this deficiency.

Very thank you, Andrew!

Your explanation help me lots rather than original patch description. OK, A=
t least
MAP_UNLOCED have two users (you and gleb) and your explanation seems
makes sense.

So, if gleb resend this patch with rewrited description, I might take my re=
viewed-by tag to it, probagly.


Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
