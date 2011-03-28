Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 767B98D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 03:00:56 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9F3363EE0BC
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:00:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 894B445DE94
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:00:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7247645DE93
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:00:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64716E08001
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:00:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FAC8E08003
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:00:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] x86,mm: make pagefault killable
In-Reply-To: <AANLkTinsabm-AHTdc2X550jkAqb=TrBLfrk5CV-WEjGx@mail.gmail.com>
References: <20110324171319.GA20182@redhat.com> <AANLkTinsabm-AHTdc2X550jkAqb=TrBLfrk5CV-WEjGx@mail.gmail.com>
Message-Id: <20110328160125.F06F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 28 Mar 2011 16:00:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Thu, Mar 24, 2011 at 10:13 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > I am wondering, can't we set FAULT_FLAG_KILLABLE unconditionally
> > but check PF_USER when we get VM_FAULT_RETRY? I mean,
> >
> > =A0 =A0 =A0 =A0if ((fault & VM_FAULT_RETRY) && fatal_signal_pending(cur=
rent)) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(error_code & PF_USER))
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0no_context(...);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> > =A0 =A0 =A0 =A0}
>=20
> I agree, we should do this.
>=20
> > Probably not... but I can't find any example of in-kernel fault which
> > can be broken by -EFAULT if current was killed.
>=20
> There's no way that can validly break anything, since any such
> codepath has to be able to handle -EFAULT for other reasons anyway.
>=20
> The only issue is whether we're ok with a regular write() system call
> (for example) not being atomic in the presence of a fatal signal. So
> it does change semantics, but I think it changes it in a good way
> (technically POSIX requires atomicity, but on the other hand,
> technically POSIX also doesn't talk about the process being killed,
> and writes would still be atomic for the case where they actually
> return. Not to mention NFS etc where writes have never been atomic
> anyway, so a program that relies on strict "all or nothing" write
> behavior is fundamentally broken to begin with).

Ok, I didn't have enough brave. Will do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
