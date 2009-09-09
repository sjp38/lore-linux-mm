Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F394E6B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 19:58:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n89NwNpK014558
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Sep 2009 08:58:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D47545DE4D
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:58:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1926E45DE4F
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:58:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C6397E08001
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:58:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EDCF61DB8043
	for <linux-mm@kvack.org>; Thu, 10 Sep 2009 08:58:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <28c262360909090839j626ff818of930cf13a6185123@mail.gmail.com>
References: <20090909131945.0CF5.A69D9226@jp.fujitsu.com> <28c262360909090839j626ff818of930cf13a6185123@mail.gmail.com>
Message-Id: <20090910084602.9CBD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 10 Sep 2009 08:58:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, Sep 9, 2009 at 1:27 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> The usefulness of a scheme like this requires:
> >>
> >> 1. There are cpus that continually execute user space code
> >> =A0 =A0without system interaction.
> >>
> >> 2. There are repeated VM activities that require page isolation /
> >> =A0 =A0migration.
> >>
> >> The first page isolation activity will then clear the lru caches of th=
e
> >> processes doing number crunching in user space (and therefore the firs=
t
> >> isolation will still interrupt). The second and following isolation wi=
ll
> >> then no longer interrupt the processes.
> >>
> >> 2. is rare. So the question is if the additional code in the LRU handl=
ing
> >> can be justified. If lru handling is not time sensitive then yes.
> >
> > Christoph, I'd like to discuss a bit related (and almost unrelated) thi=
ng.
> > I think page migration don't need lru_add_drain_all() as synchronous, b=
ecause
> > page migration have 10 times retry.
> >
> > Then asynchronous lru_add_drain_all() cause
> >
> > =A0- if system isn't under heavy pressure, retry succussfull.
> > =A0- if system is under heavy pressure or RT-thread work busy busy loop=
, retry failure.
> >
> > I don't think this is problematic bahavior. Also, mlock can use asynchr=
ounous lru drain.
>=20
> I think, more exactly, we don't have to drain lru pages for mlocking.
> Mlocked pages will go into unevictable lru due to
> try_to_unmap when shrink of lru happens.

Right.

> How about removing draining in case of mlock?

Umm, I don't like this. because perfectly no drain often make strange test =
result.
I mean /proc/meminfo::Mlock might be displayed unexpected value. it is not =
leak. it's only lazy cull.
but many tester and administrator wiill think it's bug... ;)

Practically, lru_add_drain_all() is nearly zero cost. because mlock's page =
fault is very
costly operation. it hide drain cost. now, we only want to treat corner cas=
e issue.=20
I don't hope dramatic change.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
