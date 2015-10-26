Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0865A82F64
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 13:46:49 -0400 (EDT)
Received: by qgeo38 with SMTP id o38so126525159qge.0
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 10:46:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 59si27335888qgg.109.2015.10.26.10.46.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 10:46:48 -0700 (PDT)
Date: Mon, 26 Oct 2015 13:46:46 -0400
From: Aristeu Rozanski <arozansk@redhat.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151026174645.GQ15046@redhat.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
 <20151026160111.GA2214@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151026160111.GA2214@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Oct 26, 2015 at 12:01:11PM -0400, Johannes Weiner wrote:
> I think this makes sense.
> 
> The high volume log output is not just annoying, we have also had
> reports from people whose machines locked up as they tried to log
> hundreds of containers through a low-bandwidth serial console.
> 
> Could you include sample output of before and after in the changelog
> to provide an immediate comparison on what we are saving?

Sure, at the end of email.

> Should we make the knob specific to the stack dump or should it be
> more generic, so that we could potentially save even more output?

Perhaps what Michal proposed, to use printk() levels.

Sure:
wc -l on the logs:
  47 /tmp/today.txt
  27 /tmp/without_dump_stack.txt

as is:
--------------------------------------------
[248285.939528] memhog invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
[248285.939531] memhog cpuset=/ mems_allowed=0
[248285.939535] CPU: 1 PID: 2130 Comm: memhog Not tainted 4.3.0-rc6+ #132
[248285.939536] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[248285.939538]  ffff88007c037d58 ffffffff812bda53 ffff8800313990c0 ffffffff811b2f3a
[248285.939539]  0000000000001288 ffffffff811082a9 0000000000000001 ffff88007fffbb28
[248285.939541]  0000000000000003 0000000000000206 ffff88007c037d58 0000000000000000
[248285.939542] Call Trace:
[248285.939548]  [<ffffffff812bda53>] ? dump_stack+0x40/0x5d
[248285.939550]  [<ffffffff811b2f3a>] ? dump_header+0x76/0x1e1
[248285.939553]  [<ffffffff811082a9>] ? delayacct_end+0x39/0x60
[248285.939556]  [<ffffffff8114cfae>] ? oom_kill_process+0x1be/0x380
[248285.939559]  [<ffffffff8124414e>] ? security_capable_noaudit+0x3e/0x60
[248285.939563]  [<ffffffff8114d60b>] ? out_of_memory+0x44b/0x460
[248285.939565]  [<ffffffff81152c63>] ? __alloc_pages_nodemask+0x893/0x9e0
[248285.939567]  [<ffffffff81195a77>] ? alloc_pages_vma+0xc7/0x230
[248285.939570]  [<ffffffff811ad1bc>] ? mem_cgroup_try_charge+0x7c/0x1a0
[248285.939572]  [<ffffffff81177d4a>] ? handle_mm_fault+0x130a/0x1680
[248285.939574]  [<ffffffff8117d516>] ? do_mmap+0x336/0x420
[248285.939575]  [<ffffffff8116585c>] ? vm_mmap_pgoff+0x9c/0xc0
[248285.939578]  [<ffffffff8105bf56>] ? __do_page_fault+0x186/0x410
[248285.939581]  [<ffffffff81529b58>] ? async_page_fault+0x28/0x30
[248285.939582] Mem-Info:
[248285.939585] active_anon:501670 inactive_anon:43 isolated_anon:0
                 active_file:16 inactive_file:21 isolated_file:0
                 unevictable:0 dirty:9 writeback:0 unstable:0
                 slab_reclaimable:1780 slab_unreclaimable:2045
                 mapped:6 shmem:59 pagetables:1474 bounce:0
                 free:3388 free_pcp:0 free_cma:0
