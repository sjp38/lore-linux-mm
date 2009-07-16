Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ED6AC6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 14:32:29 -0400 (EDT)
Date: Thu, 16 Jul 2009 11:51:33 -0700 (PDT)
From: "Li, Ming Chun" <macli@brc.ubc.ca>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
In-Reply-To: <23396.1247764286@redhat.com>
Message-ID: <alpine.DEB.1.00.0907161130120.16004@mail.selltech.ca>
References: <4A5F5454.8070300@redhat.com> <20090716133454.GA20550@localhost> <4987.1247760908@redhat.com> <23396.1247764286@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, David Howells wrote:

> Rik van Riel <riel@redhat.com> wrote:
> 
> > It's part of a series of patches, including the three posted by Kosaki-san
> > last night (to track the number of isolated pages) and the patch I posted
> > last night (to throttle reclaim when too many pages are isolated).
> 
> Okay; Rik gave me a tarball of those patches, which I applied and re-ran the
> test.  The first run of msgctl11 produced lots of:
> 
> 	[root@andromeda ltp]# while ./testcases/bin/msgctl11; do :; done

I applied the series of patches on 2.6.31-rc3 and run 

while ./testcases/bin/msgctl11; do :; done 

four times, only got one OOM kill in the first round and the system is 
quite responsive all the time.

# while ./testcases/bin/msgctl11; do :; done
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    0  WARN  :  Fork failure in first child of child group 1587
msgctl11    0  WARN  :  Fork failure in first child of child group 1586
..snip...........
msgctl11    1  FAIL  :  Child exit status = 4

# while ./testcases/bin/msgctl11; do :; done
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    0  WARN  :  Fork failure in first child of child group 1573
msgctl11    0  WARN  :  Fork failure in first child of child group 1524
...............snip.....
msgctl11    1  FAIL  :  Child exit status = 4

# while ./testcases/bin/msgctl11; do :; done
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    0  WARN  :  Fork failure in first child of child group 1050
msgctl11    0  WARN  :  Fork failure in first child of child group 795
msgctl11    1  FAIL  :  Child exit status = 4

# while ./testcases/bin/msgctl11; do :; done
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16303 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!
msgctl11    0  INFO  :  Using upto 16301 pids
msgctl11    0  WARN  :  Fork failure in first child of child group 1346
msgctl11    0  WARN  :  Fork failure in first child of child group 924
...........snip........
msgctl11    1  FAIL  :  Child exit status = 4


Vincent Li
Biomedical Research Center
University of British Columbia

