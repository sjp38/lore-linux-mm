Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6883D6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 06:50:20 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and
 related changes in MM
Date: Thu, 5 Jan 2012 11:47:21 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045542B5@008-AM1MPN1-003.mgdnok.nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
 <20120104195612.GB19181@suse.de>
In-Reply-To: <20120104195612.GB19181@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

Hi,

Android OOM (AOOM) is a different thing. Briefly Android OOM is a safety be=
lt, but I try to introduce look-ahead radar to stop before hitting wall.

As I understand AOOM it wait until situation is reached bad conditions whic=
h required memory reclaiming, selects application according to free memory =
and oom_adj level and kills it.
So no intermediate levels could be checked (e.g. 75% usage),  nothing could=
 be done in user-space to prevent killing, no notification for case when me=
mory becomes OK.

What I try to do is to get notification in any application that memory beco=
mes low, and do something about it like stop processing data, close unused =
pages or correctly shuts applications, daemons.
Application(s) might have necessity to install several notification levels,=
 so reaction could be adjusted based on current utilization level per each =
application, not globally.

Rik van Riel have pointed Kosaki-san's low memory notification. I know abou=
t mem_notify but according to Anton Vorontsov's statement [1] it is died si=
nce 2008 and for me it is really good news that is still not.=20
I need to re-investigate it.

With Best Wishes,
Leonid

[1] http://permalink.gmane.org/gmane.linux.kernel.mm/71626

-----Original Message-----
From: ext Greg KH [mailto:gregkh@suse.de]=20
Sent: 04 January, 2012 21:56
To: Moiseichuk Leonid (Nokia-MP/Helsinki)
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; cesarb@cesarb.net; ka=
mezawa.hiroyu@jp.fujitsu.com; emunson@mgebm.net; penberg@kernel.org; aarcan=
ge@redhat.com; riel@redhat.com; mel@csn.ul.ie; rientjes@google.com; dima@an=
droid.com; rebecca@android.com; san@google.com; akpm@linux-foundation.org; =
Jaaskelainen Vesa (Nokia-MP/Helsinki)
Subject: Re: [PATCH 3.2.0-rc1 0/3] Used Memory Meter pseudo-device and rela=
ted changes in MM

On Wed, Jan 04, 2012 at 07:21:53PM +0200, Leonid Moiseichuk wrote:
> The main idea of Used Memory Meter (UMM) is to provide low-cost=20
> interface for user-space to notify about memory consumption using=20
> similar approach /proc/meminfo does but focusing only on "modified" pages=
 which cannot be fogotten.
>=20
> The calculation formula in terms of meminfo looks the following:
>   UsedMemory =3D (MemTotal - MemFree - Buffers - Cached - SwapCached) +
>                                                (SwapTotal - SwapFree)=20
> It reflects well amount of system memory used in applications in heaps an=
d shared pages.
>=20
> Previously (n770..n900) we had lowmem.c [1] which used LSM and did a=20
> lot other things,
> n9 implementation based on memcg [2] which has own problems, so the=20
> proposed variant I hope is the best one for n9:
> - Keeps connections from user space
> - When amount of modified pages reaches crossed pointed value for particu=
lar connection
>   makes POLLIN and allow user-space app to read it and react
> - Economic as much as possible, so currently its operates if allocation h=
igher than 487
>   pages or last check happened 250 ms before Of course if no=20
> allocation happened then no activities performed, use-time must be not=20
> affected.
>=20
> Testing results:
> - Checkpatch produced 0 warning
> - Sparse does not produce warnings
> - One check costs ~20 us or less (could be checked with probe=3D1=20
> insmod)
> - One connection costs 20 bytes in kernel-space  (see observer=20
> structure) for 32-bit variant
> - For 10K connections poll update in requested in ~10ms, but for practica=
lly device expected
>   to will have about 10 connections (like n9 has now).
>=20
> Known weak points which I do not know how to fix but will if you have a b=
rillian idea:
> - Having hook in MM is nasty but MM/shrinker cannot be used there and=20
> LSM even worse idea
> - If I made=20
> 	$cat /dev/used_memory
>   it is produced lines in non-stop mode. Adding position check in umm_rea=
d seems doesn not help,
>   so "head -1 /dev/used_memory" should be used if you need to quick=20
> check
> - Format of output is USED_PAGES:AVAILABLE_PAGES, primitive but enough=20
> for tasks module does
>=20
> Tested on ARM, x86-32 and x86-64 with and without CONFIG_SWAP. Seems work=
s in all combinations.
> Sorry for wide distributions but list of names were produced by=20
> scripts/get_maintainer.pl

How does this compare with the lowmemorykiller.c driver from the android de=
velopers that is currently in the linux-next tree?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
