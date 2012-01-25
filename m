Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 2847B6B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 18:07:48 -0500 (EST)
Received: by qadc11 with SMTP id c11so1346744qad.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 15:07:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120124084335.GE26289@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117164605.GB22142@tiehlicka.suse.cz>
	<20120118091226.b46e0f6e.kamezawa.hiroyu@jp.fujitsu.com>
	<20120118104703.GA31112@tiehlicka.suse.cz>
	<20120119085309.616cadb4.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4ixAT411PZMwngh17V8VZEDGbMNNzbWFwbpC5M-JO+TVOQ@mail.gmail.com>
	<20120124084335.GE26289@tiehlicka.suse.cz>
Date: Wed, 25 Jan 2012 15:07:47 -0800
Message-ID: <CALWz4iy0ajriTk7V0xL1+W7rDFS+-M5w4OdPjasMGUTH=ZLgrw@mail.gmail.com>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from pc->flags
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Tue, Jan 24, 2012 at 12:43 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 23-01-12 14:05:33, Ying Han wrote:
>> On Wed, Jan 18, 2012 at 3:53 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Wed, 18 Jan 2012 11:47:03 +0100
>> > Michal Hocko <mhocko@suse.cz> wrote:
>> >
>> >> On Wed 18-01-12 09:12:26, KAMEZAWA Hiroyuki wrote:
>> >> > On Tue, 17 Jan 2012 17:46:05 +0100
>> >> > Michal Hocko <mhocko@suse.cz> wrote:
>> >> >
>> >> > > On Fri 13-01-12 17:40:19, KAMEZAWA Hiroyuki wrote:
>> >> [...]
>> >> > > > This patch removes PCG_MOVE_LOCK and add hashed rwlock array
>> >> > > > instead of it. This works well enough. Even when we need to
>> >> > > > take the lock,
>> >> > >
>> >> > > Hmmm, rwlocks are not popular these days very much.
>> >> > > Anyway, can we rather make it (source) memcg (bit)spinlock instea=
d. We
>> >> > > would reduce false sharing this way and would penalize only pages=
 from
>> >> > > the moving group.
>> >> > >
>> >> > per-memcg spinlock ?
>> >>
>> >> Yes
>> >>
>> >> > The reason I used rwlock() is to avoid disabling IRQ. =A0This routi=
ne
>> >> > will be called by IRQ context (for dirty ratio support). =A0So, IRQ
>> >> > disable will be required if we use spinlock.
>> >>
>> >> OK, I have missed the comment about disabling IRQs. It's true that we=
 do
>> >> not have to be afraid about deadlocks if the lock is held only for
>> >> reading from the irq context but does the spinlock makes a performanc=
e
>> >> bottleneck? We are talking about the slowpath.
>> >> I could see the reason for the read lock when doing hashed locks beca=
use
>> >> they are global but if we make the lock per memcg then we shouldn't
>> >> interfere with other updates which are not blocked by the move.
>> >>
>> >
>> > Hm, ok. In the next version, I'll use per-memcg spinlock (with hash if=
 necessary)
>>
>> Just want to make sure I understand it, even we make the lock
>> per-memcg, there is still a false sharing of pc within one memcg.
>
> Yes that is true. I have missed that we might fault in several pages at
> once but this would happen only during task move, right? And that is not
> a hot path anyway. Or?

I was thinking of page-statistics update which is hot path. If the
moving task and non-moving task share the same per-memcg lock, any
page-statistic update from the non-moving task will be blocked? Sorry
If i missed something here :)

>
>> Do we need to demonstrate the effect ?
>>
>> Also, I don't get the point of why spinlock instead of rwlock in this ca=
se?
>
> spinlock provides a fairness while with rwlocks might lead to
> starvation.

that is true.

--Ying

>
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
