Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E58536B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 22:23:41 -0400 (EDT)
Received: by qyk2 with SMTP id 2so3337525qyk.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 19:23:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110512105351.a57970d7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
	<20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=ya1rAqC+nMPHkBaMsoXpsCeHH=w@mail.gmail.com>
	<20110512105351.a57970d7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 May 2011 11:23:38 +0900
Message-ID: <BANLkTimWOtKKj+Jq1vqHfOfQ2UvP7Xxa3g@mail.gmail.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Thu, May 12, 2011 at 10:53 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 12 May 2011 10:30:45 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi Kame,
>>
>> On Thu, May 12, 2011 at 9:52 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Tue, 10 May 2011 17:15:01 +0900 (JST)
>> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> >
>> >> This patch introduces do_each_thread_reverse() and
>> >> select_bad_process() uses it. The benefits are two,
>> >> 1) oom-killer can kill younger process than older if
>> >> they have a same oom score. Usually younger process
>> >> is less important. 2) younger task often have PF_EXITING
>> >> because shell script makes a lot of short lived processes.
>> >> Reverse order search can detect it faster.
>> >>
>> >> Reported-by: CAI Qian <caiqian@redhat.com>
>> >> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> >
>> > IIUC, for_each_thread() can be called under rcu_read_lock() but
>> > for_each_thread_reverse() must be under tasklist_lock.
>>
>> Just out of curiosity.
>> You mentioned it when I sent forkbomb killer patch. :)
>> From at that time, I can't understand why we need holding
>> tasklist_lock not rcu_read_lock. Sorry for the dumb question.
>>
>> At present, it seems that someone uses tasklist_lock and others uses
>> rcu_read_lock. But I can't find any rule for that.
>>
>
> for_each_list_rcu() makes use of RCU list's characteristics and allows
> walk a list under rcu_read_lock() without taking any atomic locks.
>
> list_del() of RCU list works as folllowing.
>
> =3D=3D
> =C2=A01) assume =C2=A0A, B, C, are linked in the list.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(head)<->(A) <-> (B) =C2=A0<-> (C)
>
> =C2=A02) remove B.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(head)<->(A) <-> (C)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (B)
>
> =C2=A0Because (B)'s next points to (C) even after (B) is removed, (B)->ne=
xt
> =C2=A0points to the alive object. Even if (C) is removed at the same time=
,
> =C2=A0(C) is not freed until rcu glace period and (C)'s next points to (h=
ead)
>
> Then, for_each_list_rcu() can work well under rcu_read_lock(), it will vi=
sit
> only alive objects (but may not be valid.)
>
> =3D=3D
>
> please see include/linux/rculist.h and check list_add_rcu() ;)
>
> As above implies, (B)->prev pointer is invalid pointer after list_del().
> So, there will be race with list modification and for_each_list_reverse u=
nder
> rcu_read__lock()
>
> So, when you need to take atomic lock (as tasklist lock is) is...
>
> =C2=A01) You can't check 'entry' is valid or not...
> =C2=A0 =C2=A0In above for_each_list_rcu(), you may visit an object which =
is under removing.
> =C2=A0 =C2=A0You need some flag or check to see the object is valid or no=
t.
>
> =C2=A02) you want to use list_for_each_safe().
> =C2=A0 =C2=A0You can't do list_del() an object which is under removing...
>
> =C2=A03) You want to walk the list in reverse.
>
> =C2=A03) Some other reasons. For example, you'll access an object pointed=
 by the
> =C2=A0 =C2=A0'entry' and the object is not rcu safe.
>
> make sense ?

Yes. Thanks, Kame.
It seems It is caused by prev poisoning of list_del_rcu.
If we remove it, isn't it possible to traverse reverse without atomic lock?



>
> Thanks,
> -Kame
>
>
>> Could you elaborate it, please?
>> Doesn't it need document about it?
>>
>> --
>> Kind regards,
>> Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom internet charges in Canada: sign http://stopthemete=
r.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
