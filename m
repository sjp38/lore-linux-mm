Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8D4D96B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:22:46 -0500 (EST)
Received: by iwn9 with SMTP id 9so15564iwn.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 15:22:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1289294671-6865-4-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
	<1289294671-6865-4-git-send-email-gthelen@google.com>
Date: Wed, 10 Nov 2010 08:22:44 +0900
Message-ID: <AANLkTinX9FSC=9azJWH7LELvLs2jYjOYUeQe4KhD_th=@mail.gmail.com>
Subject: Re: [PATCH 3/6] memcg: make throttle_vm_writeout() memcg aware
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 9, 2010 at 6:24 PM, Greg Thelen <gthelen@google.com> wrote:
> If called with a mem_cgroup, then throttle_vm_writeout() should
> query the given cgroup for its dirty memory usage limits.
>
> dirty_writeback_pages() is no longer used, so delete it.
>
> Signed-off-by: Greg Thelen <gthelen@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> ---
> =A0include/linux/writeback.h | =A0 =A02 +-
> =A0mm/page-writeback.c =A0 =A0 =A0 | =A0 31 ++++++++++++++++-------------=
--
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A03 files changed, 18 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 335dba1..1bacdda 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -97,7 +97,7 @@ void laptop_mode_timer_fn(unsigned long data);
> =A0#else
> =A0static inline void laptop_sync_completion(void) { }
> =A0#endif
> -void throttle_vm_writeout(gfp_t gfp_mask);
> +void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)=
;
>
> =A0/* These are exported to sysctl. */
> =A0extern int dirty_background_ratio;
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index d717fa9..bf85062 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -131,18 +131,6 @@ EXPORT_SYMBOL(laptop_mode);
> =A0static struct prop_descriptor vm_completions;
> =A0static struct prop_descriptor vm_dirties;
>
> -static unsigned long dirty_writeback_pages(void)
> -{
> - =A0 =A0 =A0 unsigned long ret;
> -
> - =A0 =A0 =A0 ret =3D mem_cgroup_page_stat(NULL, MEMCG_NR_DIRTY_WRITEBACK=
_PAGES);
> - =A0 =A0 =A0 if ((long)ret < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D global_page_state(NR_UNSTABLE_NFS) =
+
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(NR_WRITEB=
ACK);
> -
> - =A0 =A0 =A0 return ret;
> -}
> -

Nice cleanup.

> =A0/*
> =A0* couple the period to the dirty_ratio:
> =A0*
> @@ -703,12 +691,25 @@ void balance_dirty_pages_ratelimited_nr(struct addr=
ess_space *mapping,
> =A0}
> =A0EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>
> -void throttle_vm_writeout(gfp_t gfp_mask)
> +/*
> + * Throttle the current task if it is near dirty memory usage limits.
> + * If @mem_cgroup is NULL or the root_cgroup, then use global dirty memo=
ry
> + * information; otherwise use the per-memcg dirty limits.
> + */
> +void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)
> =A0{
> =A0 =A0 =A0 =A0struct dirty_info dirty_info;
> + =A0 =A0 =A0 unsigned long nr_writeback;
>
> =A0 =A0 =A0 =A0 for ( ; ; ) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&dirty_info);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup || !memcg_dirty_info(mem_cg=
roup, &dirty_info)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_dirty_info(&dirty_in=
fo);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_writeback =3D global_pag=
e_state(NR_UNSTABLE_NFS) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page=
_state(NR_WRITEBACK);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_writeback =3D mem_cgroup=
_page_stat(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup,=
 MEMCG_NR_DIRTY_WRITEBACK_PAGES);

In point of view rcu_read_lock removal, memcg can't destroy due to
mem_cgroup_select_victim's css_tryget?
Then, we can remove unnecessary rcu_read_lock in mem_cgroup_page_stat.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
