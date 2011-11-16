Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1049D6B0074
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 17:07:16 -0500 (EST)
Received: by bke17 with SMTP id 17so1571758bke.14
        for <linux-mm@kvack.org>; Wed, 16 Nov 2011 14:07:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com>
References: <20111114140421.GA27150@suse.de>
	<CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
	<20111115173656.GJ27150@suse.de>
	<20111116002235.GA10958@barrios-laptop.redhat.com>
	<CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
	<20111116004516.GA13028@barrios-laptop.redhat.com>
	<alpine.LFD.2.02.1111160908310.2446@tux.localdomain>
	<alpine.DEB.2.00.1111161340010.16596@chino.kir.corp.google.com>
Date: Thu, 17 Nov 2011 07:07:13 +0900
Message-ID: <CABin3AGpQbt6i56a5+rh=qJC+vC-x4VkhJwsfJczMyGsSH31TA@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Minchan Kim <barrioskmc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Colin Cross <ccross@android.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Thu, Nov 17, 2011 at 6:44 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 16 Nov 2011, Pekka Enberg wrote:
>
>> > diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
>> > index fdd4263..01aa9b5 100644
>> > --- a/kernel/power/suspend.c
>> > +++ b/kernel/power/suspend.c
>> > @@ -297,9 +297,11 @@ int enter_state(suspend_state_t state)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto Finish;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_debug("PM: Entering %s sleep\n", pm_stat=
es[state]);
>> > + =C2=A0 =C2=A0 =C2=A0 oom_killer_disable();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pm_restrict_gfp_mask();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D suspend_devices_and_enter(state);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pm_restore_gfp_mask();
>> > + =C2=A0 =C2=A0 =C2=A0 oom_killer_enable();
>> >
>> > =C2=A0Finish:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_debug("PM: Finishing wakeup.\n");
>> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> > index 6e8ecb6..d8c31b7 100644
>> > --- a/mm/page_alloc.c
>> > +++ b/mm/page_alloc.c
>> > @@ -2177,9 +2177,9 @@ rebalance:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 * running out of options and have to consi=
der going OOM
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!did_some_progress) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((gfp_mask & __G=
FP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (oom_killer_disabled)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (oom_killer_disa=
bled)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto nopage;
>
> You're allowing __GFP_NOFAIL allocations to fail.
>
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((gfp_mask & __G=
FP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0page =3D __alloc_pages_may_oom(gfp_mask, order,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zoneli=
st, high_zoneidx,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nodema=
sk, preferred_zone,
>> >
>>
>> I'd prefer something like this. The whole 'gfp_allowed_flags' thing was
>> designed to make GFP_KERNEL work during boot time where it's obviously s=
afe to
>> do that. I really don't think that's going to work suspend cleanly.
>>
>
> Adding Rafael to the cc.
>
> This has been done since 2.6.34 and presumably has been working quite
> well. =C2=A0I don't have a specific objection to gfp_allowed_flags to be =
used
> outside of boot since it seems plausible that there are system-level
> contexts that would need different behavior in the page allocator and thi=
s
> does it effectively without major surgery or a slower fastpath. =C2=A0Sus=
pend
> is using it just like boot does before irqs are enabled, so I don't have
> an objection to it.
>

My point isn't using gfp_allowed_flags(maybe it's Pekka's concern) but
why adding new special case handling code like pm_suspended_storage.
I think we can handle the issue with oom_killer_disabled(but the naming is =
bad)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
