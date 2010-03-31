Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9D17B6B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:48:28 -0400 (EDT)
Received: by pwi2 with SMTP id 2so4788509pwi.14
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:48:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100331111202.a94b233a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100316170808.GA29400@redhat.com>
	 <20100330135634.09e6b045.akpm@linux-foundation.org>
	 <20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100330173721.cbd442cb.akpm@linux-foundation.org>
	 <20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
	 <z2t28c262361003301857l77db88dbv7d025b5c5947ad72@mail.gmail.com>
	 <20100331111202.a94b233a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 31 Mar 2010 11:48:20 +0900
Message-ID: <z2z28c262361003301948h64378b8bkbbd29ed810862ce5@mail.gmail.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 11:12 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 31 Mar 2010 10:57:18 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Mar 31, 2010 at 9:41 AM, KAMEZAWA Hiroyuki
>
>> > Doesn't make sense ?
>> >
>>
>> Nitpick.
>> How about moving sync_mm_rss into after check !mm of exit_mm?
>>
> Hmm.
> =3D=3D
> =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_mm_rss(tsk, tsk->mm);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0group_dead =3D atomic_dec_and_test(&tsk->signa=
l->live);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (group_dead) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hrtimer_cancel(&ts=
k->signal->real_timer);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exit_itimers(tsk->=
signal);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (tsk->mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0setmax_mm_hiwater_rss(&tsk->signal->maxrss, tsk->mm); ---(**)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0acct_collect(code, group_dead);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (group_dead)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tty_audit_exit();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(tsk->audit_context))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0audit_free(tsk);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tsk->exit_code =3D code;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0taskstats_exit(tsk, group_dead); --------(*)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0exit_mm(tsk);
> =3D=3D
> task_acct routine has to handle mm information (*).

Indeed. I missed that.
Thanks, Kame.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
