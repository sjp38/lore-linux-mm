Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C260B6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:43:47 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC 1/3] /dev/low_mem_notify
Date: Wed, 18 Jan 2012 09:41:41 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
	<1326788038-29141-2-git-send-email-minchan@kernel.org>
	<CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
	<4F15A34F.40808@redhat.com>
	<alpine.LFD.2.02.1201172044310.15303@tux.localdomain>
	<84FF21A720B0874AA94B46D76DB98269045596AE@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
In-Reply-To: <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org
Cc: riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, mtosatti@redhat.com, akpm@linux-foundation.org, rhod@redhat.com, kosaki.motohiro@jp.fujitsu.com

> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 18 January, 2012 11:16
...
> > Would be possible to not use percents for thesholds? Accounting in page=
s
> even
> > not so difficult to user-space.
>=20
> How does that work with memory hotplug?

Not worse than %%. For example you had 10% free memory threshold for 512 MB=
 RAM meaning 51.2 MB in absolute number.
Then hotplug turned off 256 MB, you for sure must update threshold for %% b=
ecause these 10% for 25.6 MB most likely will be not suitable for different=
 operating mode.
Using pages makes calculations must simpler.

>=20
> On Wed, Jan 18, 2012 at 11:06 AM,  <leonid.moiseichuk@nokia.com> wrote:
> > Also, looking on vmnotify_match I understand that events propagated to
> > user-space only in case threshold trigger change state from 0 to 1 but =
not
> > back, 1-> 0 is very useful event as well
(*)

> >
> > Would be possible to use for threshold pointed value(s) e.g. according =
to
> > enum zone_state_item, because kinds of memory to track could be
> different?
> > E.g. to tracking paging activity NR_ACTIVE_ANON and NR_ACTIVE_FILE
> could be
> > interesting, not only free.
>=20
> I don't think there's anything in the ABI that would prevent that.

If this statement also related my question (*)  I have to point need to tra=
ck attributes history, otherwise user-space will be constantly kicked with =
updates.

> I actually changed the ABI to look like this:
>=20
> struct vmnotify_event {
>         /*
>          * Size of the struct for ABI extensibility.
>          */
>         __u32                   size;
>=20
>         __u64                   attrs;
>=20
>         __u64                   attr_values[];
> };
>=20
> So userspace can decide which fields to include in notifications.

Good. But how you can provide current status of attributes to user-space? N=
eed to have read() call support to deliver all supported attr_values[] on d=
emand.

> >> +
> >> +#ifdef CONFIG_SWAP
> >> +     si_swapinfo(&si);
> >> +     event.nr_swap_pages     =3D si.totalswap;
> >> +#endif
> >> +
> >
> > Why not to use global_page_state() directly? si_meminfo() and especial
> > si_swapinfo are quite expensive call.
>=20
> Sure, we can do that. Feel free to send a patch :-).

When I see code because from emails it is quite difficult to understand.=20
For short-term I need to focus on integration "memnotify" version internall=
y which is kind of work for me already and provides all required interfaces=
 n9 needs.
=20
Btw, when API starts to work with pointed thresholds logically it is not an=
ymore low_mem_notify, you need to invent some other name.=20

> No idea what happens. The sampling code is just a proof of concept thing =
and
> I expect it to be buggy as hell. :-)
>=20
> 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
