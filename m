Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AFE716B0248
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 06:49:45 -0400 (EDT)
Subject: Re: FYI: mmap_sem OOM patch
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTimLSnNot2byTWYuIHE8rhGLXbl1zKsQQhmci1Do@mail.gmail.com>
References: <20100707231134.GA26555@google.com>
	 <1278585009.1900.31.camel@laptop>
	 <AANLkTimLSnNot2byTWYuIHE8rhGLXbl1zKsQQhmci1Do@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 08 Jul 2010 12:49:33 +0200
Message-ID: <1278586173.1900.50.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Divyesh Shah <dpshah@google.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-07-08 at 03:39 -0700, Michel Lespinasse wrote:
>=20
>=20
>         One way to fix this is to have T4 wake from the oom queue and ret=
urn an
>         allocation failure instead of insisting on going oom itself when =
T1
>         decides to take down the task.
>=20
> How would you have T4 figure out the deadlock situation ? T1 is taking do=
wn T2, not T4...=20

If T2 and T4 share a mmap_sem they belong to the same process. OOM takes
down the whole process by sending around signals of sorts (SIGKILL?), so
if T4 gets a fatal signal while it is waiting to enter the oom thingy,
have it abort and return an allocation failure.

That alloc failure (along with a pending fatal signal) will very likely
lead to the release of its mmap_sem (if not, there's more things to
cure).

At which point the cycle is broken an stuff continues as it was
intended.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
