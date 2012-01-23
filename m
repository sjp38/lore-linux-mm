Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 74A576B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 15:11:12 -0500 (EST)
Received: by qcsg1 with SMTP id g1so787912qcs.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 12:11:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 23 Jan 2012 12:11:11 -0800
Message-ID: <CALWz4ixufzgi2kDRgTMAzty-S2AKMmPfqdGc1sBRNFJxf-WTAQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: remove unnecessary thp check at page stat accounting
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Wed, Jan 18, 2012 at 11:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Thank you very much for reviewing previous RFC series.
> This is a patch against memcg-devel and linux-next (can by applied withou=
t HUNKs).
>
> =3D=3D
>
> From 64641b360839b029bb353fbd95f7554cc806ed05 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 16:08:33 +0900
> Subject: [PATCH] memcg: remove unnecessary thp check in mem_cgroup_update=
_page_stat()
>
> commit 58b318ecf(memcg-devel)
> =A0 =A0memcg: make mem_cgroup_split_huge_fixup() more efficient
> removes move_lock_page_cgroup() in thp-split path.
>
> So, We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> and fallback into the locked accounting because both move charge and thp
> split up are done with compound_lock so they cannot race. update vs.
> move is protected by the mem_cgroup_stealed sufficiently.

Sorry, i don't see we changed the "move charge" to "move account" ?

--Ying
>
> PageTransHuge pages shouldn't appear in this code path currently because
> we are tracking only file pages at the moment but later we are planning
> to track also other pages (e.g. mlocked ones).
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> =A0mm/memcontrol.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5073474..fb2dfc3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1801,7 +1801,7 @@ void mem_cgroup_update_page_stat(struct page *page,
> =A0 =A0 =A0 =A0if (unlikely(!memcg || !PageCgroupUsed(pc)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0/* pc->mem_cgroup is unstable ? */
> - =A0 =A0 =A0 if (unlikely(mem_cgroup_stealed(memcg)) || PageTransHuge(pa=
ge)) {
> + =A0 =A0 =A0 if (unlikely(mem_cgroup_stealed(memcg))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* take a lock against to access pc->mem_c=
group */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0move_lock_page_cgroup(pc, &flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0need_unlock =3D true;
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
