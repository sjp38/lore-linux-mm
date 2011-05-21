Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E75A900114
	for <linux-mm@kvack.org>; Sat, 21 May 2011 08:04:53 -0400 (EDT)
Received: by wyf19 with SMTP id 19so4331174wyf.14
        for <linux-mm@kvack.org>; Sat, 21 May 2011 05:04:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
References: <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
 <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com> <20110520153346.GA1843@barrios-desktop>
 <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com> <20110520161934.GA2386@barrios-desktop>
 <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 21 May 2011 21:04:31 +0900
Message-ID: <BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3f44b81..d1dabc9 100644
> @@ -1426,8 +1437,13 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
>
> =A0 =A0 =A0 =A0/* Check if we should syncronously wait for writeback */
> =A0 =A0 =A0 =A0if (should_reclaim_stall(nr_taken, nr_reclaimed, priority,=
 sc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_active, old_nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_reclaim_mode(priority, sc, true);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_active =3D clear_active_flags(&page_list=
, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_events(PGDEACTIVATE, nr_active);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 old_nr_scanned =3D sc->nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaimed +=3D shrink_page_list(&page_l=
ist, zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D old_nr_scanned;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0local_irq_disable();
>
> I just tested 2.6.38.6 with the attached patch. =A0It survived dirty_ram
> and test_mempressure without any problems other than slowness, but
> when I hit ctrl-c to stop test_mempressure, I got the attached oom.

Minchan,

I'm confused now.
If pages got SetPageActive(), should_reclaim_stall() should never return tr=
ue.
Can you please explain which bad scenario was happen?

---------------------------------------------------------------------------=
--------------------------
static void reset_reclaim_mode(struct scan_control *sc)
{
        sc->reclaim_mode =3D RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;
}

shrink_page_list()
{
 (snip)
 activate_locked:
                SetPageActive(page);
                pgactivate++;
                unlock_page(page);
                reset_reclaim_mode(sc);                  /// here
                list_add(&page->lru, &ret_pages);
        }
---------------------------------------------------------------------------=
--------------------------


---------------------------------------------------------------------------=
--------------------------
bool should_reclaim_stall()
{
 (snip)

        /* Only stall on lumpy reclaim */
        if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)   /// and here
                return false;
---------------------------------------------------------------------------=
--------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