[248285.939587] Node 0 DMA free:7988kB min:40kB low:48kB high:60kB active_anon:7540kB inactive_anon:4kB active_file:8kB inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:12kB shmem:12kB slab_reclaimable:28kB slab_unreclaimable:56kB kernel_stack:64kB pagetables:56kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:100 all_unreclaimable? yes
[248285.939590] lowmem_reserve[]: 0 1988 1988 1988
[248285.939592] Node 0 DMA32 free:5564kB min:5588kB low:6984kB high:8380kB active_anon:1999140kB inactive_anon:168kB active_file:56kB inactive_file:76kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080760kB managed:2038396kB mlocked:0kB dirty:36kB writeback:0kB mapped:12kB shmem:224kB slab_reclaimable:7092kB slab_unreclaimable:8124kB kernel_stack:2448kB pagetables:5840kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1260 all_unreclaimable? yes
[248285.939595] lowmem_reserve[]: 0 0 0 0
[248285.939597] Node 0 DMA: 6*4kB (UEM) 2*8kB (UE) 5*16kB (UE) 0*32kB 5*64kB (UE) 5*128kB (UEM) 3*256kB (UE) 2*512kB (EM) 3*1024kB (UE) 1*2048kB (U) 0*4096kB = 7992kB
[248285.939604] Node 0 DMA32: 197*4kB (UEM) 46*8kB (UE) 11*16kB (UE) 4*32kB (UEM) 0*64kB 3*128kB (UEM) 1*256kB (M) 3*512kB (U) 2*1024kB (UM) 0*2048kB 0*4096kB = 5684kB
[248285.939610] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[248285.939611] 80 total pagecache pages
[248285.939612] 0 pages in swap cache
[248285.939613] Swap cache stats: add 0, delete 0, find 0/0
[248285.939613] Free swap  = 0kB
[248285.939614] Total swap = 0kB
[248285.939614] 524188 pages RAM
[248285.939615] 0 pages HighMem/MovableOnly
[248285.939616] 10612 pages reserved
[248285.939616] 0 pages hwpoisoned
[248285.939617] Out of memory: Kill process 2130 (memhog) score 943 or sacrifice child
[248285.939726] Killed process 2130 (memhog) total-vm:1998720kB, anon-rss:1994396kB, file-rss:4kB
---------------------------------------------

without stack trace:
---------------------------------------------
[248310.662881] memhog invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[248310.662885] memhog cpuset=/ mems_allowed=0
[248310.662888] Mem-Info:
[248310.662891] active_anon:501678 inactive_anon:43 isolated_anon:0
                 active_file:23 inactive_file:13 isolated_file:0
                 unevictable:0 dirty:16 writeback:0 unstable:0
                 slab_reclaimable:1780 slab_unreclaimable:2046
                 mapped:7 shmem:59 pagetables:1446 bounce:0
                 free:3375 free_pcp:30 free_cma:0
[248310.662908] Node 0 DMA free:7988kB min:40kB low:48kB high:60kB active_anon:7536kB inactive_anon:4kB active_file:0kB inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:4kB writeback:0kB mapped:8kB shmem:12kB slab_reclaimable:28kB slab_unreclaimable:56kB kernel_stack:64kB pagetables:40kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? yes
[248310.662912] lowmem_reserve[]: 0 1988 1988 1988
[248310.662914] Node 0 DMA32 free:5512kB min:5588kB low:6984kB high:8380kB active_anon:1999176kB inactive_anon:168kB active_file:96kB inactive_file:44kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080760kB managed:2038396kB mlocked:0kB dirty:60kB writeback:0kB mapped:20kB shmem:224kB slab_reclaimable:7092kB slab_unreclaimable:8128kB kernel_stack:2432kB pagetables:5744kB unstable:0kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:884 all_unreclaimable? yes
[248310.662925] lowmem_reserve[]: 0 0 0 0
[248310.662952] Node 0 DMA: 7*4kB (UEM) 2*8kB (UE) 5*16kB (UE) 0*32kB 5*64kB (UE) 5*128kB (UEM) 3*256kB (UE) 2*512kB (EM) 3*1024kB (UE) 1*2048kB (U) 0*4096kB = 7996kB
[248310.662966] Node 0 DMA32: 140*4kB (UE) 39*8kB (UEM) 11*16kB (EM) 2*32kB (E) 0*64kB 1*128kB (E) 3*256kB (UM) 3*512kB (U) 2*1024kB (UM) 0*2048kB 0*4096kB = 5592kB
[248310.662981] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[248310.662982] 110 total pagecache pages
[248310.662984] 0 pages in swap cache
[248310.662986] Swap cache stats: add 0, delete 0, find 0/0
[248310.662988] Free swap  = 0kB
[248310.662989] Total swap = 0kB
[248310.662990] 524188 pages RAM
[248310.662991] 0 pages HighMem/MovableOnly
[248310.662993] 10612 pages reserved
[248310.662994] 0 pages hwpoisoned
[248310.662997] Out of memory: Kill process 2134 (memhog) score 943 or sacrifice child
[248310.663637] Killed process 2134 (memhog) total-vm:1998720kB, anon-rss:1994716kB, file-rss:0kB
---------------------------------------------

-- 
Aristeu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
