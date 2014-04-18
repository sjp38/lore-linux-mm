Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 74DC56B0038
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:55:02 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id as1so1691053iec.31
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:55:02 -0700 (PDT)
Received: from fujitsu25.fnanic.fujitsu.com (fujitsu25.fnanic.fujitsu.com. [192.240.6.15])
        by mx.google.com with ESMTPS id ac8si18531630icc.18.2014.04.18.07.55.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:55:01 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Fri, 18 Apr 2014 07:54:36 -0700
Subject: RE: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to
 infinity
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E30986F0FF0@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1397812720-5629-1-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1397812720-5629-1-git-send-email-manfred@colorfullife.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "gthelen@google.com" <gthelen@google.com>, "aswin@hp.com" <aswin@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mtk.manpages@gmail.com" <mtk.manpages@gmail.com>



> -----Original Message-----
> From: Manfred Spraul [mailto:manfred@colorfullife.com]
> Sent: Friday, April 18, 2014 2:19 AM
> To: Andrew Morton; Davidlohr Bueso
> Cc: LKML; KAMEZAWA Hiroyuki; Motohiro Kosaki JP; gthelen@google.com; aswi=
n@hp.com; linux-mm@kvack.org; Manfred Spraul;
> mtk.manpages@gmail.com
> Subject: [PATCH] ipc/shm: Increase the defaults for SHMALL, SHMMAX to inf=
inity
>=20
> System V shared memory
>=20
> a) can be abused to trigger out-of-memory conditions and the standard
>    measures against out-of-memory do not work:
>=20
>     - it is not possible to use setrlimit to limit the size of shm segmen=
ts.
>=20
>     - segments can exist without association with any processes, thus
>       the oom-killer is unable to free that memory.
>=20
> b) is typically used for shared information - today often multiple GB.
>    (e.g. database shared buffers)
>=20
> The current default is a maximum segment size of 32 MB and a maximum tota=
l size of 8 GB. This is often too much for a) and not
> enough for b), which means that lots of users must change the defaults.
>=20
> This patch increases the default limits to ULONG_MAX, which is perfect fo=
r case b). The defaults are used after boot and as the initial
> value for each new namespace.
>=20
> Admins/distros that need a protection against a) should reduce the limits=
 and/or enable shm_rmid_forced.
>=20
> Further notes:
> - The patch only changes the boot time default, overrides behave as befor=
e:
> 	# sysctl kernel/shmall=3D33554432
>   would recreate the previous limit for SHMMAX (for the current namespace=
).
>=20
> - Disabling sysv shm allocation is possible with:
> 	# sysctl kernel.shmall=3D0
>   (not a new feature, also per-namespace)
>=20
> - ULONG_MAX is not really infinity, but 18 Exabyte segment size and
>   75 Zettabyte total size. This should be enough for the next few weeks.
>   (assuming a 64-bit system with 4k pages)
>=20
> Risks:
> - The patch breaks installations that use "take current value and increas=
e
>   it a bit". [seems to exist, http://marc.info/?l=3Dlinux-mm&m=3D13963833=
4330127]
>   After a:
> 	# CUR=3D`sysctl -n kernel.shmmax`
> 	# NEW=3D`echo $CUR+1 | bc -l`
> 	# sysctl -n kernel.shmmax=3D$NEW
>   shmmax ends up as 0, which disables shm allocations.
>=20
> - There is no wrap-around protection for ns->shm_ctlall, i.e. the 75 ZB
>   limit is not enforced.
>=20
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Reported-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: mtk.manpages@gmail.com

I'm ok either ULONG_MAX or 0 (special value of infinity).

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
