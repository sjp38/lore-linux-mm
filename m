Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 93FE06B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 02:34:57 -0500 (EST)
Received: by qcsd16 with SMTP id d16so1438555qcs.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 23:34:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120202063345.GA15124@localhost>
References: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
 <CAHH2K0bPdqzpuWv82uyvEu4d+cDqJOYoHbw=GeP5OZk4-3gCUg@mail.gmail.com> <20120202063345.GA15124@localhost>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 1 Feb 2012 23:34:36 -0800
Message-ID: <CAHH2K0a+srs7A78SdneNG01bbS_Nyq0eCSOA8mrujuE=F2juSg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] memcg topics.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

On Wed, Feb 1, 2012 at 10:33 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Hi Greg,
>
> On Wed, Feb 01, 2012 at 12:24:25PM -0800, Greg Thelen wrote:
>> 1. how to compute per-container pause based on bdi bandwidth, cgroup
>> dirty page usage.
>> 2. how to ensure that writeback will engage even if system and bdi are
>> below respective background dirty ratios, yet a memcg is above its bg
>> dirty limit.
>
> The solution to (1,2) would be something like this:
>
> --- linux-next.orig/mm/page-writeback.c 2012-02-02 14:13:45.000000000 +08=
00
> +++ linux-next/mm/page-writeback.c =A0 =A0 =A02012-02-02 14:24:11.0000000=
00 +0800
> @@ -654,6 +654,17 @@ static unsigned long bdi_position_ratio(
> =A0 =A0 =A0 =A0pos_ratio =3D pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> =A0 =A0 =A0 =A0pos_ratio +=3D 1 << RATELIMIT_CALC_SHIFT;
>
> + =A0 =A0 =A0 if (memcg) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 long long f;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 x =3D div_s64((memcg_setpoint - memcg_dirty=
) << RATELIMIT_CALC_SHIFT,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_limit - memcg=
_setpoint + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 f =3D x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 f =3D f * x >> RATELIMIT_CALC_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 f =3D f * x >> RATELIMIT_CALC_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 f +=3D 1 << RATELIMIT_CALC_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pos_ratio =3D pos_ratio * f >> RATELIMIT_CA=
LC_SHIFT;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We have computed basic pos_ratio above based on global =
situation. If
> =A0 =A0 =A0 =A0 * the bdi is over/under its share of dirty pages, we want=
 to scale
> @@ -1202,6 +1213,8 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0freerun =3D dirty_freerun_ceiling(dirty_th=
resh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0background_thresh);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nr_dirty <=3D freerun) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg && memcg_dirty > =
memcg_freerun)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto start_=
writeback;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0current->dirty_paused_when=
 =3D now;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0current->nr_dirtied =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0current->nr_dirtied_pause =
=3D
> @@ -1209,6 +1222,7 @@ static void balance_dirty_pages(struct a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> +start_writeback:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(!writeback_in_progress(bdi)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bdi_start_background_write=
back(bdi);
>
>
> That makes the minimal change to enforce per-memcg dirty ratio.
> It could result in a less stable control system, but should still
> be able to balance things out.
>
> Thanks,
> Fengguang

Thank you for the quick patch.  It looks promising.  I can imagine how
this would wake up background writeback.  But I am unsure how
background writeback will do anything.  It seems like
over_bground_thresh() would not necessarily see system or bdi dirty
usage over respective limits.  In previously posted memcg writeback
patches this involved an fs-writeback.c call to
mem_cgroups_over_bground_dirty_thresh() to check for memcg dirty limit
compliance.  Do you think we still need such a call out to memcg from
writeback?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
