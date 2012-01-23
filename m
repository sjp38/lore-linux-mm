Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 2C1CD6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 17:05:35 -0500 (EST)
Received: by qcsg1 with SMTP id g1so853611qcs.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:05:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120119085309.616cadb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117164605.GB22142@tiehlicka.suse.cz>
	<20120118091226.b46e0f6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118104703.GA31112@tiehlicka.suse.cz>
	<20120119085309.616cadb4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 Jan 2012 14:05:33 -0800
Message-ID: <CALWz4ixAT411PZMwngh17V8VZEDGbMNNzbWFwbpC5M-JO+TVOQ@mail.gmail.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from pc->flags
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Wed, Jan 18, 2012 at 3:53 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 18 Jan 2012 11:47:03 +0100
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Wed 18-01-12 09:12:26, KAMEZAWA Hiroyuki wrote:
>> > On Tue, 17 Jan 2012 17:46:05 +0100
>> > Michal Hocko <mhocko@suse.cz> wrote:
>> >
>> > > On Fri 13-01-12 17:40:19, KAMEZAWA Hiroyuki wrote:
>> [...]
>> > > > This patch removes PCG_MOVE_LOCK and add hashed rwlock array
>> > > > instead of it. This works well enough. Even when we need to
>> > > > take the lock,
>> > >
>> > > Hmmm, rwlocks are not popular these days very much.
>> > > Anyway, can we rather make it (source) memcg (bit)spinlock instead. =
We
>> > > would reduce false sharing this way and would penalize only pages fr=
om
>> > > the moving group.
>> > >
>> > per-memcg spinlock ?
>>
>> Yes
>>
>> > The reason I used rwlock() is to avoid disabling IRQ. =A0This routine
>> > will be called by IRQ context (for dirty ratio support). =A0So, IRQ
>> > disable will be required if we use spinlock.
>>
>> OK, I have missed the comment about disabling IRQs. It's true that we do
>> not have to be afraid about deadlocks if the lock is held only for
>> reading from the irq context but does the spinlock makes a performance
>> bottleneck? We are talking about the slowpath.
>> I could see the reason for the read lock when doing hashed locks because
>> they are global but if we make the lock per memcg then we shouldn't
>> interfere with other updates which are not blocked by the move.
>>
>
> Hm, ok. In the next version, I'll use per-memcg spinlock (with hash if ne=
cessary)

Just want to make sure I understand it, even we make the lock
per-memcg, there is still a false sharing of pc within one memcg. Do
we need to demonstrate the effect ?

Also, I don't get the point of why spinlock instead of rwlock in this case?

--Ying

>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
