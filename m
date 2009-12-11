Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CCACB6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 20:25:05 -0500 (EST)
Received: by pwi1 with SMTP id 1so344271pwi.6
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 17:25:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091211095159.6472a009.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262360912101640y4b90db76w61a7a5dab5f8e796@mail.gmail.com>
	 <20091211095159.6472a009.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 10:25:03 +0900
Message-ID: <28c262360912101725ydb0a0d9i12a91c1d4fe57672@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, Dec 11, 2009 at 9:51 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 11 Dec 2009 09:40:07 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>> >=C2=A0static inline unsigned long get_mm_counter(struct mm_struct *mm, =
int member)
>> > =C2=A0{
>> > - =C2=A0 =C2=A0 =C2=A0 return (unsigned long)atomic_long_read(&(mm)->c=
ounters[member]);
>> > + =C2=A0 =C2=A0 =C2=A0 long ret;
>> > + =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Because this counter is loosely synchro=
nized with percpu cached
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* information, it's possible that value g=
ets to be minus. For user's
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* convenience/sanity, avoid returning min=
us.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 ret =3D atomic_long_read(&(mm)->counters[member=
]);
>> > + =C2=A0 =C2=A0 =C2=A0 if (unlikely(ret < 0))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> > + =C2=A0 =C2=A0 =C2=A0 return (unsigned long)ret;
>> > =C2=A0}
>>
>> Now, your sync point is only task switching time.
>> So we can't show exact number if many counting of mm happens
>> in short time.(ie, before context switching).
>> It isn't matter?
>>
> I think it's not a matter from 2 reasons.
>
> 1. Now, considering servers which requires continuous memory usage monito=
ring
> as ps/top, when there are 2000 processes, "ps -elf" takes 0.8sec.
> Because system admins know that gathering process information consumes
> some amount of cpu resource, they will not do that so frequently.(I hope)
>
> 2. When chains of page faults occur continously in a period, the monitor
> of memory usage just see a snapshot of current numbers and "snapshot of w=
hat
> moment" is at random, always. No one can get precise number in that kind =
of situation.
>

Yes. I understand that.

But we did rss updating as batch until now.
It was also stale. Just only your patch make stale period longer.
Hmm. I hope people don't expect mm count is precise.

I saw the many people believed sanpshot of mm counting is real in
embedded system.
They want to know the exact memory usage in system.
Maybe embedded system doesn't use SPLIT_LOCK so that there is no regression=
.

At least, I would like to add comment "It's not precise value." on
statm's Documentation.
Of course, It's off topic.  :)

Thanks for commenting. Kame.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
