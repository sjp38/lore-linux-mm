Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AF2F6B0406
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:27:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b1so445326865pgc.5
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 02:27:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z195si30286575pgz.5.2016.12.22.02.27.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 02:27:21 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161214181850.GC16763@dhcp22.suse.cz>
	<201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
	<201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
	<20161219122738.GB427@tigerII.localdomain>
	<20161220153948.GA575@tigerII.localdomain>
In-Reply-To: <20161220153948.GA575@tigerII.localdomain>
Message-Id: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
Date: Thu, 22 Dec 2016 19:27:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky@gmail.com
Cc: mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

Sergey Senozhatsky wrote:
> On (12/19/16 21:27), Sergey Senozhatsky wrote:
> [..]
> >
> > I'll finish re-basing the patch set tomorrow.
> >
> 
> pushed
> 
> https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred
> 
> not tested. will test and send out the patch set tomorrow.
> 
>      -ss

Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
it turned out that your patch set does not solve this problem.

I was assuming that sending to consoles from printk() is offloaded to a kernel
thread dedicated for that purpose, but your patch set does not do it. As a result,
somebody who called out_of_memory() is still preempted by other threads consuming
CPU time due to cond_resched() from console_unlock() as demonstrated by below patch.

----------------------------------------
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -2099,6 +2099,9 @@ static inline int can_use_console(void)
 	return cpu_online(raw_smp_processor_id()) || have_callable_console();
 }
 
+extern bool oom_lock_resched;
+extern struct mutex oom_lock;
+
 /**
  * console_unlock - unlock the console system
  *
@@ -2211,8 +2214,11 @@ void console_unlock(void)
 		start_critical_timings();
 		printk_safe_exit(flags);
 
-		if (do_cond_resched)
+		if (do_cond_resched) {
+			oom_lock_resched = (__mutex_owner(&oom_lock) == current);
 			cond_resched();
+			oom_lock_resched = false;
+		}
 	}
 	console_locked = 0;
 
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3523,6 +3523,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	return false;
 }
 
+bool oom_lock_resched;
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -3694,10 +3696,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Make sure we know about allocations which stall for too long */
 	if (time_after(jiffies, alloc_start + stall_timeout)) {
-		warn_alloc(gfp_mask,
-			"page allocation stalls for %ums, order:%u",
-			jiffies_to_msecs(jiffies-alloc_start), order);
-		stall_timeout += 10 * HZ;
+		static DEFINE_RATELIMIT_STATE(stall_rs, HZ, 1);
+
+		if (__ratelimit(&stall_rs)) {
+			pr_warn("%s(%u): page allocation stalls for %ums, order:%u mode:%#x(%pGg) cond_resched_with_oom_lock=%u\n",
+				current->comm, current->pid, jiffies_to_msecs(jiffies - alloc_start),
+				order, gfp_mask, &gfp_mask, oom_lock_resched);
+			stall_timeout += 10 * HZ;
+		}
 	}
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
----------------------------------------

