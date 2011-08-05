Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A25DC6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 22:36:37 -0400 (EDT)
Received: by qwa26 with SMTP id 26so311162qwa.14
        for <linux-mm@kvack.org>; Thu, 04 Aug 2011 19:36:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <876efe5f-7222-4c67-aa3f-0c6e4272f5e1@default>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
	<1312427390-20005-2-git-send-email-lliubbo@gmail.com>
	<20110804075730.GF31039@tiehlicka.suse.cz>
	<20110804090017.GI31039@tiehlicka.suse.cz>
	<876efe5f-7222-4c67-aa3f-0c6e4272f5e1@default>
Date: Fri, 5 Aug 2011 10:36:34 +0800
Message-ID: <CAA_GA1f8B9uPszGecYd=DiuAOCqo0AXkFca_=5jEGRczGia5ZA@mail.gmail.com>
Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

On Fri, Aug 5, 2011 at 12:47 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
>> From: Michal Hocko [mailto:mhocko@suse.cz]
>> Sent: Thursday, August 04, 2011 3:00 AM
>> Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
>>
>> On Thu 04-08-11 10:14:07, Johannes Weiner wrote:
>> > On Thu, Aug 04, 2011 at 09:57:30AM +0200, Michal Hocko wrote:
>> > > On Thu 04-08-11 11:09:48, Bob Liu wrote:
>> > > > This patch also add checking whether alloc frontswap_map memory
>> > > > failed.
>> > > >
>> > > > Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> > > > ---
>> > > > =C2=A0mm/swapfile.c | =C2=A0 =C2=A06 +++---
>> > > > =C2=A01 files changed, 3 insertions(+), 3 deletions(-)
>> > > >
>> > > > diff --git a/mm/swapfile.c b/mm/swapfile.c
>> > > > index ffdd06a..8fe9e88 100644
>> > > > --- a/mm/swapfile.c
>> > > > +++ b/mm/swapfile.c
>> > > > @@ -2124,9 +2124,9 @@ SYSCALL_DEFINE2(swapon, const char __user *,=
 specialfile, int, swap_flags)
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* frontswap enabled? set up bit-per-p=
age map for frontswap */
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (frontswap_enabled) {
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 frontswap_map =
=3D vmalloc(maxpages / sizeof(long));
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (frontswap_m=
ap)
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 memset(frontswap_map, 0, maxpages / sizeof(long));
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 frontswap_map =
=3D vzalloc(maxpages / sizeof(long));
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!frontswap_=
map)
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 goto bad_swap;
>> > >
>> > > vzalloc part looks good but shouldn't we disable frontswap rather th=
an
>> > > fail?
>> >
>> > Silently dropping explicitely enabled features is not a good idea,
>> > IMO.
>>
>> Sure, I didn't mean silently. It should be a big fat warning that there
>> is not enough memory to enable the feature.
>>
>> > But from a quick look, this seems to be actually happening as
>> > frontswap's bitmap tests check for whether there is even a bitmap
>> > allocated and it should essentially never do anything for real if
>> > there isn't.
>>
>> Yes, that was my impression as well. I wasn't 100% sure about that
>> though, because there are many places which check frontswap_enabled and
>> do not check the map. I though that disabling the feature should be
>> safer.
>>
>> > How about printing a warning as to why the swapon fails and give the
>> > admin a choice to disable it on her own?
>>
>> I am not that familiar with the code but drivers/staging/zcache/zcache.c
>> says:
>> /*
>> =C2=A0* zcache initialization
>> =C2=A0* NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER =
OR
>> =C2=A0* NOTHING HAPPENS!
>> =C2=A0*/
>>
>> Is there something admin can do about it?
>>
>> >
>> > It's outside this patch's scope, though, just as changing the
>> > behaviour to fail swapon is.
>>
>> Agreed. The patch should just use vzalloc and the allocation failure
>> should be handled separately - if needed at all.
>
> Agreed here too. =C2=A0The frontswap_enabled flag is global (enabling fro=
ntswap
> across all frontswap devices) whereas failure to allocate the frontswap_m=
ap
> will disable frontswap for only one swap device. =C2=A0And since frontswa=
p is
> strictly a performance enhancement, there's no reason to fail the swapon
> for the entire swap device.
>

Agreed.

> I am fairly sure that the failed allocation is handled gracefully
> through the remainder of the frontswap code, but will re-audit to
> confirm. =C2=A0A warning might be nice though.
>

There is a place i think maybe have problem.
function __frontswap_flush_area() in file frontswap.c called
memset(sis->frontswap_map, .., ..);
But if frontswap_map allocation fail there is a null pointer access ?

> In any case:
>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 frontswap_map =3D vmalloc(ma=
xpages / sizeof(long));
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (frontswap_map)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
memset(frontswap_map, 0, maxpages / sizeof(long));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 frontswap_map =3D vzalloc(ma=
xpages / sizeof(long));
>
> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>

Thanks,

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!frontswap_map)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto bad_swap;
>
> NAK
>
> Dan
>
> Thanks... for the memory!
> I really could use more / my throughput's on the floor
> The balloon is flat / my swap disk's fat / I've OOM's in store
> Overcommitted so much
> (with apologies to Bob Hope)
>

:)

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
