Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 10B6D6B002E
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:01:35 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2333047pwi.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 09:01:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520153346.GA1843@barrios-desktop>
References: <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
 <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com> <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
 <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com> <4DD5DC06.6010204@jp.fujitsu.com>
 <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com> <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
 <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com> <20110520101120.GC11729@random.random>
 <BANLkTikAFMvpgHR2dopd+Nvjfyw_XT5=LA@mail.gmail.com> <20110520153346.GA1843@barrios-desktop>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 20 May 2011 12:01:12 -0400
Message-ID: <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, May 20, 2011 at 11:33 AM, Minchan Kim <minchan.kim@gmail.com> wrote=
:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8bfd450..a5c01e9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1430,7 +1430,10 @@ shrink_inactive_list(unsigned long nr_to_scan, str=
uct zone *zone,
>
> =A0 =A0 =A0 =A0/* Check if we should syncronously wait for writeback */
> =A0 =A0 =A0 =A0if (should_reclaim_stall(nr_taken, nr_reclaimed, priority,=
 sc)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_active;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_reclaim_mode(priority, sc, true);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_active =3D clear_active_flags(&page_list=
, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_events(PGDEACTIVATE, nr_active);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaimed +=3D shrink_page_list(&page_l=
ist, zone, sc);
> =A0 =A0 =A0 =A0}
>
> --

I'm now running that patch *without* the pgdat_balanced fix or the
need_resched check.  The VM_BUG_ON doesn't happen but I still get
incorrect OOM kills.

However, if I replace the check with:

	if (false &&should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {

then my system lags under bad memory pressure but recovers without
OOMs or oopses.

Is that expected?

--Andy

> 1.7.1
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
