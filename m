Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB206B0172
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 12:50:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <876efe5f-7222-4c67-aa3f-0c6e4272f5e1@default>
Date: Thu, 4 Aug 2011 09:47:58 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <20110804075730.GF31039@tiehlicka.suse.cz>
 <20110804081407.GF21516@cmpxchg.org 20110804090017.GI31039@tiehlicka.suse.cz>
In-Reply-To: <20110804090017.GI31039@tiehlicka.suse.cz>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com

> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Thursday, August 04, 2011 3:00 AM
> Subject: Re: [PATCH 2/4] frontswap: using vzalloc instead of vmalloc
>=20
> On Thu 04-08-11 10:14:07, Johannes Weiner wrote:
> > On Thu, Aug 04, 2011 at 09:57:30AM +0200, Michal Hocko wrote:
> > > On Thu 04-08-11 11:09:48, Bob Liu wrote:
> > > > This patch also add checking whether alloc frontswap_map memory
> > > > failed.
> > > >
> > > > Signed-off-by: Bob Liu <lliubbo@gmail.com>
> > > > ---
> > > >  mm/swapfile.c |    6 +++---
> > > >  1 files changed, 3 insertions(+), 3 deletions(-)
> > > >
> > > > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > > > index ffdd06a..8fe9e88 100644
> > > > --- a/mm/swapfile.c
> > > > +++ b/mm/swapfile.c
> > > > @@ -2124,9 +2124,9 @@ SYSCALL_DEFINE2(swapon, const char __user *, =
specialfile, int, swap_flags)
> > > >  =09}
> > > >  =09/* frontswap enabled? set up bit-per-page map for frontswap */
> > > >  =09if (frontswap_enabled) {
> > > > -=09=09frontswap_map =3D vmalloc(maxpages / sizeof(long));
> > > > -=09=09if (frontswap_map)
> > > > -=09=09=09memset(frontswap_map, 0, maxpages / sizeof(long));
> > > > +=09=09frontswap_map =3D vzalloc(maxpages / sizeof(long));
> > > > +=09=09if (!frontswap_map)
> > > > +=09=09=09goto bad_swap;
> > >
> > > vzalloc part looks good but shouldn't we disable frontswap rather tha=
n
> > > fail?
> >
> > Silently dropping explicitely enabled features is not a good idea,
> > IMO.
>=20
> Sure, I didn't mean silently. It should be a big fat warning that there
> is not enough memory to enable the feature.
>=20
> > But from a quick look, this seems to be actually happening as
> > frontswap's bitmap tests check for whether there is even a bitmap
> > allocated and it should essentially never do anything for real if
> > there isn't.
>=20
> Yes, that was my impression as well. I wasn't 100% sure about that
> though, because there are many places which check frontswap_enabled and
> do not check the map. I though that disabling the feature should be
> safer.
>=20
> > How about printing a warning as to why the swapon fails and give the
> > admin a choice to disable it on her own?
>=20
> I am not that familiar with the code but drivers/staging/zcache/zcache.c
> says:
> /*
>  * zcache initialization
>  * NOTE FOR NOW zcache MUST BE PROVIDED AS A KERNEL BOOT PARAMETER OR
>  * NOTHING HAPPENS!
>  */
>=20
> Is there something admin can do about it?
>=20
> >
> > It's outside this patch's scope, though, just as changing the
> > behaviour to fail swapon is.
>=20
> Agreed. The patch should just use vzalloc and the allocation failure
> should be handled separately - if needed at all.

Agreed here too.  The frontswap_enabled flag is global (enabling frontswap
across all frontswap devices) whereas failure to allocate the frontswap_map
will disable frontswap for only one swap device.  And since frontswap is
strictly a performance enhancement, there's no reason to fail the swapon
for the entire swap device.

I am fairly sure that the failed allocation is handled gracefully
through the remainder of the frontswap code, but will re-audit to
confirm.  A warning might be nice though.

In any case:

> -=09=09frontswap_map =3D vmalloc(maxpages / sizeof(long));
> -=09=09if (frontswap_map)
> -=09=09=09memset(frontswap_map, 0, maxpages / sizeof(long));
> +=09=09frontswap_map =3D vzalloc(maxpages / sizeof(long));

Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

> +=09=09if (!frontswap_map)
> +=09=09=09goto bad_swap;

NAK

Dan

Thanks... for the memory!
I really could use more / my throughput's on the floor
The balloon is flat / my swap disk's fat / I've OOM's in store
Overcommitted so much
(with apologies to Bob Hope)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
