Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 012BE900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 04:24:50 -0400 (EDT)
Received: by pxi10 with SMTP id 10so837716pxi.8
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 01:24:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302678187-24154-3-git-send-email-yinghan@google.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com> <1302678187-24154-3-git-send-email-yinghan@google.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Thu, 14 Apr 2011 16:24:27 +0800
Message-ID: <BANLkTimR+Tn+AccUt3dxqXhSVA8tUp_xDg@mail.gmail.com>
Subject: Re: [PATCH V3 2/7] Add per memcg reclaim watermarks
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

Hi Ying,

2011/4/13 Ying Han <yinghan@google.com>:
> +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> +{
> + =C2=A0 =C2=A0 =C2=A0 u64 limit;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long wmark_ratio;
> +
> + =C2=A0 =C2=A0 =C2=A0 wmark_ratio =3D get_wmark_ratio(mem);
> + =C2=A0 =C2=A0 =C2=A0 limit =3D mem_cgroup_get_limit(mem);

mem_cgroup_get_limit doesn't return the correct limit for you,
actually it's only for OOM killer.
You should use
limit =3D res_counter_read_u64(&mem->res, RES_LIMIT) directly.
Otherwise in the box which has swapon, you will get a huge
number here.
e.g.
 [root@zyh-fedora a]# echo 500m > memory.limit_in_bytes
[root@zyh-fedora a]# cat memory.limit_in_bytes
524288000
[root@zyh-fedora a]# cat memory.reclaim_wmarks
low_wmark 9114218496
high_wmark 9114218496

Regards,
Zhu Yanhai


> + =C2=A0 =C2=A0 =C2=A0 if (wmark_ratio =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 res_counter_set_low_wm=
ark_limit(&mem->res, limit);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 res_counter_set_high_w=
mark_limit(&mem->res, limit);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long low_wmar=
k, high_wmark;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long long tmp=
 =3D (wmark_ratio * limit) / 100;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 low_wmark =3D tmp;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 high_wmark =3D tmp - (=
tmp >> 8);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 res_counter_set_low_wm=
ark_limit(&mem->res, low_wmark);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 res_counter_set_high_w=
mark_limit(&mem->res, high_wmark);
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> =C2=A0/*
> =C2=A0* Following LRU functions are allowed to be used without PCG_LOCK.
> =C2=A0* Operations are called by routine of global LRU independently from=
 memcg.
> @@ -1195,6 +1219,16 @@ static unsigned int get_swappiness(struct mem_cgro=
up *memcg)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return memcg->swappiness;
> =C2=A0}
>
> +static unsigned long get_wmark_ratio(struct mem_cgroup *memcg)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct cgroup *cgrp =3D memcg->css.cgroup;
> +
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(!cgrp);
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(!cgrp->parent);
> +
> + =C2=A0 =C2=A0 =C2=A0 return memcg->wmark_ratio;
> +}
> +
> =C2=A0static void mem_cgroup_start_move(struct mem_cgroup *mem)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int cpu;
> @@ -3205,6 +3239,7 @@ static int mem_cgroup_resize_limit(struct mem_cgrou=
p *memcg,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg->memsw_is_minimum =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 setup_per_memcg_wmarks=
(memcg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&set_=
limit_mutex);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!ret)
> @@ -3264,6 +3299,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem=
_cgroup *memcg,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg->memsw_is_minimum =3D false;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 setup_per_memcg_wmarks=
(memcg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&set_=
limit_mutex);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!ret)
> @@ -4521,6 +4557,22 @@ static void __init enable_swap_cgroup(void)
> =C2=A0}
> =C2=A0#endif
>
> +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int charge_flags)
> +{
> + =C2=A0 =C2=A0 =C2=A0 long ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int flags =3D CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH=
;
> +
> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON((charge_flags & flags) =3D=3D flags);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (charge_flags & CHARGE_WMARK_LOW)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D res_counter_ch=
eck_under_low_wmark_limit(&mem->res);
> + =C2=A0 =C2=A0 =C2=A0 if (charge_flags & CHARGE_WMARK_HIGH)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D res_counter_ch=
eck_under_high_wmark_limit(&mem->res);
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> =C2=A0static int mem_cgroup_soft_limit_tree_init(void)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_tree_per_node *rtpn;
> --
> 1.7.3.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
