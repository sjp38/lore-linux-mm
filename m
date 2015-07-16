Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF96E2802F6
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 13:13:41 -0400 (EDT)
Received: by lahh5 with SMTP id h5so47380343lah.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 10:13:40 -0700 (PDT)
Received: from mail-la0-x236.google.com (mail-la0-x236.google.com. [2a00:1450:4010:c03::236])
        by mx.google.com with ESMTPS id u7si2323536lae.3.2015.07.16.10.13.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 10:13:39 -0700 (PDT)
Received: by lahh5 with SMTP id h5so47379780lah.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 10:13:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150714103108.GA6812@suse.de>
References: <20150714000910.GA8160@wfg-t540p.sh.intel.com>
	<20150714103108.GA6812@suse.de>
Date: Thu, 16 Jul 2015 20:13:38 +0300
Message-ID: <CALYGNiMUXMvvvi-+64Nd6Qb8Db2EiGZ26jbP8yotUHWS4uF1jg@mail.gmail.com>
Subject: Re: [mminit] [ INFO: possible recursive locking detected ]
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, nicstange@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>

On Tue, Jul 14, 2015 at 1:31 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Jul 14, 2015 at 08:09:10AM +0800, Fengguang Wu wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit is
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>
>
> Can you check if this patch addresses the problem please?
>
> ---8<---
> mm, meminit: replace rwsem with completion
>
> From: Nicolai Stange <nicstange@gmail.com>
>
> Commit 0e1cc95b4cc7 ("mm: meminit: finish initialisation of struct pages
> before basic setup") introduced a rwsem to signal completion of the
> initialization workers.
>
> Lockdep complains about possible recursive locking:
>   =============================================
>   [ INFO: possible recursive locking detected ]
>   4.1.0-12802-g1dc51b8 #3 Not tainted
>   ---------------------------------------------
>   swapper/0/1 is trying to acquire lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c7fb>] page_alloc_init_late+0xc7/0xe6
>
>   but task is already holding lock:
>   (pgdat_init_rwsem){++++.+},
>     at: [<ffffffff8424c772>] page_alloc_init_late+0x3e/0xe6
>
> Replace the rwsem by a completion together with an atomic
> "outstanding work counter".
>
> [peterz@infradead.org: Barrier removal on the grounds of being pointless]
> [mgorman@suse.de: Applied review feedback]
> Signed-off-by: Nicolai Stange <nicstange@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/page_alloc.c | 22 +++++++++++++++-------
>  1 file changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 506eac8b38af..a69e78c396a0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -18,7 +18,6 @@
>  #include <linux/mm.h>
>  #include <linux/swap.h>
>  #include <linux/interrupt.h>
> -#include <linux/rwsem.h>
>  #include <linux/pagemap.h>
>  #include <linux/jiffies.h>
>  #include <linux/bootmem.h>
> @@ -1062,7 +1061,15 @@ static void __init deferred_free_range(struct page *page,
>                 __free_pages_boot_core(page, pfn, 0);
>  }
>
> -static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
> +/* Completion tracking for deferred_init_memmap() threads */
> +static atomic_t pgdat_init_n_undone __initdata;
> +static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
> +
> +static inline void __init pgdat_init_report_one_done(void)
> +{
> +       if (atomic_dec_and_test(&pgdat_init_n_undone))
> +               complete(&pgdat_init_all_done_comp);
> +}
>
>  /* Initialise remaining memory on a node */
>  static int __init deferred_init_memmap(void *data)
> @@ -1079,7 +1086,7 @@ static int __init deferred_init_memmap(void *data)
>         const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
>
>         if (first_init_pfn == ULONG_MAX) {
> -               up_read(&pgdat_init_rwsem);
> +               pgdat_init_report_one_done();
>                 return 0;
>         }
>
> @@ -1179,7 +1186,8 @@ free_range:
>
>         pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
>                                         jiffies_to_msecs(jiffies - start));
> -       up_read(&pgdat_init_rwsem);
> +
> +       pgdat_init_report_one_done();
>         return 0;
>  }
>
> @@ -1187,14 +1195,14 @@ void __init page_alloc_init_late(void)
>  {pgdat_init_rwsempgdat_init_rwsempgdat_init_rwsem
>         int nid;
>
> +       /* There will be num_node_state(N_MEMORY) threads */
> +       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
>         for_each_node_state(nid, N_MEMORY) {
> -               down_read(&pgdat_init_rwsem);

Rw-sem have special "non-owner" mode for keeping lockdep away.
This should be enough:

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1079,7 +1079,7 @@ static int __init deferred_init_memmap(void *data)
        const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 --- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1079,7 +1079,7 @@ static int __init deferred_init_memmap(void *data)
        const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);

        if (first_init_pfn == ULONG_MAX) {
-               up_read(&pgdat_init_rwsem);
+               up_read_non_owner(&pgdat_init_rwsem);
                return 0;
        }

@@ -1179,7 +1179,7 @@ free_range:

        pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
                                        jiffies_to_msecs(jiffies - start));
-       up_read(&pgdat_init_rwsem);
+       up_read_non_owner(&pgdat_init_rwsem);
        return 0;
 }

@@ -1188,7 +1188,7 @@ void __init page_alloc_init_late(void)
        int nid;

        for_each_node_state(nid, N_MEMORY) {
-               down_read(&pgdat_init_rwsem);
+               down_read_non_owner(&pgdat_init_rwsem);
                kthread_run(deferred_init_memmap, NODE_DATA(nid),
"pgdatinit%d", nid);
        }


        if (first_init_pfn == ULONG_MAX) {
-               up_read(&pgdat_init_rwsem);
+               up_read_non_owner(&pgdat_init_rwsem);
                return 0;
        }

@@ -1179,7 +1179,7 @@ free_range:

        pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
                                        jiffies_to_msecs(jiffies - start));
-       up_read(&pgdat_init_rwsem);
+       up_read_non_owner(&pgdat_init_rwsem);
        return 0;
 }

@@ -1188,7 +1188,7 @@ void __init page_alloc_init_late(void)
        int nid;

        for_each_node_state(nid, N_MEMORY) {
-               down_read(&pgdat_init_rwsem);
+               down_read_non_owner(&pgdat_init_rwsem);
                kthread_run(deferred_init_memmap, NODE_DATA(nid),
"pgdatinit%d", nid);
        }


>                 kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
>         }
>
>         /* Block until all are initialised */
> -       down_write(&pgdat_init_rwsem);
> -       up_write(&pgdat_init_rwsem);
> +       wait_for_completion(&pgdat_init_all_done_comp);
>  }
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
