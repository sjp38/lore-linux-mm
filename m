Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F30DA6B00D4
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:11:08 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2190749iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:11:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019121321.A1E1.A69D9226@jp.fujitsu.com>
References: <20101019030515.GB11924@localhost>
	<AANLkTinvcGjF2-dvu8kpDY4V7kGkRJjHTWDtQPNRKMU_@mail.gmail.com>
	<20101019121321.A1E1.A69D9226@jp.fujitsu.com>
Date: Tue, 19 Oct 2010 14:11:07 +0900
Message-ID: <AANLkTi=Akuku=Sz7kw0JRB-bzP8cmirbX4XJ8qyVqmze@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 12:13 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Tue, Oct 19, 2010 at 12:05 PM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>> > On Tue, Oct 19, 2010 at 10:52:47AM +0800, Minchan Kim wrote:
>> >> Hi Wu,
>> >>
>> >> On Tue, Oct 19, 2010 at 11:35 AM, Wu Fengguang <fengguang.wu@intel.co=
m> wrote:
>> >> >> @@ -2054,10 +2069,11 @@ rebalance:
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_pg;
>> >> >>
>> >> >> =A0 =A0 =A0 =A0 /*
>> >> >> - =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming, t=
hen we are
>> >> >> - =A0 =A0 =A0 =A0* running out of options and have to consider goi=
ng OOM
>> >> >> + =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming an=
d there aren't
>> >> >> + =A0 =A0 =A0 =A0* many parallel reclaiming, then we are unning ou=
t of options and
>> >> >> + =A0 =A0 =A0 =A0* have to consider going OOM
>> >> >> =A0 =A0 =A0 =A0 =A0*/
>> >> >> - =A0 =A0 =A0 if (!did_some_progress) {
>> >> >> + =A0 =A0 =A0 if (!did_some_progress && !too_many_isolated_zone(pr=
eferred_zone)) {
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((gfp_mask & __GFP_FS) && !(gfp=
_mask & __GFP_NORETRY)) {
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (oom_killer_dis=
abled)
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 go=
to nopage;
>> >> >
>> >> > This is simply wrong.
>> >> >
>> >> > It disabled this block for 99% system because there won't be enough
>> >> > tasks to make (!too_many_isolated_zone =3D=3D true). As a result th=
e LRU
>> >> > will be scanned like mad and no task get OOMed when it should be.
>> >>
>> >> If !too_many_isolated_zone is false, it means there are already many
>> >> direct reclaiming tasks.
>> >> So they could exit reclaim path and !too_many_isolated_zone will be t=
rue.
>> >> What am I missing now?
>> >
>> > Ah sorry, my brain get short circuited.. but I still feel uneasy with
>> > this change. It's not fixing the root cause and won't prevent too many
>> > LRU pages be isolated. It's too late to test too_many_isolated_zone()
>> > after direct reclaim returns (after sleeping for a long time).
>> >
>>
>> Intend to agree.
>> I think root cause is a infinite looping in too_many_isolated holding FS=
 lock.
>> Would it be simple that too_many_isolated would be bail out after some t=
ry?
>
> How?
> A lot of caller don't have good recover logic when memory allocation fail=
 occur.
>

I means following as.

1. shrink_inactive_list
2. if too_many_isolated is looping than 5 times, it marks some
variable to notice this fail is concurrent reclaim and bail out
3. __alloc_pages_slowpath see that did_some_progress is zero and the
mark which show bailout by concurrent reclaim.
4. Instead of OOM, congestion_wait and rebalance.

While I implement it, I knew it makes code rather ugly and I thought
lost is bigger than gain.

Okay. I will drop this idea.

Thanks for advising me, Wu, KOSAKI.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
