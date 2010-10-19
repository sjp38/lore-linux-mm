Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 604976B00A5
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 03:34:36 -0400 (EDT)
Received: by ywa8 with SMTP id 8so222551ywa.14
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 00:34:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019071534.GA15105@sli10-conroe.sh.intel.com>
References: <20101019093142.509d6947@notabene>
	<20101018154137.90f5325f.akpm@linux-foundation.org>
	<20101019095144.A1B0.A69D9226@jp.fujitsu.com>
	<AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
	<20101019023537.GB8310@localhost>
	<AANLkTikHxDyjOGgM8-X6FNT15Hr3s4NaA-=+FRhma+3D@mail.gmail.com>
	<20101019030515.GB11924@localhost>
	<AANLkTinvcGjF2-dvu8kpDY4V7kGkRJjHTWDtQPNRKMU_@mail.gmail.com>
	<20101019032145.GA3108@sli10-conroe.sh.intel.com>
	<20101019071534.GA15105@sli10-conroe.sh.intel.com>
Date: Tue, 19 Oct 2010 16:34:32 +0900
Message-ID: <AANLkTimQzT3SYf0LMqEH8Bfta2gnvVjWCHRj=kmb_4Z7@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 4:15 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Tue, Oct 19, 2010 at 11:21:45AM +0800, Shaohua Li wrote:
>> On Tue, Oct 19, 2010 at 11:09:29AM +0800, Minchan Kim wrote:
>> > On Tue, Oct 19, 2010 at 12:05 PM, Wu Fengguang <fengguang.wu@intel.com=
> wrote:
>> > > On Tue, Oct 19, 2010 at 10:52:47AM +0800, Minchan Kim wrote:
>> > >> Hi Wu,
>> > >>
>> > >> On Tue, Oct 19, 2010 at 11:35 AM, Wu Fengguang <fengguang.wu@intel.=
com> wrote:
>> > >> >> @@ -2054,10 +2069,11 @@ rebalance:
>> > >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_pg;
>> > >> >>
>> > >> >> =A0 =A0 =A0 =A0 /*
>> > >> >> - =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming,=
 then we are
>> > >> >> - =A0 =A0 =A0 =A0* running out of options and have to consider g=
oing OOM
>> > >> >> + =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming =
and there aren't
>> > >> >> + =A0 =A0 =A0 =A0* many parallel reclaiming, then we are unning =
out of options and
>> > >> >> + =A0 =A0 =A0 =A0* have to consider going OOM
>> > >> >> =A0 =A0 =A0 =A0 =A0*/
>> > >> >> - =A0 =A0 =A0 if (!did_some_progress) {
>> > >> >> + =A0 =A0 =A0 if (!did_some_progress && !too_many_isolated_zone(=
preferred_zone)) {
>> > >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((gfp_mask & __GFP_FS) && !(g=
fp_mask & __GFP_NORETRY)) {
>> > >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (oom_killer_d=
isabled)
>> > >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
goto nopage;
>> > >> >
>> > >> > This is simply wrong.
>> > >> >
>> > >> > It disabled this block for 99% system because there won't be enou=
gh
>> > >> > tasks to make (!too_many_isolated_zone =3D=3D true). As a result =
the LRU
>> > >> > will be scanned like mad and no task get OOMed when it should be.
>> > >>
>> > >> If !too_many_isolated_zone is false, it means there are already man=
y
>> > >> direct reclaiming tasks.
>> > >> So they could exit reclaim path and !too_many_isolated_zone will be=
 true.
>> > >> What am I missing now?
>> > >
>> > > Ah sorry, my brain get short circuited.. but I still feel uneasy wit=
h
>> > > this change. It's not fixing the root cause and won't prevent too ma=
ny
>> > > LRU pages be isolated. It's too late to test too_many_isolated_zone(=
)
>> > > after direct reclaim returns (after sleeping for a long time).
>> > >
>> >
>> > Intend to agree.
>> > I think root cause is a infinite looping in too_many_isolated holding =
FS lock.
>> > Would it be simple that too_many_isolated would be bail out after some=
 try?
>> I'm wondering if we need too_many_isolated_zone logic. The do_try_to_fre=
e_pages
>> will return progress till all zones are unreclaimable. Assume before thi=
s we
>> don't oomkiller. If the direct reclaim fails but has progress, it will s=
leep.
> Not sure if this is clear. What I mean is we can delete too_many_isolated=
_zone,
> do_try_to_free_pages can still return 1 till all zones are unreclaimable.=
 Before
> this direct reclaim will not oom, because it sees progress and will call =
congestion_wait
> to sleep. Am I missing anything?
>

You mean could we remove too_many_isolated? not too_many_isolated_zone. Rig=
ht?
It it is, we can't.

Your saying is right.
do_try_to_free_pages can return 1 until all zones are unreclaimable.
But If we remove throttling logic which is too_many_isolated, too many
process can enter direct reclaim path and they can increase
zone->pages_scanned while zone_reclaimable pages are decreased by
isolation. At last, we could reach all zones are unreclaimable much
faster.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
