Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9040F6B00AF
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 01:56:22 -0400 (EDT)
Received: by iwn1 with SMTP id 1so3298292iwn.14
        for <linux-mm@kvack.org>; Sat, 16 Oct 2010 22:56:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1287177279-30876-5-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
	<1287177279-30876-5-git-send-email-gthelen@google.com>
Date: Sun, 17 Oct 2010 14:56:20 +0900
Message-ID: <AANLkTimosH8egHCY1BJ_8DisweJDm1VwxXJ=sGzxUJJe@mail.gmail.com>
Subject: Re: [PATCH v2 04/11] memcg: disable softirq in lock_page_cgroup()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 16, 2010 at 6:14 AM, Greg Thelen <gthelen@google.com> wrote:
> If pages are being migrated from a memcg, then updates to that
> memcg's page statistics are protected by grabbing a bit spin lock
> using lock_page_cgroup(). =A0In an upcoming commit memcg dirty page
> accounting will be updating memcg page accounting (specifically:
> num writeback pages) from softirq. =A0Avoid a deadlocking nested
> spin lock attempt by disabling softirq on the local processor
> when grabbing the page_cgroup bit_spin_lock in lock_page_cgroup().
> This avoids the following deadlock:
> statistic
> =A0 =A0 =A0CPU 0 =A0 =A0 =A0 =A0 =A0 =A0 CPU 1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inc_file_mapped
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock
> =A0start move
> =A0synchronize_rcu
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lock_page_cgroup
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0softirq
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0test_clear_page_writeback
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_dec_page_stat(NR_WR=
ITEBACK)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lock_page_cgroup =A0 /* deadlo=
ck */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlock_page_cgroup
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unlock_page_cgroup
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock
>
> By disabling softirq in lock_page_cgroup, nested calls are avoided.
> The softirq would be delayed until after inc_file_mapped enables
> softirq when calling unlock_page_cgroup().
>
> The normal, fast path, of memcg page stat updates typically
> does not need to call lock_page_cgroup(), so this change does
> not affect the performance of the common case page accounting.
>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> =A0include/linux/page_cgroup.h | =A0 =A06 ++++++
> =A01 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index b59c298..0585546 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -3,6 +3,8 @@
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> =A0#include <linux/bit_spinlock.h>
> +#include <linux/hardirq.h>
> +
> =A0/*
> =A0* Page Cgroup can be considered as an extended mem_map.
> =A0* A page_cgroup page is associated with every page descriptor. The
> @@ -119,12 +121,16 @@ static inline enum zone_type page_cgroup_zid(struct=
 page_cgroup *pc)
>
> =A0static inline void lock_page_cgroup(struct page_cgroup *pc)
> =A0{
> + =A0 =A0 =A0 /* This routine is only deadlock safe from softirq or lower=
. */
> + =A0 =A0 =A0 VM_BUG_ON(in_irq());
> + =A0 =A0 =A0 local_bh_disable();
> =A0 =A0 =A0 =A0bit_spin_lock(PCG_LOCK, &pc->flags);
> =A0}
>
> =A0static inline void unlock_page_cgroup(struct page_cgroup *pc)
> =A0{
> =A0 =A0 =A0 =A0bit_spin_unlock(PCG_LOCK, &pc->flags);
> + =A0 =A0 =A0 local_bh_enable();
> =A0}
>
> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
> --
> 1.7.1
>
>

Please, see recent Kame's patch.
http://lkml.org/lkml/2010/10/15/54

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
