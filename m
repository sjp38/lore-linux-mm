Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EB9E66B0083
	for <linux-mm@kvack.org>; Sat, 21 May 2011 10:31:46 -0400 (EDT)
Received: by qyk2 with SMTP id 2so223287qyk.14
        for <linux-mm@kvack.org>; Sat, 21 May 2011 07:31:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
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
Date: Sat, 21 May 2011 23:31:45 +0900
Message-ID: <BANLkTimfPXXcTamkR1kTgOu55iy14ybTpA@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Lutomirski <luto@mit.edu>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Sat, May 21, 2011 at 9:04 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 3f44b81..d1dabc9 100644
>> @@ -1426,8 +1437,13 @@ shrink_inactive_list(unsigned long nr_to_scan,
>> struct zone *zone,
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check if we should syncronously wait for w=
riteback */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (should_reclaim_stall(nr_taken, nr_reclaim=
ed, priority, sc)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_acti=
ve, old_nr_scanned;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_reclaim_mode(=
priority, sc, true);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_active =3D clear_a=
ctive_flags(&page_list, NULL);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 count_vm_events(PGDEA=
CTIVATE, nr_active);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 old_nr_scanned =3D sc=
->nr_scanned;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed +=3D=
 shrink_page_list(&page_list, zone, sc);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_scanned =3D ol=
d_nr_scanned;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_disable();
>>
>> I just tested 2.6.38.6 with the attached patch. =C2=A0It survived dirty_=
ram
>> and test_mempressure without any problems other than slowness, but
>> when I hit ctrl-c to stop test_mempressure, I got the attached oom.
>
> Minchan,
>
> I'm confused now.
> If pages got SetPageActive(), should_reclaim_stall() should never return =
true.

Hi KOSAKI,
You're absolutely right.
I missed that so the problem should not happen. :(

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
