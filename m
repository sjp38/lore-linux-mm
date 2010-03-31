Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E2F046B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:53:02 -0400 (EDT)
Received: by pwi2 with SMTP id 2so4791537pwi.14
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:53:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100331102755.92a89ca5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100316170808.GA29400@redhat.com>
	 <20100330135634.09e6b045.akpm@linux-foundation.org>
	 <20100331092815.c8b9d89c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100330173721.cbd442cb.akpm@linux-foundation.org>
	 <20100331094124.43c49290.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100330182258.59813fe6.akpm@linux-foundation.org>
	 <20100331102755.92a89ca5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 31 Mar 2010 11:53:00 +0900
Message-ID: <n2m28c262361003301953iea82f541u227e7227a23702e@mail.gmail.com>
Subject: Re: [PATCH] exit: fix oops in sync_mm_rss
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Troels Liebe Bentsen <tlb@rapanden.dk>, linux-bluetooth@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 10:27 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 30 Mar 2010 18:22:58 -0400
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Wed, 31 Mar 2010 09:41:24 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp=
.fujitsu.com> wrote:
>>
>> > > With this fixed, the test for non-zero tsk->mm is't really needed in
>> > > do_exit(), is it? =C2=A0I guess it makes sense though - sync_mm_rss(=
) only
>> > > really works for kernel threads by luck..
>> >
>> > At first, I considered so, too. But I changed my mind to show
>> > "we know tsk->mm can be NULL here!" by code.
>> > Because __sync_mm_rss_stat() has BUG_ON(!mm), the code reader will thi=
nk
>> > tsk->mm shouldn't be NULL always.
>> >
>> > Doesn't make sense ?
>>
>> uh, not really ;)
>>
>>
>> I think we should do this too:
>>
>> --- a/mm/memory.c~exit-fix-oops-in-sync_mm_rss-fix
>> +++ a/mm/memory.c
>> @@ -131,7 +131,6 @@ static void __sync_task_rss_stat(struct
>>
>> =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < NR_MM_COUNTERS; i++) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (task->rss_stat.coun=
t[i]) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
BUG_ON(!mm);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 add_mm_counter(mm, i, task->rss_stat.count[i]);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 task->rss_stat.count[i] =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> _
>>
>> Because we just made sure it can't happen, and if it _does_ happen, the
>> oops will tell us the samme thing that the BUG_ON() would have.
>>
>
> Hmm, then, finaly..
> =3D=3D
>
> task->rss_stat wasn't initialized to 0 at copy_process().
> And __sync_task_rss_stat() should be static.
> removed BUG_ON(!mm) in __sync_task_rss_stat() for avoiding to show
> wrong information to code readers. Anyway, if !mm && task->rss_stat
> has some value, panic will happen.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
