Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9C53C828DE
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 06:23:22 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id cy9so256736196pac.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 03:23:22 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hv6si31251777pac.145.2016.01.07.03.23.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jan 2016 03:23:21 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
	<1452094975-551-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1452094975-551-2-git-send-email-mhocko@kernel.org>
Message-Id: <201601072023.AGC51005.QSFFHOVMJOFLtO@I-love.SAKURA.ne.jp>
Date: Thu, 7 Jan 2016 20:23:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> @@ -607,17 +748,25 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD))
> -			continue;
>  		if (is_global_init(p))
>  			continue;
> -		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +		if (unlikely(p->flags & PF_KTHREAD) ||
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +			/*
> +			 * We cannot use oom_reaper for the mm shared by this
> +			 * process because it wouldn't get killed and so the
> +			 * memory might be still used.
> +			 */
> +			can_oom_reap = false;
>  			continue;
> -
> +		}
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>  	}
>  	rcu_read_unlock();

According to commit a2b829d95958da20 ("mm/oom_kill.c: avoid attempting
to kill init sharing same memory"), below patch is needed for avoid
killing init process with SIGSEGV.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9548dce..9832f3f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -784,9 +784,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
  			continue;
  		if (same_thread_group(p, victim))
  			continue;
-		if (is_global_init(p))
-			continue;
-		if (unlikely(p->flags & PF_KTHREAD) ||
+		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
  		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
  			/*
  			 * We cannot use oom_reaper for the mm shared by this
----------

----------
#define _GNU_SOURCE
#include <stdlib.h>
#include <unistd.h>
#include <sched.h>

static int child(void *unused)
{
	char *buf = NULL;
	unsigned long i;
	unsigned long size = 0;
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	for (i = 0; i < size; i += 4096)
		buf[i] = '\0'; /* Will cause OOM due to overcommit */
	return 0;
}

int main(int argc, char *argv[])
{
	char *cp = malloc(8192);
	if (cp && clone(child, cp + 8192, CLONE_VM, NULL) > 0)
		while (1) {
			sleep(1);
			write(1, cp, 1);
		}
	return 0;
}
----------
[    2.954212] init invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
[    2.959697] init cpuset=/ mems_allowed=0
[    2.961927] CPU: 0 PID: 98 Comm: init Not tainted 4.4.0-rc8-next-20160106+ #28
[    2.965738] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[    2.971239]  0000000000000000 0000000075c7a38e ffffffff812ab8c4 ffff88003bd6fd48
[    2.975461]  ffffffff8117eb58 0000000000000000 ffff88003bd6fd48 0000000000000000
[    2.979572]  ffffffff810c5630 0000000000000003 0000000000000202 0000000000000549
[    2.983525] Call Trace:
[    2.984813]  [<ffffffff812ab8c4>] ? dump_stack+0x40/0x5c
[    2.987497]  [<ffffffff8117eb58>] ? dump_header+0x58/0x1ed
[    2.990285]  [<ffffffff810c5630>] ? ktime_get+0x30/0x90
[    2.992963]  [<ffffffff810fd225>] ? delayacct_end+0x35/0x60
[    2.995884]  [<ffffffff81113dc3>] ? oom_kill_process+0x323/0x460
[    2.998944]  [<ffffffff81114060>] ? out_of_memory+0x110/0x480
[    3.001833]  [<ffffffff811197ad>] ? __alloc_pages_nodemask+0xbbd/0xd60
[    3.005400]  [<ffffffff8115d951>] ? alloc_pages_vma+0xb1/0x220
[    3.008391]  [<ffffffff811780ac>] ? mem_cgroup_commit_charge+0x7c/0xf0
[    3.011668]  [<ffffffff8113ce86>] ? handle_mm_fault+0x1036/0x1460
[    3.014782]  [<ffffffff81056c97>] ? __do_page_fault+0x177/0x430
[    3.017770]  [<ffffffff81056f7b>] ? do_page_fault+0x2b/0x70
[    3.020615]  [<ffffffff815a9198>] ? page_fault+0x28/0x30
[    3.023359] Mem-Info:
[    3.024575] active_anon:244334 inactive_anon:0 isolated_anon:0
[    3.024575]  active_file:0 inactive_file:0 isolated_file:0
[    3.024575]  unevictable:561 dirty:0 writeback:0 unstable:0
[    3.024575]  slab_reclaimable:94 slab_unreclaimable:2386
[    3.024575]  mapped:275 shmem:0 pagetables:477 bounce:0
[    3.024575]  free:1924 free_pcp:304 free_cma:0
[    3.040715] Node 0 DMA free:3936kB min:60kB low:72kB high:88kB active_anon:11260kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:64kB kernel_stack:0kB pagetables:564kB unstable:0kB bounce:0kB 
free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[    3.062251] lowmem_reserve[]: 0 969 969 969
[    3.064752] Node 0 DMA32 free:3760kB min:3812kB low:4764kB high:5716kB active_anon:966076kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:2244kB isolated(anon):0kB 
isolated(file):0kB present:1032064kB managed:994872kB mlocked:0kB dirty:0kB writeback:0kB mapped:1100kB shmem:0kB slab_reclaimable:372kB slab_unreclaimable:9480kB kernel_stack:2192kB pagetables:1344kB 
unstable:0kB bounce:0kB free_pcp:1216kB local_pcp:244kB free_cma:0kB writeback_tmp:0kB pages_scanned:2244 all_unreclaimable? yes
[    3.087299] lowmem_reserve[]: 0 0 0 0
[    3.089437] Node 0 DMA: 2*4kB (ME) 1*8kB (E) 3*16kB (UME) 3*32kB (UME) 3*64kB (UME) 2*128kB (ME) 3*256kB (UME) 3*512kB (UME) 1*1024kB (E) 0*2048kB 0*4096kB = 3936kB
[    3.098058] Node 0 DMA32: 4*4kB (UME) 4*8kB (UME) 2*16kB (UE) 1*32kB (M) 1*64kB (M) 2*128kB (UE) 1*256kB (E) 0*512kB 3*1024kB (UME) 0*2048kB 0*4096kB = 3760kB
[    3.106371] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[    3.110846] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[    3.115169] 561 total pagecache pages
[    3.117051] 0 pages in swap cache
[    3.118764] Swap cache stats: add 0, delete 0, find 0/0
[    3.121414] Free swap  = 0kB
[    3.122958] Total swap = 0kB
[    3.124468] 262013 pages RAM
[    3.125962] 0 pages HighMem/MovableOnly
[    3.127932] 9319 pages reserved
[    3.129597] 0 pages cma reserved
[    3.131258] 0 pages hwpoisoned
[    3.132836] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[    3.137232] [   98]     0    98   279607   244400     489       5        0             0 init
[    3.141664] Out of memory: Kill process 98 (init) score 940 or sacrifice child
[    3.145346] Killed process 98 (init) total-vm:1118428kB, anon-rss:977464kB, file-rss:136kB, shmem-rss:0kB
[    3.416105] init[1]: segfault at 0 ip           (null) sp 00007ffd484cf5f0 error 14 in init[400000+1000]
[    3.439074] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    3.439074]
[    3.450193] Kernel Offset: disabled
[    3.456259] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    3.456259]
----------

Guessing from commit 1e99bad0d9c12a4a ("oom: kill all threads sharing oom
killed task's mm"), the

	if (same_thread_group(p, victim))
		continue;

test is for avoiding "Kill process %d (%s) sharing same memory\n" on the
victim's mm, but that printk() was already removed. Thus, I think we have
nothing to do (or can remove it if we don't mind sending SIGKILL twice).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
