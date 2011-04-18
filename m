Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53A8B900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 22:22:11 -0400 (EDT)
Received: by iyh42 with SMTP id 42so5300131iyh.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 19:22:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302909815-4362-6-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-6-git-send-email-yinghan@google.com>
Date: Mon, 18 Apr 2011 11:22:09 +0900
Message-ID: <BANLkTing7E=7HZ25uTvwVHwYV5c-6-uvjg@mail.gmail.com>
Subject: Re: [PATCH V5 05/10] Implement the select_victim_node within memcg.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> This add the mechanism for background reclaim which we remember the
> last scanned node and always starting from the next one each time.
> The simple round-robin fasion provide the fairness between nodes for
> each memcg.
>
> changelog v5..v4:
> 1. initialize the last_scanned_node to MAX_NUMNODES.
>
> changelog v4..v3:
> 1. split off from the per-memcg background reclaim patch.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0include/linux/memcontrol.h | =C2=A0 =C2=A03 +++
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 3=
5 +++++++++++++++++++++++++++++++++++
> =C2=A02 files changed, 38 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f7ffd1f..d4ff7f2 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup *me=
m,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct kswapd *kswapd_p);
> =C2=A0extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> =C2=A0extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup =
*mem);
> +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const nodema=
sk_t *nodes);
>
> =C2=A0static inline
> =C2=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8761a6f..b92dc13 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -279,6 +279,11 @@ struct mem_cgroup {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 high_wmark_distance;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 low_wmark_distance;
>
> + =C2=A0 =C2=A0 =C2=A0 /* While doing per cgroup background reclaim, we c=
ache the

Correct comment style.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
