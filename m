Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEE71900123
	for <linux-mm@kvack.org>; Sat, 21 May 2011 10:44:03 -0400 (EDT)
Received: by qyk2 with SMTP id 2so227053qyk.14
        for <linux-mm@kvack.org>; Sat, 21 May 2011 07:44:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
	<20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520101120.GC11729@random.random>
	<BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com>
	<20110520153346.GA1843@barrios-desktop>
	<BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com>
	<20110520161934.GA2386@barrios-desktop>
	<BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
	<BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
	<BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com>
Date: Sat, 21 May 2011 23:44:02 +0900
Message-ID: <BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

Hi Andrew.

On Sat, May 21, 2011 at 10:34 PM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Sat, May 21, 2011 at 8:04 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 3f44b81..d1dabc9 100644
>>> @@ -1426,8 +1437,13 @@ shrink_inactive_list(unsigned long nr_to_scan,
>>> struct zone *zone,
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check if we should syncronously wait for =
writeback */
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (should_reclaim_stall(nr_taken, nr_reclai=
med, priority, sc)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_act=
ive, old_nr_scanned;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_reclaim_mode=
(priority, sc, true);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_active =3D clear_=
active_flags(&page_list, NULL);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_events(PGDE=
ACTIVATE, nr_active);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 old_nr_scanned =3D s=
c->nr_scanned;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed +=
=3D shrink_page_list(&page_list, zone, sc);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_scanned =3D o=
ld_nr_scanned;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_disable();
>>>
>>> I just tested 2.6.38.6 with the attached patch. =C2=A0It survived dirty=
_ram
>>> and test_mempressure without any problems other than slowness, but
>>> when I hit ctrl-c to stop test_mempressure, I got the attached oom.
>>
>> Minchan,
>>
>> I'm confused now.
>> If pages got SetPageActive(), should_reclaim_stall() should never return=
 true.
>> Can you please explain which bad scenario was happen?
>>
>> ------------------------------------------------------------------------=
-----------------------------
>> static void reset_reclaim_mode(struct scan_control *sc)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0sc->reclaim_mode =3D RECLAIM_MODE_SINGLE | RE=
CLAIM_MODE_ASYNC;
>> }
>>
>> shrink_page_list()
>> {
>> =C2=A0(snip)
>> =C2=A0activate_locked:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageActive(pag=
e);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgactivate++;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page(page)=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reset_reclaim_mod=
e(sc); =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/// he=
re
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list_add(&page->l=
ru, &ret_pages);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> ------------------------------------------------------------------------=
-----------------------------
>>
>>
>> ------------------------------------------------------------------------=
-----------------------------
>> bool should_reclaim_stall()
>> {
>> =C2=A0(snip)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Only stall on lumpy reclaim */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sc->reclaim_mode & RECLAIM_MODE_SINGLE) =
=C2=A0 /// and here
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;
>> ------------------------------------------------------------------------=
-----------------------------
>>
>
> I did some tracing and the oops happens from the second call to
> shrink_page_list after should_reclaim_stall returns true and it hits
> the same pages in the same order that the earlier call just finished
> calling SetPageActive on. =C2=A0I have *not* confirmed that the two calls
> happened from the same call to shrink_inactive_list, but something's
> certainly wrong in there.
>
> This is very easy to reproduce on my laptop.

I would like to confirm this problem.
Could you show the diff of 2.6.38.6 with current your 2.6.38.6 + alpha?
(ie, I would like to know that what patches you add up on vanilla
2.6.38.6 to reproduce this problem)
I believe you added my crap below patch. Right?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..69d317e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -311,7 +311,8 @@ static void set_reclaim_mode(int priority, struct
scan_control *sc,
        */
       if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
               sc->reclaim_mode |=3D syncmode;
-       else if (sc->order && priority < DEF_PRIORITY - 2)
+       else if ((sc->order && priority < DEF_PRIORITY - 2) ||
+                               prioiry <=3D DEF_PRIORITY / 3)
               sc->reclaim_mode |=3D syncmode;
       else
               sc->reclaim_mode =3D RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYN=
C;
@@ -1349,10 +1350,6 @@ static inline bool
should_reclaim_stall(unsigned long nr_taken,
       if (current_is_kswapd())
               return false;

-       /* Only stall on lumpy reclaim */
-       if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
-               return false;
-
       /* If we have relaimed everything on the isolated list, no stall */
       if (nr_freed =3D=3D nr_taken)
               return false;


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