----------------------------------------
[  103.425129] mysqld invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), nodemask=0, order=0, oom_score_adj=0
[  103.508812] mysqld cpuset=/ mems_allowed=0
[  103.514111] CPU: 2 PID: 2300 Comm: mysqld Not tainted 4.9.0+ #100
[  103.517436] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  103.522379] Call Trace:
[  103.527731]  dump_stack+0x85/0xc9
[  103.532552]  dump_header+0x82/0x275
[  103.534901]  ? trace_hardirqs_on_caller+0xf9/0x1c0
[  103.537726]  ? trace_hardirqs_on+0xd/0x10
[  103.540217]  oom_kill_process+0x219/0x400
[  103.542729]  out_of_memory+0x13e/0x580
[  103.545162]  ? out_of_memory+0x20e/0x580
[  103.547603]  __alloc_pages_slowpath+0x7d4/0x8e6
[  103.550178]  ? get_page_from_freelist+0x15a/0xdc0
[  103.552808]  __alloc_pages_nodemask+0x456/0x4e0
[  103.555355]  alloc_pages_current+0x97/0x1b0
[  103.557750]  ? find_get_entry+0x5/0x300
[  103.559996]  __page_cache_alloc+0x15d/0x1a0
[  103.564859]  ? pagecache_get_page+0x2c/0x2b0
[  103.567258]  filemap_fault+0x48e/0x6d0
[  103.569444]  ? filemap_fault+0x339/0x6d0
[  103.571698]  xfs_filemap_fault+0x71/0x1e0 [xfs]
[  103.574125]  __do_fault+0x21/0xa0
[  103.576075]  ? _raw_spin_unlock+0x27/0x40
[  103.578273]  handle_mm_fault+0xee9/0x1180
[  103.580437]  ? handle_mm_fault+0x5e/0x1180
[  103.582634]  __do_page_fault+0x24a/0x530
[  103.584710]  do_page_fault+0x30/0x80
[  103.586682]  page_fault+0x28/0x30
[  103.588497] RIP: 0033:0x7f3b9d66d5d0
[  103.590410] RSP: 002b:00007f3b7ffc9c88 EFLAGS: 00010246
[  103.592857] RAX: 0000000000000001 RBX: 0000560ff6f1afa0 RCX: 00007f3b9d668a82
[  103.596038] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000560ff6f162e0
[  103.599490] RBP: 00007f3b7ffc9d80 R08: 0000560ff6f162e0 R09: 0000000000000001
[  103.602675] R10: 00007f3b7ffc9ce0 R11: 0000000000000000 R12: 0000000000000003
[  103.605821] R13: 00007f3b7ffc9ce0 R14: 000000000000006e R15: 0000560ff6f16200
[  103.609007] Mem-Info:
[  103.621042] __alloc_pages_slowpath: 39544 callbacks suppressed
[  103.621046] irqbalance(483): page allocation stalls for 14949ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  104.621663] __alloc_pages_slowpath: 41790 callbacks suppressed
[  104.621679] systemd(1): page allocation stalls for 15951ms, order:0 mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) cond_resched_with_oom_lock=1
[  105.622679] __alloc_pages_slowpath: 42194 callbacks suppressed
[  105.622683] postgres(2210): page allocation stalls for 16864ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  106.623754] __alloc_pages_slowpath: 39712 callbacks suppressed
[  106.623758] postgres(1190): page allocation stalls for 13337ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  107.624849] __alloc_pages_slowpath: 35250 callbacks suppressed
[  107.624853] crond(503): page allocation stalls for 18950ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  108.625924] __alloc_pages_slowpath: 29191 callbacks suppressed
[  108.625928] master(2162): page allocation stalls for 16786ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  109.626959] __alloc_pages_slowpath: 46005 callbacks suppressed
[  109.626963] postgres(2212): page allocation stalls for 16623ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  110.628011] __alloc_pages_slowpath: 53990 callbacks suppressed
[  110.628015] ksmtuned(507): page allocation stalls for 21856ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  111.628588] __alloc_pages_slowpath: 49833 callbacks suppressed
[  111.628592] in:imjournal(885): page allocation stalls for 22956ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  112.629667] __alloc_pages_slowpath: 48069 callbacks suppressed
[  112.629671] crond(503): page allocation stalls for 23955ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  113.630720] __alloc_pages_slowpath: 50438 callbacks suppressed
[  113.630724] master(2162): page allocation stalls for 21791ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  114.631785] __alloc_pages_slowpath: 50191 callbacks suppressed
[  114.631789] systemd(1): page allocation stalls for 25961ms, order:0 mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) cond_resched_with_oom_lock=1
[  115.632884] __alloc_pages_slowpath: 47058 callbacks suppressed
[  115.632888] postgres(2211): page allocation stalls for 26874ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  116.633937] __alloc_pages_slowpath: 43322 callbacks suppressed
[  116.633940] postgres(1190): page allocation stalls for 23347ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  117.634987] __alloc_pages_slowpath: 41755 callbacks suppressed
[  117.634991] irqbalance(483): page allocation stalls for 28963ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  118.634021] active_anon:313193 inactive_anon:3457 isolated_anon:0
[  118.634021]  active_file:256 inactive_file:337 isolated_file:32
[  118.634021]  unevictable:0 dirty:9 writeback:0 unstable:0
[  118.634021]  slab_reclaimable:8896 slab_unreclaimable:31623
[  118.634021]  mapped:1988 shmem:3527 pagetables:8669 bounce:0
[  118.634021]  free:12797 free_pcp:214 free_cma:0
[  118.636046] __alloc_pages_slowpath: 40420 callbacks suppressed
[  118.636050] gmain(615): page allocation stalls for 29979ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=0
[  119.636632] __alloc_pages_slowpath: 59369 callbacks suppressed
[  119.636636] in:imjournal(885): page allocation stalls for 30964ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  120.637687] __alloc_pages_slowpath: 55694 callbacks suppressed
[  120.637690] ksmtuned(507): page allocation stalls for 31866ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  121.638769] __alloc_pages_slowpath: 51519 callbacks suppressed
[  121.638772] postgres(2212): page allocation stalls for 28635ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  122.639817] __alloc_pages_slowpath: 50601 callbacks suppressed
[  122.639820] crond(503): page allocation stalls for 33965ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  123.640913] __alloc_pages_slowpath: 51169 callbacks suppressed
[  123.640916] lpqd(2332): page allocation stalls for 28749ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  124.641949] __alloc_pages_slowpath: 54501 callbacks suppressed
[  124.641953] gmain(615): page allocation stalls for 35985ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  125.643026] __alloc_pages_slowpath: 54196 callbacks suppressed
[  125.643030] auditd(435): page allocation stalls for 26271ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  126.643593] __alloc_pages_slowpath: 54450 callbacks suppressed
[  126.643597] systemd-hostnam(571): page allocation stalls for 19483ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  127.644663] __alloc_pages_slowpath: 53238 callbacks suppressed
[  127.644666] tuned(2193): page allocation stalls for 39011ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  128.645733] __alloc_pages_slowpath: 53215 callbacks suppressed
[  128.645737] systemd-hostnam(571): page allocation stalls for 21485ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  129.646815] __alloc_pages_slowpath: 60025 callbacks suppressed
[  129.646818] in:imjournal(885): page allocation stalls for 40974ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  130.647865] __alloc_pages_slowpath: 58585 callbacks suppressed
[  130.647869] postgres(2212): page allocation stalls for 37644ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  131.648927] __alloc_pages_slowpath: 56303 callbacks suppressed
[  131.648930] systemd-logind(501): page allocation stalls for 11659ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  132.649994] __alloc_pages_slowpath: 52335 callbacks suppressed
[  132.649998] ksmtuned(507): page allocation stalls for 43878ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  133.651052] __alloc_pages_slowpath: 51745 callbacks suppressed
[  133.651056] lpqd(2332): page allocation stalls for 38759ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  134.651623] __alloc_pages_slowpath: 52909 callbacks suppressed
[  134.651626] tuned(2193): page allocation stalls for 46018ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  135.652717] __alloc_pages_slowpath: 52653 callbacks suppressed
[  135.652721] systemd-journal(383): page allocation stalls for 47032ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  136.653780] __alloc_pages_slowpath: 52888 callbacks suppressed
[  136.653784] systemd-journal(383): page allocation stalls for 48033ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  137.654858] __alloc_pages_slowpath: 54692 callbacks suppressed
[  137.654862] lpqd(2332): page allocation stalls for 42763ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  138.655883] __alloc_pages_slowpath: 55939 callbacks suppressed
[  138.655886] postgres(1190): page allocation stalls for 45369ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  139.656972] __alloc_pages_slowpath: 62010 callbacks suppressed
[  139.656975] auditd(435): page allocation stalls for 40285ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  140.658038] __alloc_pages_slowpath: 64428 callbacks suppressed
[  140.658042] tuned(2193): page allocation stalls for 52024ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  141.658599] __alloc_pages_slowpath: 65734 callbacks suppressed
[  141.658603] NetworkManager(537): page allocation stalls for 52973ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  142.659654] __alloc_pages_slowpath: 67122 callbacks suppressed
[  142.659657] systemd-hostnam(571): page allocation stalls for 35499ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  143.660751] __alloc_pages_slowpath: 64515 callbacks suppressed
[  143.660755] pickup(2169): page allocation stalls for 11784ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  144.661796] __alloc_pages_slowpath: 62998 callbacks suppressed
[  144.661799] in:imjournal(885): page allocation stalls for 55989ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  145.662860] __alloc_pages_slowpath: 58703 callbacks suppressed
[  145.662863] NetworkManager(537): page allocation stalls for 56977ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  146.663959] __alloc_pages_slowpath: 60013 callbacks suppressed
[  146.663962] systemd-logind(501): page allocation stalls for 26674ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  147.664996] __alloc_pages_slowpath: 57511 callbacks suppressed
[  147.664999] ksmtuned(507): page allocation stalls for 58893ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  148.666057] __alloc_pages_slowpath: 55971 callbacks suppressed
[  148.666061] master(2162): page allocation stalls for 56826ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  149.666631] __alloc_pages_slowpath: 62040 callbacks suppressed
[  149.666634] postgres(1190): page allocation stalls for 56380ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  150.667694] __alloc_pages_slowpath: 64495 callbacks suppressed
[  150.667698] systemd-journal(383): page allocation stalls for 62047ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  151.668761] __alloc_pages_slowpath: 65855 callbacks suppressed
[  151.668765] tuned(2193): page allocation stalls for 63035ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  152.669854] __alloc_pages_slowpath: 67093 callbacks suppressed
[  152.669857] dbus-daemon(492): page allocation stalls for 63895ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  153.670902] __alloc_pages_slowpath: 66886 callbacks suppressed
[  153.670906] mysqld(2238): page allocation stalls for 64927ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  154.671963] __alloc_pages_slowpath: 67141 callbacks suppressed
[  154.671966] gmain(615): page allocation stalls for 66015ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  155.673055] __alloc_pages_slowpath: 67300 callbacks suppressed
[  155.673058] NetworkManager(537): page allocation stalls for 66987ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  156.673615] __alloc_pages_slowpath: 67163 callbacks suppressed
[  156.673619] postgres(1190): page allocation stalls for 63387ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  157.674661] __alloc_pages_slowpath: 67216 callbacks suppressed
[  157.674665] postgres(1190): page allocation stalls for 64388ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  158.675760] __alloc_pages_slowpath: 64137 callbacks suppressed
[  158.675763] auditd(435): page allocation stalls for 59304ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  159.676802] __alloc_pages_slowpath: 63812 callbacks suppressed
[  159.676805] mysqld(2240): page allocation stalls for 70645ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  160.678024] __alloc_pages_slowpath: 63074 callbacks suppressed
[  160.678028] systemd-logind(501): page allocation stalls for 40688ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  161.678962] __alloc_pages_slowpath: 64160 callbacks suppressed
[  161.678966] mysqld(2238): page allocation stalls for 72935ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  162.680008] __alloc_pages_slowpath: 63952 callbacks suppressed
[  162.680012] gmain(615): page allocation stalls for 74023ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  163.680565] __alloc_pages_slowpath: 65331 callbacks suppressed
[  163.680568] systemd-hostnam(571): page allocation stalls for 56520ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  164.681997] __alloc_pages_slowpath: 67274 callbacks suppressed
[  164.682005] dbus-daemon(492): page allocation stalls for 75907ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  165.682703] __alloc_pages_slowpath: 67081 callbacks suppressed
[  165.682707] irqbalance(483): page allocation stalls for 77011ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  166.683767] __alloc_pages_slowpath: 67006 callbacks suppressed
[  166.683770] postgres(1190): page allocation stalls for 73397ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  167.684838] __alloc_pages_slowpath: 63439 callbacks suppressed
[  167.684842] postgres(2210): page allocation stalls for 78926ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  168.685904] __alloc_pages_slowpath: 63998 callbacks suppressed
[  168.685907] lpqd(2332): page allocation stalls for 73794ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  169.686974] __alloc_pages_slowpath: 64142 callbacks suppressed
[  169.686978] ksmtuned(507): page allocation stalls for 80915ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  170.687783] __alloc_pages_slowpath: 63814 callbacks suppressed
[  170.687787] irqbalance(483): page allocation stalls for 82016ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  171.688605] __alloc_pages_slowpath: 64212 callbacks suppressed
[  171.688608] postgres(2210): page allocation stalls for 82930ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  172.689672] __alloc_pages_slowpath: 61346 callbacks suppressed
[  172.689676] systemd(1): page allocation stalls for 84019ms, order:0 mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) cond_resched_with_oom_lock=1
[  173.690749] __alloc_pages_slowpath: 65162 callbacks suppressed
[  173.690753] NetworkManager(537): page allocation stalls for 85005ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  174.691815] __alloc_pages_slowpath: 67004 callbacks suppressed
[  174.691818] irqbalance(483): page allocation stalls for 86020ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  175.692873] __alloc_pages_slowpath: 67376 callbacks suppressed
[  175.692877] gmain(615): page allocation stalls for 87036ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  176.693970] __alloc_pages_slowpath: 67345 callbacks suppressed
[  176.693973] mysqld(2238): page allocation stalls for 87950ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  177.695007] __alloc_pages_slowpath: 67219 callbacks suppressed
[  177.695010] systemd-logind(501): page allocation stalls for 57705ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  178.635236] Node 0 active_anon:1252772kB inactive_anon:13828kB active_file:1024kB inactive_file:1348kB unevictable:0kB isolated(anon):0kB isolated(file):128kB mapped:7952kB dirty:36kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 892928kB anon_thp: 14108kB writeback_tmp:0kB unstable:0kB pages_scanned:3921 all_unreclaimable? yes
[  178.695575] __alloc_pages_slowpath: 66566 callbacks suppressed
[  178.695579] ksmtuned(507): page allocation stalls for 89924ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  179.283906] Node 0 DMA free:6700kB min:440kB low:548kB high:656kB active_anon:9144kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:28kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  179.299970] lowmem_reserve[]: 0 1565 1565 1565
[  179.482583] Node 0 DMA32 free:44488kB min:44612kB low:55764kB high:66916kB active_anon:1243628kB inactive_anon:13828kB active_file:1024kB inactive_file:1348kB unevictable:0kB writepending:36kB present:2080640kB managed:1603468kB mlocked:0kB slab_reclaimable:35584kB slab_unreclaimable:126460kB kernel_stack:17936kB pagetables:34648kB bounce:0kB free_pcp:856kB local_pcp:116kB free_cma:0kB
[  179.696680] __alloc_pages_slowpath: 58011 callbacks suppressed
[  179.696688] a.out(2743): page allocation stalls for 91086ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE) cond_resched_with_oom_lock=1
[  180.548518] lowmem_reserve[]: 0 0 0 0
[  180.697713] __alloc_pages_slowpath: 64542 callbacks suppressed
[  180.697717] gmain(615): page allocation stalls for 92041ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  181.698801] __alloc_pages_slowpath: 66996 callbacks suppressed
[  181.698805] lpqd(2332): page allocation stalls for 86807ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  182.699853] __alloc_pages_slowpath: 67094 callbacks suppressed
[  182.699857] in:imjournal(885): page allocation stalls for 94027ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  183.700923] __alloc_pages_slowpath: 67039 callbacks suppressed
[  183.700926] systemd(1): page allocation stalls for 95030ms, order:0 mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) cond_resched_with_oom_lock=1
[  184.702000] __alloc_pages_slowpath: 67067 callbacks suppressed
[  184.702004] NetworkManager(537): page allocation stalls for 96016ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  185.703062] __alloc_pages_slowpath: 66792 callbacks suppressed
[  185.703066] systemd-hostnam(571): page allocation stalls for 78542ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  186.689089] Node 0 DMA: 1*4kB (U) 1*8kB (M) 0*16kB 1*32kB (U) 2*64kB (UM) 1*128kB (U) 1*256kB (U) 0*512kB 2*1024kB (UM) 0*2048kB 1*4096kB (M) = 6700kB
[  186.703605] __alloc_pages_slowpath: 67093 callbacks suppressed
[  186.703608] systemd(1): page allocation stalls for 98033ms, order:0 mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO) cond_resched_with_oom_lock=1
[  187.704669] __alloc_pages_slowpath: 66243 callbacks suppressed
[  187.704672] crond(503): page allocation stalls for 99030ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  188.705740] __alloc_pages_slowpath: 67397 callbacks suppressed
[  188.705744] postgres(2211): page allocation stalls for 99947ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  189.706854] __alloc_pages_slowpath: 66839 callbacks suppressed
[  189.706874] a.out(2653): page allocation stalls for 100985ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK) cond_resched_with_oom_lock=1
[  190.707883] __alloc_pages_slowpath: 66947 callbacks suppressed
[  190.707886] pickup(2169): page allocation stalls for 58831ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  191.662483] Node 0 DMA32: 420*4kB (U) 315*8kB (UM) 172*16kB (UE) 335*32kB (UE) 99*64kB (UE) 26*128kB (UME) 9*256kB (UME) 11*512kB (UME) 9*1024kB (ME) 0*2048kB 0*4096kB = 44488kB
[  191.708840] __alloc_pages_slowpath: 66618 callbacks suppressed
[  191.708848] crond(503): page allocation stalls for 103034ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  192.710030] __alloc_pages_slowpath: 66453 callbacks suppressed
[  192.710034] NetworkManager(537): page allocation stalls for 104024ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  193.710566] __alloc_pages_slowpath: 66903 callbacks suppressed
[  193.710570] NetworkManager(537): page allocation stalls for 105025ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  194.712985] __alloc_pages_slowpath: 66683 callbacks suppressed
[  194.712988] tuned(2193): page allocation stalls for 106079ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  195.713716] __alloc_pages_slowpath: 67736 callbacks suppressed
[  195.713719] postgres(2210): page allocation stalls for 106955ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  196.714811] __alloc_pages_slowpath: 67054 callbacks suppressed
[  196.714816] systemd-logind(501): page allocation stalls for 76725ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  197.715840] __alloc_pages_slowpath: 67059 callbacks suppressed
[  197.715843] tuned(2193): page allocation stalls for 109082ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  198.716913] __alloc_pages_slowpath: 66687 callbacks suppressed
[  198.716917] auditd(435): page allocation stalls for 99345ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  199.718012] __alloc_pages_slowpath: 67443 callbacks suppressed
[  199.718016] postgres(2211): page allocation stalls for 110959ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  200.719049] __alloc_pages_slowpath: 67103 callbacks suppressed
[  200.719053] postgres(2210): page allocation stalls for 111960ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  201.719617] __alloc_pages_slowpath: 65347 callbacks suppressed
[  201.719620] crond(503): page allocation stalls for 113045ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  202.720681] __alloc_pages_slowpath: 67782 callbacks suppressed
[  202.720685] systemd-logind(501): page allocation stalls for 82731ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  203.721761] __alloc_pages_slowpath: 67320 callbacks suppressed
[  203.721765] crond(503): page allocation stalls for 115047ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  204.722809] __alloc_pages_slowpath: 67440 callbacks suppressed
[  204.722812] lpqd(2332): page allocation stalls for 109831ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  205.723878] __alloc_pages_slowpath: 67259 callbacks suppressed
[  205.723882] dbus-daemon(492): page allocation stalls for 116949ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  206.724974] __alloc_pages_slowpath: 66817 callbacks suppressed
[  206.724978] postgres(2210): page allocation stalls for 117966ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  207.726015] __alloc_pages_slowpath: 66699 callbacks suppressed
[  207.726019] auditd(435): page allocation stalls for 108354ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  208.726611] __alloc_pages_slowpath: 67461 callbacks suppressed
[  208.726614] systemd-logind(501): page allocation stalls for 88737ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  209.727663] __alloc_pages_slowpath: 67552 callbacks suppressed
[  209.727667] NetworkManager(537): page allocation stalls for 121042ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  210.728724] __alloc_pages_slowpath: 67554 callbacks suppressed
[  210.728727] master(2162): page allocation stalls for 118889ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  211.729782] __alloc_pages_slowpath: 66883 callbacks suppressed
[  211.729786] systemd-hostnam(571): page allocation stalls for 104569ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  212.730856] __alloc_pages_slowpath: 67060 callbacks suppressed
[  212.730859] tuned(2193): page allocation stalls for 124097ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  213.731957] __alloc_pages_slowpath: 67212 callbacks suppressed
[  213.731960] postgres(2211): page allocation stalls for 124973ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  214.732979] __alloc_pages_slowpath: 66906 callbacks suppressed
[  214.732983] NetworkManager(537): page allocation stalls for 126047ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  215.733541] __alloc_pages_slowpath: 67186 callbacks suppressed
[  215.733544] postgres(2210): page allocation stalls for 126975ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  216.734628] __alloc_pages_slowpath: 67116 callbacks suppressed
[  216.734631] systemd-logind(501): page allocation stalls for 96745ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  217.735688] __alloc_pages_slowpath: 67045 callbacks suppressed
[  217.735692] systemd-logind(501): page allocation stalls for 97746ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  218.736777] __alloc_pages_slowpath: 64296 callbacks suppressed
[  218.736781] NetworkManager(537): page allocation stalls for 130051ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=1
[  219.704510] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[  219.711197] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  219.716162] 4152 total pagecache pages
[  219.724755] 0 pages in swap cache
[  219.727428] Swap cache stats: add 0, delete 0, find 0/0
[  219.730665] Free swap  = 0kB
[  219.733323] Total swap = 0kB
[  219.739283] 524157 pages RAM
[  219.741645] 0 pages HighMem/MovableOnly
[  219.744292] 119314 pages reserved
[  219.745254] __alloc_pages_slowpath: 64179 callbacks suppressed
[  219.745257] mysqld(2234): page allocation stalls for 130829ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) cond_resched_with_oom_lock=0
[  219.759890] 0 pages cma reserved
[  219.762306] 0 pages hwpoisoned
[  219.773275] Out of memory: Kill process 2706 (a.out) score 997 or sacrifice child
[  219.777233] Killed process 2706 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  219.827687] oom_reaper: reaped process 2706 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------------------------------------

Pretending out_of_memory() as if under NMI context is ridicurous.
Running out_of_memory() with preemption disabled
( http://lkml.kernel.org/r/201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp )
was not accepted.
Adding exceptions like

-	do_cond_resched = console_may_schedule;
+	do_cond_resched = console_may_schedule && __mutex_owner(&oom_lock) != current;

will not be smart.

Now, what options are left other than replacing !mutex_trylock(&oom_lock)
with mutex_lock_killable(&oom_lock) which also stops wasting CPU time?
Are we waiting for offloading sending to consoles?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
