Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CEA716B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 18:53:56 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p42MrsIT015804
	for <linux-mm@kvack.org>; Mon, 2 May 2011 15:53:54 -0700
Received: from ywa8 (ywa8.prod.google.com [10.192.1.8])
	by wpaz1.hot.corp.google.com with ESMTP id p42MqtOQ015275
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 2 May 2011 15:53:52 -0700
Received: by ywa8 with SMTP id 8so2167822ywa.9
        for <linux-mm@kvack.org>; Mon, 02 May 2011 15:53:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1304366849.15370.27.camel@mulgrave.site>
References: <1304366849.15370.27.camel@mulgrave.site>
From: Paul Menage <menage@google.com>
Date: Mon, 2 May 2011 15:53:31 -0700
Message-ID: <BANLkTimhZAdL-HXftE86SyjRrDy9KB+qsg@mail.gmail.com>
Subject: Re: memcg: fix fatal livelock in kswapd
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>, Balbir Singh <balbir@in.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

[ Adding the memcg maintainers ]

On Mon, May 2, 2011 at 1:07 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> The fatal livelock in kswapd, reported in this thread:
>
> http://marc.info/?t=3D130392066000001
>
> Is mitigateable if we prevent the cgroups code being so aggressive in
> its zone shrinking (by reducing it's default shrink from 0 [everything]
> to DEF_PRIORITY [some things]). =A0This will have an obvious knock on
> effect to cgroup accounting, but it's better than hanging systems.
>
> Signed-off-by: James Bottomley <James.Bottomley@suse.de>
>
> ---
>
> From 74b62fc417f07e1411d98181631e4e097c8e3e68 Mon Sep 17 00:00:00 2001
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
> Date: Mon, 2 May 2011 14:56:29 -0500
> Subject: [PATCH] vmscan: move containers scan back to default priority
>
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..46cde92 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2173,8 +2173,12 @@ unsigned long mem_cgroup_shrink_node_zone(struct m=
em_cgroup *mem,
> =A0 =A0 =A0 =A0 * if we don't reclaim here, the shrink_zone from balance_=
pgdat
> =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup's as well. We =
hack
> =A0 =A0 =A0 =A0 * the priority and make it zero.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* FIXME: jejb: zero here was causing a livelock in the
> + =A0 =A0 =A0 =A0* shrinker so changed to DEF_PRIORITY to fix this. Now n=
eed to
> + =A0 =A0 =A0 =A0* sort out cgroup accounting.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 shrink_zone(0, zone, &sc);
> + =A0 =A0 =A0 shrink_zone(DEF_PRIORITY, zone, &sc);
>
> =A0 =A0 =A0 =A0trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaime=
d);
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