---
 kernel: [  735.507878] msgctl11 invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0
 kernel: [  735.507884] msgctl11 cpuset=/ mems_allowed=0
 kernel: [  735.507888] Pid: 20631, comm: msgctl11 Not tainted 2.6.31-rc3-custom #1
 kernel: [  735.507891] Call Trace:
 kernel: [  735.507900]  [<c01ad781>] oom_kill_process+0x161/0x280
 kernel: [  735.507905]  [<c01adcd3>] ? select_bad_process+0x63/0xd0
 kernel: [  735.507909]  [<c01add8e>] __out_of_memory+0x4e/0xb0
 kernel: [  735.507913]  [<c01ade42>] out_of_memory+0x52/0xa0
 kernel: [  735.507917]  [<c01b0b07>] __alloc_pages_nodemask+0x4d7/0x4f0
 kernel: [  735.507922]  [<c01b0b77>] __get_free_pages+0x17/0x30
 kernel: [  735.507927]  [<c012baa6>] pgd_alloc+0x36/0x250
 kernel: [  735.507932]  [<c01f4ad3>] ? dup_fd+0x23/0x340
 kernel: [  735.507936]  [<c01422f7>] ? dup_mm+0x47/0x350
 kernel: [  735.507939]  [<c0141dd9>] mm_init+0xa9/0xe0
 kernel: [  735.507943]  [<c0142329>] dup_mm+0x79/0x350
 kernel: [  735.507947]  [<c01ffe22>] ? copy_fs_struct+0x22/0x90
 kernel: [  735.507951]  [<c01432d5>] ? copy_process+0xc75/0x1070
 kernel: [  735.507955]  [<c0143090>] copy_process+0xa30/0x1070
 kernel: [  735.507959]  [<c054b204>] ? schedule+0x494/0xa80
 kernel: [  735.507963]  [<c014373f>] do_fork+0x6f/0x330
 kernel: [  735.507968]  [<c014fdce>] ? recalc_sigpending+0xe/0x40
 kernel: [  735.507972]  [<c0107716>] sys_clone+0x36/0x40
 kernel: [  735.507976]  [<c0108dd4>] sysenter_do_call+0x12/0x28
 kernel: [  735.507979] Mem-Info:
 kernel: [  735.507981] DMA per-cpu:
 kernel: [  735.507983] CPU    0: hi:    0, btch:   1 usd:   0
 kernel: [  735.507986] CPU    1: hi:    0, btch:   1 usd:   0
 kernel: [  735.507988] Normal per-cpu:
 kernel: [  735.507990] CPU    0: hi:  186, btch:  31 usd:  17
 kernel: [  735.507993] CPU    1: hi:  186, btch:  31 usd: 180
 kernel: [  735.507994] HighMem per-cpu:
 kernel: [  735.507997] CPU    0: hi:   42, btch:   7 usd:  22
 kernel: [  735.507999] CPU    1: hi:   42, btch:   7 usd:   0
 kernel: [  735.508008] active_anon:82389 inactive_anon:2043 isolated_anon:32
 kernel: [  735.508009]  active_file:2201 inactive_file:5773 isolated_file:31
 kernel: [  735.508010]  unevictable:0 dirty:4 writeback:0 unstable:0 buffer:19
 kernel: [  735.508011]  free:1825 slab_reclaimable:655 slab_unreclaimable:19679
 kernel: [  735.508012]  mapped:1309 shmem:113 pagetables:66757 bounce:0
 kernel: [  735.508020] DMA free:3520kB min:64kB low:80kB high:96kB active_anon:2240kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15832kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:132kB kernel_stack:120kB pagetables:2436kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
 kernel: [  735.508026] lowmem_reserve[]: 0 867 998 998
 kernel: [  735.508035] Normal free:3632kB min:3732kB low:4664kB high:5596kB active_anon:269136kB inactive_anon:0kB active_file:56kB inactive_file:20kB unevictable:0kB isolated(anon):128kB isolated(file):124kB present:887976kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:2620kB slab_unreclaimable:78584kB kernel_stack:77328kB pagetables:227972kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:222 all_unreclaimable? no
 kernel: [  735.508042] lowmem_reserve[]: 0 0 1052 1052
 kernel: [  735.508051] HighMem free:148kB min:128kB low:268kB high:408kB active_anon:58180kB inactive_anon:8172kB active_file:8748kB inactive_file:23072kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:134688kB mlocked:0kB dirty:16kB writeback:0kB mapped:5232kB shmem:452kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:36620kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
 kernel: [  735.508057] lowmem_reserve[]: 0 0 0 0
 kernel: [  735.508061] DMA: 8*4kB 2*8kB 2*16kB 2*32kB 1*64kB 0*128kB 1*256kB 2*512kB 0*1024kB 1*2048kB 0*4096kB = 3536kB
 kernel: [  735.508073] Normal: 142*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3664kB
 kernel: [  735.508084] HighMem: 2*4kB 10*8kB 2*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 120kB
 kernel: [  735.508095] 8102 total pagecache pages
 kernel: [  735.508097] 0 pages in swap cache
 kernel: [  735.508099] Swap cache stats: add 0, delete 0, find 0/0
 kernel: [  735.508101] Free swap  = 0kB
 kernel: [  735.508103] Total swap = 0kB
 kernel: [  735.510778] 261775 pages RAM
 kernel: [  735.510780] 33938 pages HighMem
 kernel: [  735.510782] 21851 pages reserved
 kernel: [  735.510784] 279954 pages shared
 kernel: [  735.510786] 216034 pages non-shared
 kernel: [  735.510789] Out of memory: kill process 14702 (msgctl11) score 96635 or a child
 kernel: [  735.510793] Killed process 17847 (msgctl11)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
