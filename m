Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id AFF956B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 21:21:29 -0400 (EDT)
Date: Wed, 18 Jul 2012 10:22:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120718012200.GA27770@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf Baechle <ralf@linux-mips.org>, minchan@kernel.org, mm-commits@vger.kernel.org, akpm@linux-foundation.org, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

Hi Andrew,

> 
> 
> The patch titled
>      Subject: memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix
> has been added to the -mm tree.  Its filename is
>      memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix
> 
> fix CONFIG_MEMORY_ISOLATION=n build:
> 
> mm/page_alloc.c: In function 'free_area_init_core':
> mm/page_alloc.c:4430: error: 'struct zone' has no member named
> 'nr_pageblock_isolate'

Sorry about that.
I sent a patch yesterday.

> 
> Is this really necessary?  Does the zone start out all-zeroes?  If not, can we
> make it do so?

Good point.
It can remove zap_zone_vm_stats and zone->flags = 0, too.
More important thing is that we could remove adding code to initialize
zero whenever we add new field to zone. So I look at the code.

In summary, IMHO, all is already initialie zero out but we need double
check in mips.

== hotplug ==

1) ia64 arch_alloc_nodedata uses kzalloc
2) generic_alloc_nodedata uses kzalloc

So it seems to be no problem.

== contig_page_data ==
1) bootmem 

struct pglist_data __refdata contig_page_data = {
         .bdata = &bootmem_node_data[0]
};
it initializes all data of zone to zero implicitly.

2) nobootmem

struct pglist_data __refdata contig_page_data;
EXPORT_SYMBOL(contig_page_data);

it initializes all data of zone to zero implicitly.

So both case isn't no problem.

== node_data ==

1) x86

In setup_node_data, it does memset.

2) ia64

fill_pernode does memset pernode

3) powerpc

careful_zallocation does memset so it initializes all data to zero.

4) parisc

struct node_map_data node_data[MAX_NUMNODES] __read_mostly;

So it initializes all data of zone to zero implicitly.

5) m32r 

pg_data_t m32r_node_data[MAX_NUMNODES];

So it initializes all data of zone to zero implicitly.

6) sh

setup_bootmem_node does memset.
So it initializes all data of zone to zero implicitly.

7) sparc

allocate_node_data does memset.
So it initializes all data of zone to zero implicitly.

8) alpha

pg_data_t node_data[MAX_NUMNODES];
EXPORT_SYMBOL(node_data);

So it initializes all data of zone to zero implicitly.

9) tile

struct pglist_data node_data[MAX_NUMNODES] __read_mostly;
EXPORT_SYMBOL(node_data);

So it initializes all data of zone to zero implicitly.

10) mips

node_mem_init 

it seems to use slot_freepfn for __node_data but doesn't initialize zero
but not sure. we needs double checks.

11) m68k

pg_data_t pg_data_map[MAX_NUMNODES];
EXPORT_SYMBOL(pg_data_map);

So it initializes all data of zone to zero implicitly.

> 
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/page_alloc.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN mm/page_alloc.c~memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix
> mm/page_alloc.c
> --- a/mm/page_alloc.c~memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix
> +++ a/mm/page_alloc.c
> @@ -4424,7 +4424,9 @@ static void __paginginit free_area_init_
>                 lruvec_init(&zone->lruvec, zone);
>                 zap_zone_vm_stats(zone);
>                 zone->flags = 0;
> +#ifdef CONFIG_MEMORY_ISOLATION
>                 zone->nr_pageblock_isolate = 0;
> +#endif
>                 if (!size)
>                         continue;
> 
> _
> Subject: Subject: memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix
> 
> Patches currently in -mm which might be from akpm@linux-foundation.org are
> 
> linux-next.patch
> linux-next-git-rejects.patch
> i-need-old-gcc.patch
> arch-alpha-kernel-systblss-remove-debug-check.patch
> arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
> arch-x86-kernel-cpu-perf_event_intel_uncoreh-make-uncore_pmu_hrtimer_interval-64-bit.patch
> sysfs-fail-dentry-revalidation-after-namespace-change-fix.patch
> thermal-add-generic-cpufreq-cooling-implementation.patch
> thermal-exynos5-add-exynos5-thermal-sensor-driver-support.patch
> thermal-exynos-register-the-tmu-sensor-with-the-kernel-thermal-layer.patch
> coredump-warn-about-unsafe-suid_dumpable-core_pattern-combo.patch
> mm.patch
> mm-make-vb_alloc-more-foolproof-fix.patch
> mm-hugetlb-add-new-hugetlb-cgroup-fix.patch
> mm-hugetlb-add-new-hugetlb-cgroup-fix-fix.patch
> hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix.patch
> hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix-fix.patch
> mm-memblockc-memblock_double_array-cosmetic-cleanups.patch
> memcg-make-mem_cgroup_force_empty_list-return-bool-fix.patch
> mm-fadvise-dont-return-einval-when-filesystem-cannot-implement-fadvise-checkpatch-fixes.patch
> memcg-rename-config-variables.patch
> memcg-rename-config-variables-fix-fix.patch
> mm-have-order-0-compaction-start-off-where-it-left-checkpatch-fixes.patch
> mm-have-order-0-compaction-start-off-where-it-left-v3-typo.patch
> memory-hotplug-fix-kswapd-looping-forever-problem-fix.patch
> memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch
> mm-memcg-fix-compaction-migration-failing-due-to-memcg-limits-checkpatch-fixes.patch
> memcg-prevent-oom-with-too-many-dirty-pages.patch
> avr32-mm-faultc-port-oom-changes-to-do_page_fault-fix.patch
> nmi-watchdog-fix-for-lockup-detector-breakage-on-resume.patch
> kernel-sysc-avoid-argv_freenull.patch
> kmsg-dev-kmsg-properly-return-possible-copy_from_user-failure.patch
> printk-add-generic-functions-to-find-kern_level-headers-fix.patch
> btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-fix.patch
> btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-checkpatch-fixes.patch
> lib-vsprintfc-remind-people-to-update-documentation-printk-formatstxt-when-adding-printk-formats.patch
> string-introduce-memweight-fix.patch
> drivers-rtc-rtc-ab8500c-use-uie-emulation-checkpatch-fixes.patch
> drivers-rtc-rtc-r9701c-check-that-r9701_set_datetime-succeeded.patch
> kernel-kmodc-document-call_usermodehelper_fns-a-bit.patch
> kmod-avoid-deadlock-from-recursive-kmod-call.patch
> fork-use-vma_pages-to-simplify-the-code-fix.patch
> revert-sched-fix-fork-error-path-to-not-crash.patch
> ipc-use-kconfig-options-for-__arch_want_ipc_parse_version.patch
> fs-cachefiles-add-support-for-large-files-in-filesystem-caching-fix.patch
> include-linux-aioh-cpp-c-conversions.patch
> fault-injection-add-selftests-for-cpu-and-memory-hotplug.patch
> journal_add_journal_head-debug.patch
> mutex-subsystem-synchro-test-module-fix.patch
> slab-leaks3-default-y.patch
> put_bh-debug.patch
> 
> --
> To unsubscribe from this list: send the line "unsubscribe mm-commits" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
