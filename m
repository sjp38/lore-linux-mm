Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB6E66B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 07:18:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n6so168150576qtn.2
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:18:28 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id s5si22226995wjk.223.2016.08.16.04.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 04:18:27 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id q128so15844137wma.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:18:27 -0700 (PDT)
From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher order requests
Date: Tue, 16 Aug 2016 13:18:25 +0200
References: <201608120901.41463.a.miskiewicz@gmail.com> <20160814125327.GF9248@dhcp22.suse.cz> <20160815085129.GA3360@dhcp22.suse.cz>
In-Reply-To: <20160815085129.GA3360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201608161318.25412.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Monday 15 of August 2016, Michal Hocko wrote:
> [Fixing up linux-mm]
>=20
> Ups I had a c&p error in the previous patch. Here is an updated patch.


Going to apply this patch now and report again. I mean time what I have is =
a=20

 while (true); do echo "XX date"; date; echo "XX SLAB"; cat /proc/slabinfo =
;=20
echo "XX VMSTAT"; cat /proc/vmstat ; echo "XX free"; free; echo "XX DMESG";=
=20
dmesg -T | tail -n 50; /bin/sleep 60;done 2>&1 | tee log

loop gathering some data while few OOM conditions happened.

I was doing "rm -rf copyX; cp -al original copyX" 10x in parallel.

https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160816.txt


> ---
> From 348e768ab1f885bb6dc3160158c17f043fd7f219 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Sun, 14 Aug 2016 12:23:13 +0200
> Subject: [PATCH] mm, oom: report compaction/migration stats for higher
> order requests
>=20
> Both oom and the allocation failure reports are not providing any
> information about the compaction/migration counters which might give us
> a clue what went wrong and why we are OOM for the particular order -
> e.g. the compaction fails constantly because it cannot isolate any pages
> or that the migration fails. So far we have been asking for /proc/vmstat
> content before and after the OOM which is rather clumsy, especially when
> the OOM is not 100% reproducible.
>=20
> Extend show_mem() to understand a new filter (SHOW_COMPACTION_STATS)
> which is enabled only for higer order paths.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mm.h |  1 +
>  lib/show_mem.c     | 14 ++++++++++++++
>  mm/oom_kill.c      |  2 +-
>  mm/page_alloc.c    |  2 ++
>  4 files changed, 18 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7e44613c5078..b4859547acc4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1146,6 +1146,7 @@ extern void pagefault_out_of_memory(void);
>   * various contexts.
>   */
>  #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
> +#define SHOW_COMPACTION_STATS		(0x0002u)
>=20
>  extern void show_free_areas(unsigned int flags);
>  extern bool skip_free_areas_node(unsigned int flags, int nid);
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 1feed6a2b12a..c0ac5bd2c121 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -8,6 +8,7 @@
>  #include <linux/mm.h>
>  #include <linux/quicklist.h>
>  #include <linux/cma.h>
> +#include <linux/vm_event_item.h>
>=20
>  void show_mem(unsigned int filter)
>  {
> @@ -17,6 +18,19 @@ void show_mem(unsigned int filter)
>  	printk("Mem-Info:\n");
>  	show_free_areas(filter);
>=20
> +#ifdef CONFIG_COMPACTION
> +	if (filter & SHOW_COMPACTION_STATS) {
> +		printk("compaction_stall:%lu compaction_fail:%lu "
> +		       "compact_migrate_scanned:%lu compact_free_scanned:%lu "
> +		       "compact_isolated:%lu "
> +		       "pgmigrate_success:%lu pgmigrate_fail:%lu\n",
> +		       global_page_state(COMPACTSTALL),=20
global_page_state(COMPACTFAIL),
> +		       global_page_state(COMPACTMIGRATE_SCANNED),
> global_page_state(COMPACTFREE_SCANNED), +		     =20
> global_page_state(COMPACTISOLATED),
> +		       global_page_state(PGMIGRATE_SUCCESS),
> global_page_state(PGMIGRATE_FAIL)); +	}
> +#endif
> +
>  	for_each_online_pgdat(pgdat) {
>  		unsigned long flags;
>  		int zoneid;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 463cdd22d4e0..5e7a09f4dbc9 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -419,7 +419,7 @@ static void dump_header(struct oom_control *oc, struct
> task_struct *p) if (oc->memcg)
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else
> -		show_mem(SHOW_MEM_FILTER_NODES);
> +		show_mem(SHOW_MEM_FILTER_NODES | (oc->order)?SHOW_COMPACTION_STATS:0);
>  	if (sysctl_oom_dump_tasks)
>  		dump_tasks(oc->memcg, oc->nodemask);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9d46b65061be..adf0cb655827 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2999,6 +2999,8 @@ void warn_alloc_failed(gfp_t gfp_mask, unsigned int
> order, const char *fmt, ...) pr_warn("%s: page allocation failure:
> order:%u, mode:%#x(%pGg)\n", current->comm, order, gfp_mask, &gfp_mask);
>  	dump_stack();
> +	if (order)
> +		filter |=3D SHOW_COMPACTION_STATS;
>  	if (!should_suppress_show_mem())
>  		show_mem(filter);
>  }


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
