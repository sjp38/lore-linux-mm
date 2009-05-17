Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 62A846B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 20:37:56 -0400 (EDT)
Received: by gxk20 with SMTP id 20so5187684gxk.14
        for <linux-mm@kvack.org>; Sat, 16 May 2009 17:38:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090516092858.GA12104@localhost>
References: <20090516090005.916779788@intel.com>
	 <20090516090448.410032840@intel.com>
	 <20090516092858.GA12104@localhost>
Date: Sun, 17 May 2009 09:38:30 +0900
Message-ID: <28c262360905161738o2ec8b0cg6bfb40b40fc048fa@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, May 16, 2009 at 6:28 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> [trivial update on comment text, according to Rik's comment]
>
> --
> vmscan: make mapped executable pages the first class citizen
>
> Protect referenced PROT_EXEC mapped pages from being deactivated.
>
> PROT_EXEC(or its internal presentation VM_EXEC) pages normally belong to =
some
> currently running executables and their linked libraries, they shall real=
ly be
> cached aggressively to provide good user experiences.
>
> Thanks to Johannes Weiner for the advice to reuse the VMA walk in
> page_referenced() to get the PROT_EXEC bit.
>
>
> [more details]
>
> ( The consequences of this patch will have to be discussed together with
> =C2=A0Rik van Riel's recent patch "vmscan: evict use-once pages first". )
>
> ( Some of the good points and insights are taken into this changelog.
> =C2=A0Thanks to all the involved people for the great LKML discussions. )
>
> the problem
> -----------
>
> For a typical desktop, the most precious working set is composed of
> *actively accessed*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(1) memory mapped executables
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(2) and their anonymous pages
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(3) and other files
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(4) and the dcache/icache/.. slabs
> while the least important data are
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5) infrequently used or use-once files
>
> For a typical desktop, one major problem is busty and large amount of (5)
> use-once files flushing out the working set.
>
> Inside the working set, (4) dcache/icache have already been too sticky ;-=
)
> So we only have to care (2) anonymous and (1)(3) file pages.
>
> anonymous pages
> ---------------
> Anonymous pages are effectively immune to the streaming IO attack, becaus=
e we
> now have separate file/anon LRU lists. When the use-once files crowd into=
 the
> file LRU, the list's "quality" is significantly lowered. Therefore the sc=
an
> balance policy in get_scan_ratio() will choose to scan the (low quality) =
file
> LRU much more frequently than the anon LRU.
>
> file pages
> ----------
> Rik proposed to *not* scan the active file LRU when the inactive list gro=
ws
> larger than active list. This guarantees that when there are use-once str=
eaming
> IO, and the working set is not too large(so that active_size < inactive_s=
ize),
> the active file LRU will *not* be scanned at all. So the not-too-large wo=
rking
> set can be well protected.
>
> But there are also situations where the file working set is a bit large s=
o that
> (active_size >=3D inactive_size), or the streaming IOs are not purely use=
-once.
> In these cases, the active list will be scanned slowly. Because the curre=
nt
> shrink_active_list() policy is to deactivate active pages regardless of t=
heir
> referenced bits. The deactivated pages become susceptible to the streamin=
g IO
> attack: the inactive list could be scanned fast (500MB / 50MBps =3D 10s) =
so that
> the deactivated pages don't have enough time to get re-referenced. Becaus=
e a
> user tend to switch between windows in intervals from seconds to minutes.
>
> This patch holds mapped executable pages in the active list as long as th=
ey
> are referenced during each full scan of the active list. =C2=A0Because th=
e active
> list is normally scanned much slower, they get longer grace time (eg. 100=
s)
> for further references, which better matches the pace of user operations.
>
> Therefore this patch greatly prolongs the in-cache time of executable cod=
e,
> when there are moderate memory pressures.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0before patch: guaranteed to be cached if refer=
ence intervals < I
> =C2=A0 =C2=A0 =C2=A0 =C2=A0after =C2=A0patch: guaranteed to be cached if =
reference intervals < I+A
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0(except when randomly reclaimed by the lumpy reclaim)
> where
> =C2=A0 =C2=A0 =C2=A0 =C2=A0A =3D time to fully scan the =C2=A0 active fil=
e LRU
> =C2=A0 =C2=A0 =C2=A0 =C2=A0I =3D time to fully scan the inactive file LRU
>
> Note that normally A >> I.
>
> side effects
> ------------
>
> This patch is safe in general, it restores the pre-2.6.28 mmap() behavior
> but in a much smaller and well targeted scope.
>
> One may worry about some one to abuse the PROT_EXEC heuristic. =C2=A0But =
as
> Andrew Morton stated, there are other tricks to getting that sort of boos=
t.
>
> Another concern is the PROT_EXEC mapped pages growing large in rare cases=
,
> and therefore hurting reclaim efficiency. But a sane application targeted=
 for
> large audience will never use PROT_EXEC for data mappings. If some home m=
ade
> application tries to abuse that bit, it shall be aware of the consequence=
s.
> If it is abused to scale of 2/3 total memory, it gains nothing but overhe=
ads.
>
> CC: Elladan <elladan@eskimo.com>
> CC: Nick Piggin <npiggin@suse.de>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Peter Zijlstra <peterz@infradead.org>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
