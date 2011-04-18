Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8DCDC900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 01:01:43 -0400 (EDT)
Received: by iwg8 with SMTP id 8so5406845iwg.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 22:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302909815-4362-10-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-10-git-send-email-yinghan@google.com>
Date: Mon, 18 Apr 2011 14:01:40 +0900
Message-ID: <BANLkTik5g_+7KYVRM8tmpHzM55vjekk1EA@mail.gmail.com>
Subject: Re: [PATCH V5 09/10] Add API to export per-memcg kswapd pid.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> This add the API which exports per-memcg kswapd thread pid. The kswapd
> thread is named as "memcg_" + css_id, and the pid can be used to put
> kswapd thread into cpu cgroup later.
>
> $ mkdir /dev/cgroup/memory/A
> $ cat /dev/cgroup/memory/A/memory.kswapd_pid
> memcg_null 0
>
> $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> $ ps -ef | grep memcg
> root =C2=A0 =C2=A0 =C2=A06727 =C2=A0 =C2=A0 2 =C2=A00 14:32 ? =C2=A0 =C2=
=A0 =C2=A0 =C2=A000:00:00 [memcg_3]
> root =C2=A0 =C2=A0 =C2=A06729 =C2=A06044 =C2=A00 14:32 ttyS0 =C2=A0 =C2=
=A000:00:00 grep memcg
>
> $ cat memory.kswapd_pid
> memcg_3 6727
>
> changelog v5..v4
> 1. Initialize the memcg-kswapd pid to -1 instead of 0.
> 2. Remove the kswapds_spinlock.
>
> changelog v4..v3
> 1. Add the API based on KAMAZAWA's request on patch v3.
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0include/linux/swap.h | =C2=A0 =C2=A02 ++
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 31 +++++++++++++++++++=
++++++++++++
> =C2=A02 files changed, 33 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 319b800..2d3e21a 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -34,6 +34,8 @@ struct kswapd {
> =C2=A0};
>
> =C2=A0int kswapd(void *p);
> +extern spinlock_t kswapds_spinlock;

Remove spinlock.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
